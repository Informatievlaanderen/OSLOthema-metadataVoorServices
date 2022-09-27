# Validation branch

Deze branch bevat de informatie & tools om een overzicht te maken van de validatieregels in het metadata DCAT ecosysteem.
In de toekomst kan het zijn dat deze branch op een andere plek gezet wordt.  

# structuur
De directory input-shacl bevat alle shacl files die momenteel genereerd worden door de OSLO-Specgenerator tool (multilingual-dev).


## validatie 

The next steps will do a validation for a profile w.r.t. a environment. 
In this case the development environment of data.vlaanderen.be.

```
make prepare
cd result/<environment>
make prepareprofile
cd <profile>
make  
```
