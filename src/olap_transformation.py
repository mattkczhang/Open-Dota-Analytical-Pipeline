import pymongo
import pandas as pd
import csv

PROJECTION = {'match_id': 1,
              'radiant_win': 1,
              'start_time': 1,
              'duration': 1,
              'tower_status_radiant': 1,
              'tower_status_dire': 1,
              'barracks_status_radiant': 1,
              'barracks_status_dire':1,
              'first_blood_time': 1,
              '_id': 0
             }
PROJECTION2 = {'match_id':1, 'start_time':1, 'chat':1, '_id':0}
data_proc_path = './data/processed/'
match_stat_fn = 'match_stat.csv'
chat_fn = 'chat.csv'
chat_headers=['match_id', 'start_time', 'time', 'key']

PROJECTION3 = {'players':1, 'radiant_win':1, '_id':0}
hero_headers = ['hero_id', 'match_result']
hero_fn = 'hero_performance.csv'

def create_empty_csv(filename, headers):
    df = pd.DataFrame([], columns=headers)
    fp = f'{data_proc_path}/{filename}'
    df.to_csv(fp, header=True, index=False)
#     display(pd.read_csv(fp))
    
def proj_to_headers(proj):
    return [key for key in proj.keys() if proj[key] == 1]

def create_cursor(client, proj, lmt, query={}):
    db1 = client.get_database('dota')
    collection1 = db1['matches']
    if lmt is None:
        cursor = collection1.find({}, proj)
    else:
        cursor = collection1.find({}, proj).limit(lmt)
    return cursor

def subset_match_stat(client, proj = PROJECTION, lmt = 100, append = False):
    cursor = create_cursor(client, proj, lmt)
    headers = proj_to_headers(proj)
#     print(len(headers))
    if not append:
        create_empty_csv(match_stat_fn, headers)
        print(f'new document {match_stat_fn} created')
    with open(f'{data_proc_path}/{match_stat_fn}', 'a', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames = headers)
        for document in cursor:
#         print(len(document))
            writer.writerow(document)
    print('finished writing')
    display(pd.read_csv(f'{data_proc_path}/{match_stat_fn}').head())
    
def subset_chat(client, proj = PROJECTION2, lmt = 100, append = False):
    cursor = create_cursor(client, proj, lmt)
    headers = chat_headers
    if not append:
        create_empty_csv(chat_fn, headers)
        print(f'new document {chat_fn} created')
    with open(f'{data_proc_path}/{chat_fn}', 'a') as fh:
        for document in cursor:
            if not document['chat']:
                continue
#             print(document)
            df = pd.DataFrame(document)
            expanded_df = pd.concat([df[['match_id', 'start_time']], (df['chat'].apply(pd.Series)[['time', 'key']])], axis=1)
            expanded_df['match_id'] = expanded_df['match_id'].astype('str')
            expanded_df['start_time'] = expanded_df['start_time'].astype('str')
#             display(expanded_df)
            expanded_df.to_csv(f'{data_proc_path}/{chat_fn}', index=False, header=False, mode='a')
    print('finished writing')
    display(pd.read_csv(f'{data_proc_path}/{chat_fn}').head())
            
def record_hero_performance(client, proj = PROJECTION3, lmt = 100, append = False):
    def calculate_victory(row):
        if ((row['player_slot'] <= 127) and (row['radiant_win'])):
            return 'w'
        elif ((row['player_slot'] > 127) and not (row['radiant_win'])):
            return 'w'
        else:
            return 'l'
    cursor = create_cursor(client, proj, lmt)
    headers = hero_headers
    if not append:
        create_empty_csv(hero_fn, headers)
        print(f'new document {hero_fn} created')
    with open(f'{data_proc_path}/{hero_fn}', 'a', newline='') as fh:
        for doc in cursor:
            df = pd.DataFrame(doc['players'])
#             display(df)
            df['radiant_win'] = doc['radiant_win']
            df = df[['hero_id', 'player_slot','radiant_win']]
            df['match_result'] = df[['hero_id', 'player_slot','radiant_win']].apply(calculate_victory, axis=1)
#             display(df)
            results = df[hero_headers]
            results.to_csv(f'{data_proc_path}/{hero_fn}', index=False, mode='a', header=False)
    display(pd.read_csv(f'{data_proc_path}/{hero_fn}').head())
