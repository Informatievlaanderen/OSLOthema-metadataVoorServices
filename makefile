# List of input files
INPUTS=6.output.jsonld 7.output.jsonld 8.output.jsonld
OUTPUTCSV=$(patsubst %.jsonld,%.csv,${INPUTS})

# The first in the list used as the seed
FIRST := $(shell echo ${OUTPUTCSV} | awk '{print $$1;}')
# The remainder of the list of files minus the seed file (used when joining)
REM := $(shell echo ${OUTPUTCSV} | awk '{for (i=2; i<=NF; i++) print $$i}')

all: final.csv
#	echo ${OUTPUTCSV}

%.csv: %.jsonld
	# Entract the ruleid and the id into a file which sorted on the first key (ruleid)
	jq '.shapes[]."sh:property"[] | [."vl:rule",."@id"] | join(",")' $< | sed 's/\"//g' | sort -t "," -k 1 > $@
	# Add the filename as a header for the 2nd column
	sed -i '1s/.*/,$</' $@

	# join the files as needed
final.csv: ${OUTPUTCSV}
	cat ${FIRST} > final.csv ; \
	for f in ${REM}; do join --header -t "," -j 1 final.csv $${f} > tmp.csv; mv tmp.csv final.csv; done

clean:
	rm -rf ${OUTPUTCSV} final.csv tm.csv
