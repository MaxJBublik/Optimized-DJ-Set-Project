from main import *
from gdx import GdxFile, GAMSDatabase

data_val = list(data.values())
data_key = list(data.keys())

for x in range(len(data)):
    data_val_dict = data_val[x]
    liveness = data_val_dict['liveness']
    speechiness = data_val_dict['speechiness']
    if (liveness >= 0.8) or (speechiness >= 0.66):
        del data[data_key[x]]
        print('deleted' + data_key[x])
        
with GdxFile() as gdx:
    # Add data to the GDX file
    for parameter, values in data.items():
        for index, value in values.items():
            gdx[parameter, index] = value

    # Save the GDX file
    gdx.write('songdata.gdx')

# Load the GDX file into a GAMS database
with GAMSDatabase('songdata.gdx') as db:
    # Display the content of the GAMS database
    print(db)
