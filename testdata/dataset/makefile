INPUTS:= $(wildcard *.jsonld)
OUTPUT-RDF=$(patsubst %.jsonld,%.nt,${INPUTS})
OUTPUT-format=$(patsubst %.jsonld,%.format,${INPUTS})

%.nt: %.jsonld
	rdf serialize --input-format jsonld --processingMode json-ld-1.1 $(CURDIR)/$< --output $(CURDIR)/$@

all: ${OUTPUT-RDF}

clean:
	rm -rf ${OUTPUT-RDF}
	rm -rf ${OUTPUT-format}


%.format: %.jsonld
	jq -S . $< > $@
	cp $@ $<

format: ${OUTPUT-format}

