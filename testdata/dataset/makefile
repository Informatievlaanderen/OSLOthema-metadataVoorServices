INPUTS:= $(wildcard *.jsonld)
OUTPUT-RDF=$(patsubst %.jsonld,%.nt,${INPUTS})

%.nt: %.jsonld
	rdf serialize --input-format jsonld --processingMode json-ld-1.1 $(CURDIR)/$< --output $(CURDIR)/$@

all: ${OUTPUT-RDF}

clean:
	rm -rf ${OUTPUT-RDF}

