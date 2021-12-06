#!/bin/bash

curl -H "Content-type:application/json" \
     -H "Accept: */*" \
    -d '{"contentToValidate":"https://github.com/Informatievlaanderen/OSLOthema-metadataVoorServices/raw/validation/testdata/error-catalog-maxcard.nt","validationType":"dcat_ap_vl"}'  \
    https://data.dev-vlaanderen.be/shacl-validator-backend/shacl/applicatieprofielen/api/validate

curl -H "Content-type:application/json" \
     -H "Accept: application/json" \
    -d '{"contentToValidate":"https://github.com/Informatievlaanderen/OSLOthema-metadataVoorServices/raw/validation/testdata/error-catalog-maxcard.nt","validationType":"dcat_ap_vl", "reportSyntax":"application/ld+json"}'  \
    https://data.dev-vlaanderen.be/shacl-validator-backend/shacl/applicatieprofielen/api/validate
