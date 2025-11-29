$gdxIn gj_ef7c01ea_base_3_gdxin.gdx
$onMultiR
$gdxIn
$offeolcom
$eolcom #
Option Reslim=600;

equations
    objective                       "Objective function"
    flowBalance(i)                  "Flow balance at each song node"
    timeconst                       "Used to account for time over the hour limit"
    useSongConstraintu              "Used to set upper bound for binary variable if I am using a song"
    useSongConstraintl              "Used to set lower bound for binary variable if I am using a song"
    costarcs                        "The cost equation per arc. I will change this equation to optimize over different parameters"
    oneIncomingFlowConstraint(i)    "Node can have one arc flow in"
    oneOutgoingFlowConstraint(i)    "Node can have one arc flow out"
    noflowtoself(i, i)              "Song's cannot flow into themselves, prevent cycling"
    pathorderconst(i, i)            "Establishes an order of songs"
    ;

objective..
    cost =e= sum(arcs(i, k), arcCost(i, k)) + (overtime/10000);

flowBalance(i)..
    sum(k$arcs(i, k), flowat(i,k)) - sum(l$arcs(l, i), flowat(l,i)) =e= supply(i);
    
timeconst..
    sum(i, songUsed(i)*durration(i)) =e= timelimit + overtime;
    
useSongConstraintu(i)..
    songUsed(i) =l= 2*sum(k$arcs(i, k), flowat(i, k));
    
useSongConstraintl(i)..
    songUsed(i) =g= sum(k$arcs(i, k), flowat(i, k));
    
costarcs(i, k)$(arcs(i, k))..
    arcCost(i, k) =e= abs(tempo(i) - tempo(k))*songUsed(i);

oneIncomingFlowConstraint(i)..
    sum(k$arcs(k, i), flowat(k, i)) =l= 1;

oneOutgoingFlowConstraint(i)..
    sum(k$arcs(i, k), flowat(i, k)) =l= 1;
    
noflowtoself(i, i)..
    flowat(i, i) =e= 0;

pathorderconst(i, k)$(not sameas(i, 'source') and arcs(i, k))..
    position(k) - position(i) =g= 1 - 100*(1 - flowat(i, k));
    

    
model optimalsong /all/;


solve optimalsong using MIP min cost;

parameter eachcost(i, k);
eachcost(i, k) = arcCost.l(i, k)$(flowat.l(i, k))
display flowat.l, songUsed.l, position.l, cost.l, overtime.l;
