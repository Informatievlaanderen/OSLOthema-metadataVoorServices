#!/bin/bash

INPUT=$1
COLUMN=$2
OUTPUT=$INPUT.merged
TABLE=final.csv

# cleanup
rm -rf /tmp/${TABLE}.int

cut -d ';' -f 1,${COLUMN} ${TABLE} &> /tmp/${TABLE}.int


TMPINPUT=/tmp/INPUT.0
TMPOUTPUT=/tmp/INPUT.1
cp ${INPUT} ${TMPINPUT}
while IFS=';' read -r vlnb uri
do
    echo "$vlnb and $uri"
    jq --arg vlrule "$vlnb" --arg uri "$uri" 'def map(f): [.[] | f ]; def rule(u; v): if ."@id" == u then ."vl:rule" |= v else . end ; .shapes |= map(.["sh:property"] |= map( rule("\($uri)"; "\($vlrule)"))) ' ${TMPINPUT} > ${TMPOUTPUT}
    cp ${TMPOUTPUT} ${TMPINPUT}
done < /tmp/${TABLE}.int

cp ${TMPOUTPUT} ${OUTPUT}

#jq --arg vlrule "v901" '.shapes[0]|.["sh:property"] ' ${INPUT}
#jq --arg vlrule "v901" '.shapes[0]|.["sh:property"][] | select( ."vl:rule" == "\($vlrule)") ' ${INPUT}
#jq --arg vlrule "v901" '.shapes[0]|.["sh:property"][] | select( ."vl:rule" == "\($vlrule)") | ."vl:rule" ' ${INPUT}
#jq --arg vlrule "v901" '.shapes[0]|.["sh:property"][] | select( ."vl:rule" == "\($vlrule)") |."vl:rule" |= "update" ' ${INPUT}
#jq --arg vlrule "v901" '.shapes[0]| select( .["sh:property"][]."vl:rule" == "\($vlrule)") |."vl:rule" |= "update" ' ${INPUT}
#echo "list" 
#jq --arg vlrule "v901" '.shapes[0]|.["sh:property"] |= [  .[] | if  ."vl:rule" == "\($vlrule)" then  ."vl:rule" |= "update"  else .  end  ]' ${INPUT}
#jq --arg vlrule "v901" 'def map(f): [.[] | f ]; def rule(v): if ."vl:rule" == v then ."vl:rule" |= "UPDATE" else . end ; .shapes[0]|.["sh:property"] |= map( rule("\($vlrule)")) ' ${INPUT}
#
#echo "list2" 
#jq --arg vlrule "v901" 'def map(f): [.[] | f ]; def rule(v): if ."vl:rule" == v then ."vl:rule" |= "UPDATE" else . end ; .shapes| map(.["sh:property"] |= map( rule("\($vlrule)"))) ' ${INPUT} > 22
#jq --arg vlrule "v901" 'def map(f): [.[] | f ]; def rule(v): if ."vl:rule" == v then ."vl:rule" |= "UPDATE" else . end ; .shapes |= map(.["sh:property"] |= map( rule("\($vlrule)"))) ' ${INPUT} > 33
#
