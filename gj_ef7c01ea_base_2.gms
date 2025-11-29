$gdxIn gj_ef7c01ea_base_2_gdxin.gdx
$onMultiR
$if not declared i set i(*) 'song label';
$load i
$if not declared j set j(*) 'parameter';
$load j
$if not declared d parameter d(j,i) '';
$load d
$gdxIn
$offeolcom
$eolcom #
set arcs(i, i);
alias(i, k, l);


parameter danceability(i), energy(i), key(i), loudness(i), mode(i), speechiness(i), acousticness(i), instrumentalness(i), valence(i), tempo(i), durration(i), time_signature(i), supply(i);

danceability(i) = d('danceability', i);
energy(i) = d('energy', i);
key(i) = d('key', i);
loudness(i) = d('loudness', i);
mode(i) = d('mode', i);
speechiness(i) = d('speechiness', i);
acousticness(i) = d('acousticness', i);
instrumentalness(i) = d('instrumentalness', i);
valence(i) = d('valence', i);
tempo(i) = d('tempo', i);
durration(i) = d('duration_ms', i);
time_signature(i) = d('time_signature', i);


scalar timelimit "the set should be a minimum of one hour (3.6 million milliseconds)" /3600000/;

variable cost, arccost(i, i);
positive variable flow(i, i), position(i), overtime;
binary variable flowat(i, i), songUsed(i);


Loop((i, k),
    if (sameas(i, k),
        arcs(i, k) = no;
    else
        if (mode(i) = mode(k), 
            if ((abs(key(i) - key(k)) <= 1) or (abs(key(i) - key(k)) = 11),
                arcs(i, k) = yes;
            else
                arcs(i, k) = no;
            );
        else
            if (key(i) = key(k),
                arcs(i, k) = yes;
            else
                arcs(i, k) = no;
            );
    );
);
);

arcs('source', i) = yes;
arcs(i, 'source') = no;
arcs(i, 'sink') = yes;
arcs('sink', i) = no;
arcs('source', 'sink') = no;

supply('source') = 1;
supply('sink') = -1;

