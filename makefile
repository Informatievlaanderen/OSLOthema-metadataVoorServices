# List of input files (example files)
#INPUTS=6.output.jsonld 7.output.jsonld 8.output.jsonld
#INPUTS=metadata_dcat.jsonld dcatapvl.jsonld geodcatapvl.jsonld
INPUTS=release/metadata_dcat.jsonld release/dcatapvl.jsonld release/geodcatapvl.jsonld 
OUTPUTCSV=$(patsubst %.jsonld,%.csv,${INPUTS})

all: final_with_description.csv final_with_testcount.csv

%.csv: %.jsonld
	# Entract the ruleid and the id into a file which sorted on the first key (ruleid)
	jq '.shapes[]."sh:property"[] | [."vl:rule",."@id"] | join(";")' $< | sed 's/\"//g' | awk -F ';' '{if ($$1=="") {print sprintf("%s-%03d","$<",NR)";"$$2;} else {print $$0;}}' | sort -d -t ";" -k 1 > $@
	# Add the filename as a header for the 2nd column
	sed -i '1s?.*?vl:rule;$<?' $@
	sed -i "s/\r//g" $@

	# join the files as needed
final.csv: ${OUTPUTCSV}
	#Extract all the ids know from the csv files and sort as seed file
	cat ${OUTPUTCSV} | awk -F ";" '$$1!="vl:rule"{print $$1"";}' | sort -d -t ";" -k 1 | uniq > final.csv
	sed -i '1s/.*/vl:rule/' final.csv
	cp final.csv final_seed.csv
	for f in ${OUTPUTCSV}; do join --header -t ";" -j 1 -a 1 -e "_" -o auto final.csv $${f} > tmp.csv; mv tmp.csv final.csv; done
	sed -i "s/\r//g" final.csv

	# Merge in any description/extra information which is needed.
final_with_description.csv: final.csv sdescription.csv
	join -e "_" -o auto --header -t ";" -j 1 -a 1 final.csv sdescription.csv > $@

sdescription.csv: description.csv
	sort -t ";" -k 1 description.csv > $@
	sed -i '1s/.*/;description/' $@

# Process the rulefiles
TESTDATAFILES=${wildcard testdata/*.nt}
TESTDATARES=$(patsubst %.nt,%.jsonld,${TESTDATAFILES})
TESTDATARESCSV=$(patsubst %.nt,%.csv,${TESTDATAFILES})
RESULTTESTDATARES=$(patsubst testdata/%.nt,result/metadata_dcat/%.jsonld,${TESTDATAFILES})
RESULTTESTDATARESCSV=$(patsubst %.nt,%.csv,${RESULTTESTDATARES})

final_with_testcount.csv: uniq.csv final_with_description.csv
	(head -n 1 final_with_description.csv && tail -n +2 final_with_description.csv | LANG=en_EN sort -f -t ";" -k 3 ) > fdescriptions.csv
	LANG=en_EN join -i --header -t ";" -1 3 -2 1 -a 1 -o 1.1,2.2,1.2,1.3,1.4 -e "_" fdescriptions.csv uniq.csv > final_with_tc.csv
	(head -n 1 final_with_tc.csv && tail -n +2 final_with_tc.csv | sort -d -t ";" -k 1 ) > $@

.PRECIOUS: testdata/%.jsonld
testdata/%.jsonld: testdata/%.nt
	curl -H "Content-type:application/json" \
	     -H "Accept: application/json" \
	     -d '{"contentToValidate":"https://github.com/Informatievlaanderen/OSLOthema-metadataVoorServices/raw/validation/$<","validationType":"dcat_ap_vl", "reportSyntax":"application/ld+json"}' \
	     https://data.dev-vlaanderen.be/shacl-validator-backend/shacl/applicatieprofielen/api/validate > $@

.PRECIOUS: result/metadata_dcat/%.jsonld
result/metadata_dcat/%.jsonld: testdata/%.nt
	mkdir -p result/metadata_dcat
	curl -H "Content-type:application/json" \
	     -H "Accept: application/json" \
	     -d '{"contentToValidate":"https://github.com/Informatievlaanderen/OSLOthema-metadataVoorServices/raw/validation/$<","validationType":"metadata_dcat", "reportSyntax":"application/ld+json"}' \
	     https://data.dev-vlaanderen.be/shacl-validator-backend/shacl/applicatieprofielen/api/validate > $@

.PRECIOUS: result/metadata_dcat/%.csv
result/metadata_dcat/%.csv: result/metadata_dcat/%.jsonld

uniq2 : ${RESULTTESTDATARESCSV}

.PRECIOUS: testdata/%.csv
testdata/%.csv: testdata/%.jsonld
	jq '."@graph"[] | [."sourceShape",."@id"] | join(";")' $< | sed 's/\"//g' | sort -t ";" -k 1 > $@
	sed -i "s/\r//g" $@

uniq.csv: ${TESTDATARESCSV}
	cat ${TESTDATARESCSV} | awk -F ';' '{print $$1;}' | sort -t ';' -k 1 | uniq -c | awk '{print $$2";"$$1;}' > $@
	sed -i '1s/.*/;test-count/' $@


clean:
	rm -rf ${OUTPUTCSV} final.csv tmp.csv final_with_description.csv ${TESTDATARESCSV} uniq.csv final_with_testcount.csv ${TESTDATARES} sdescription.csv sdescriptions.csv fdescription.csv fdescriptions.csv sfinal.csv final_with_tc.csv final_seed.csv final2.csv


ruby-build:
	docker build -f Dockerfile.ruby -t cruby .

ruby:
	docker run --rm -it --name crubyt -v $(CURDIR):/data cruby bash
