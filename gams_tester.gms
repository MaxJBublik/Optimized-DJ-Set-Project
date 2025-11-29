*the input will be a text file that gets created from the main.py
*later on will be done sequentially through jupyter notebook

$call csv2gdx songdata.csv id=d index=1 values=2..lastCol useHeader=y storeZero=y
*this call creates my gdx File

set i( *) label of song;
set j(*) parameter name;
parameter d(i, j);
*$onEmbeddedCode Connect:
*- CSVReader:
*    file: songdata.csv
*    name: d
*    header: true
*    indexColumns: 1
*    valueColumns: "2:lastcol"
*
*- GAMSWriter:
*    writeAll: true
*$offEmbeddedCode
*

$gdxin songdata.gdx
$load i = Dim2
$load j = Dim1
$load d
$gdxIn


display d, i, j;
*list of parameter names...
*danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness,
*valence, tempo, id(not needed), duration_ms, time_signature



Parameter danceability(i), energy(i), key(i), loudness(i), mode(i);



