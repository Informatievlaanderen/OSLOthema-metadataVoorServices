SHELL=/bin/bash

# List of input files (example files)
#INPUTS=metadata_dcat.jsonld dcatapvl.jsonld geodcatapvl.jsonld
INPUTS=release/metadata_dcat.jsonld release/dcatapvl.jsonld release/geodcatapvl.jsonld 
OUTPUTCSV=$(patsubst %.jsonld,%.csv,${INPUTS})

all: final_with_description.csv 

%.csv: %.jsonld
	# Entract the ruleid and the id into a file which sorted on the first key (ruleid)
	jq '.shapes[]."sh:property"[] | [."vl:rule",."@id"] | join(";")' $< | sed 's/\"//g' | awk -F ';' '{if ($$1=="") { $$id = gensub(/(.+)#(.+)/,"\\2\\1/\\2","g", $$0) ; print $$id  ; } else {print $$0;}}' | sort -d -t ";" -k 1 > $@
	# Add the filename as a header for the 2nd column
	HH=`basename -s .jsonld $<` ;\
	sed -i "1s?.*?vl:rule;$${HH}?" $@
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





PROFILES=dcat_ap_vl metadata_dcat geodcat_ap_vl
ENVIRONMENTS=result/dev result/test result/prod

prepare: ${ENVIRONMENTS}

.PHONY: prepare

$(ENVIRONMENTS):
	mkdir -p $@
	for it in ${PROFILES} ; do \
	   mkdir -p $@/$$it ; \
	   cp -r testdata $@/$$it ; \
	done 
	cp result/makefile.env $@/makefile
	cp result/makefile.profile.$(notdir $@) $@/makefile.profile
	cp result/makefile.profile-gen $@/makefile.profile-gen



clean:
	rm -rf ${OUTPUTCSV} final.csv tmp.csv final_with_description.csv ${TESTDATARESCSV} uniq.csv final_with_testcount.csv ${TESTDATARES} sdescription.csv sdescriptions.csv fdescription.csv fdescriptions.csv sfinal.csv final_with_tc.csv final_seed.csv final2.csv
	rm -rf ${ENVIRONMENTS}


ruby-build:
	docker build -f Dockerfile.ruby -t cruby .

ruby:
	docker run --rm -it --name crubyt -v $(CURDIR):/data cruby bash
