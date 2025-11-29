from dotenv import load_dotenv
import os
import base64
from requests import post, get 
import json
import pandas as pd
import csv

load_dotenv()

client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")


def get_token():
    auth_string = client_id + ":" + client_secret
    auth_bytes = auth_string.encode("utf-8")
    auth_base64 = str(base64.b64encode(auth_bytes), "utf-8")
    
    url = "https://accounts.spotify.com/api/token"
    headers = {
        "Authorization": "Basic " + auth_base64,
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {"grant_type": "client_credentials"}
    result = post(url, headers=headers, data=data)
    json_result = json.loads(result.content)
    token = json_result["access_token"]
    return token



def get_auth_header(token):
    return {"Authorization": "Bearer " + token}


#request a playlist and save the track ID's of the playlist in a list format. Use the Track ID's to request info about tracks and add them to pandas DF

mytoken = get_token()
test_id = '7sj6GJx0FD3NPC9RRaUiG3'


# the playlist ID is right after the playlist/ part, like so - https://open.spotify.com/playlist/7sj6GJx0FD3NPC9RRaUiG3?si=0d800b9b1a5846bd
#use raving paul playlist to debug 7sj6GJx0FD3NPC9RRaUiG3

#NEW TEST PLAYLIST IS MUCH LONGER TO TEST MODEL
#03MYJGCIKvaLIZWmyvyEks?si=76571d8fd2ec4bb3

def playlist_IDs(token, playlist_ID):
    url = f'https://api.spotify.com/v1/playlists/{playlist_ID}/tracks'
    headers = get_auth_header(token)
    
    result = get(url, headers=headers)
    json_result = json.loads(result.content)
    
    track_id = dict()
    for x in range(len(json_result['items'])):
        #this creates the loop to get the track ID of every song in a playlist
        track_id[json_result['items'][x]['track']['name']] = (json_result['items'][x]['track']['id'])
    return(track_id)
    

    
def song_data(token, playlist_ID):
    song_dict = playlist_IDs(token, playlist_ID)
    song_data = dict()
    song_names = list(song_dict.keys())
    song_ids = list(song_dict.values())
    song_ids_string = ','.join(song_ids)
    
    #get my song_ids into a continuous comma separated string to use in the request
    
    url = f'https://api.spotify.com/v1/audio-features?ids={song_ids_string}'
    headers = get_auth_header(token)
    result = get(url, headers=headers)
    json_result = json.loads(result.content)
    data = json_result['audio_features']
    #get my song data
    
    #test assertions that my lists are the same length, and that the data is from the right track ID
    assert len(data) == len(song_names) == len(song_ids), "the lengths of data, song_names and song_ids are not equal"
    for x in range(len(data)):
        assert data[x]['id'] == song_ids[x], f'the song ids at {x} are not equal'
        
        song_data[song_names[x].lower()] = data[x]

       
    
    return song_data


csv_file_path = 'songdata.csv'
data = song_data(mytoken, test_id)
#data2 = song_data(mytoken, '03MYJGCIKvaLIZWmyvyEks')

#data = {**data1, **data2}
print(len(data))


data_val = list(data.values())
data_key = list(data.keys())

for x in range(len(data)):
    data_val_dict = data_val[x]
    liveness = data_val_dict['liveness']
    speechiness = data_val_dict['speechiness']
    key = data_val_dict['key']
    if (liveness >= 0.8) or (speechiness >= 0.66) or (key == -1):
        del data[data_key[x]]
        print('deleted' + data_key[x])

dataframe = pd.DataFrame(data)
dataframe = dataframe.drop(['analysis_url', 'track_href', 'uri', 'type', 'id', 'liveness'], axis = 0)
dataframe['sink'] = 0
dataframe['source'] = 0
print(dataframe)


#first clear the csv file
with open(csv_file_path, mode='w', newline=''):
    pass

dataframe.to_csv(csv_file_path, index=True)
#now I have a dictionary with the song name and all data associated with the song.