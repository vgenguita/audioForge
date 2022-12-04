import csv
import json
import sys
import music_tag  # pip install music-tag
import os
# Variables
csvFilePath = r'albums.csv'
jsonFilePath = r'albums.json'

# Functions


def csv_to_json(csvFilePath, jsonFilePath):
    jsonArray = []
    # read csv file
    with open(csvFilePath, encoding='utf-8') as csvf:
        # load csv file data using csv library's dictionary reader
        csvReader = csv.DictReader(csvf) 

        # convert each csv row into python dict
        for row in csvReader:
            # add this python dict to json array
            jsonArray.append(row)
    # convert python jsonArray to JSON String and write to file
    with open(jsonFilePath, 'w', encoding='utf-8') as jsonf:
        jsonString = json.dumps(jsonArray, indent=4)
        jsonf.write(jsonString)


def getDataAlbum(key, field):
    for keyval in data:
        if key == keyval['cddb']:
            return keyval[field]


def existCddb(key):
    for entry in data:
        if key == entry['cddb']:
            return True
            print('Existe')


if len(sys.argv) < 2:
    print(f"Use script: {sys.argv[0]} device")
    exit()
else:
    csv_to_json(csvFilePath, jsonFilePath)
    f = open(jsonFilePath)
    data = json.load(f)

    # TODO Load key from wav folder
    # keyVal = sys.argv[1]
    if existCddb(keyVal):
        relData = [getDataAlbum(keyVal, 'Artist'),
                   getDataAlbum(keyVal, 'Album'),
                   getDataAlbum(keyVal, 'Year'),
                   getDataAlbum(keyVal, 'disc'),
                   getDataAlbum(keyVal, 'comments'),
                   getDataAlbum(keyVal, 'compilation')]
        # external programs
        ripcd = "cdda2wav -vall cddb=0 speed=4 -paranoia paraopts=proof -B -D"
        os.system(cmd)
        print(f"Data: {relData}")
    else:
        print("Item is not found")
