import pymongo
import json
import gzip
# migrate them to config later on
DATA_PATH = 'data/raw/yasp-dump-2015-12-18.json.gz'
DBNAME = 'dota' 
CNAME = 'matches'
UID = 'match_id'

# the function that wraps everything together
def build_db(dbname = DBNAME, cname = CNAME, uid = UID, path = DATA_PATH, N = None):
    collection = get_db(dbname = dbname, cname = cname, uid = UID)
    read_json(collection, path = path, N = N)
    return collection

# construct a db if there isn't one, otherwise nothing would be effected
def get_db(dbname = DBNAME, cname = CNAME, uid = UID):
    client = pymongo.MongoClient()
    print(client)
    db = client[dbname]
    print(db)
    collection = db[cname] 
    print(collection)
    collection.create_index(uid, unique=True)
    print(collection.index_information())
    return collection

### precondition
# collection: a valid collection object,
# N: a integer number < number of entries
def read_json(collection, path = DATA_PATH, N = None):
    fh = gzip.open(path, mode = 'rt')
    # if we want only top N entries
    if N is not None:
        print('sampling topk data')
        counter = 0
        while counter < N:
            try:
                line = fh.readline()
                # lmao the naming of this
                counter = load_json_line(collection, line, counter=counter) 
            except:
                print(f'trouble reading line: {line}')
  
    else:
        print('loading entire data into db')
        for line in fh:
            load_json_line(collection, line)
    return

### precondition:
# collection: pymongo collection object
# line: a string object from file handler representing a line in file
def load_json_line(collection, line, counter=None):
    # if the line is not one of the poorly formatted delimiter
    try:
        parsed_dict = json.loads(line) 
    except JSONDecodeError:
        print(f'invalid json string: {line}')
        # if we are only doing top-k sampling
    if counter is not None:
        # update counter
        counter += 1
    try:
        collection.insert_one(parsed_dict)
    except DuplicateKeyError:
        print(f"duplicate entry with match_id: {parsed_dict['match_id']}")
    #else do nothing
    return counter
        




    
    