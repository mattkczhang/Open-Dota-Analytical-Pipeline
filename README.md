# Opendota_Analytical_Pipeline
 This is an attempt to design an end-to-end pipeline from api data from OpenDota to anlytical insights in BI tools.

## Overview
 The repo contains code necessary for constructing and loading data onto a local MongoDB instance as well as transforming (flattening) data for a OLAP instance on GCP using cloud SQL. 
 
## Contents

- `src` contains the source code of our project, including algorithms for data extraction, analysis, and modelling.
- `visualization` contains stored eda pictures as well as a tableau work book object.
- `config` contains easily changable parameters to test the data under various circumstances or change directories as needed.
- `EDA.ipynb` is a notebook containing EDA works for the dataset prior to their loading onto the local OLTP (MongoDB) instance.
- `run.ipynb` is a notebook served as an informal run-script for the project's code base
- `requirements.txt` lists the Python package dependencies of which the code relies on. 



## How to Run

- Install the dependencies by running `pip install -r requirements.txt` from the root directory of the project.
- Data we used is from [here](https://academictorrents.com/details/384a08fd7918cd59b23fb0c3cf3cf1aea3ea4d42). HOwever, any match-data queried from OpenDota API works.

### Building the project stages using `run_notebook.ipynb`
- Since this is an notebook serving as a run script, simply run the cell accordingly for the corresponding functionality
- For Loading: 
	- build_db() is for creating the OLTP instance from scratch and loading the data locally
- For transformation:
	- subset_match_stat() is for getting match-level statistics
	- subset_chat() is for getting chat messages for every match
	- record_hero_performance() is for getting hero level statistics for every match
