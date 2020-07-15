# IoW Water Budget Framewor

This is the repository describing the Water Budget Framework (WBF) project. A Water Budget (sometimes called Water Account or Water Balance) is ["...an accounting of the rates of water movement and the change in water storage in all or parts of the atmosphere, land surface, and subsurface."](https://water.usgs.gov/watercensus/AdHocComm/Background/WaterBudgets-FoundationsforEffectiveWater-ResourcesandEnvironmentalManagement.pdf)

Of course, there are many many ways to produce such an accounting. Where these ways differ is not merely an academic exercise in accuracy. Water budget estimates can have legal and political consequences as different jurisdictions.
The WBF projis a mapping of

1. California DWR [Water Budget Handbook With or Without Models]
2. USGS [Colorado River Basin Specifically](https://www.usgs.gov/mission-areas/water-resources/science/colorado-river-basin-focus-area-study?qt-science_center_objects=0#qt-science_center_objects)
3. Utah DWR [Water Budget Model](https://www.westernstateswater.org/utah-division-of-water-resources-water-budget-program-methods-description/)
4. New Mexico [Dynamic Statewide Water Budget](https://nmwrri.nmsu.edu/new-mexico-dynamic-statewide-water-budget/)
5. Colorado [StateWB](https://www.colorado.gov/pacific/cdss/statewb) and its contributors StateMod (surface water model) and StateCU (consumptive use)
6. Australia [National Water Accounts](http://www.bom.gov.au/water/nwa/2018/)
7. Wyoming
8. USBR LCRAS

The documentation describing each of this water budgeting frameworks are in the folders in this repository. Some water budegting frameworks are integrated models that run on one computer program (e.g. Utah, Colorado). Some are ensemble models (e.g. California, New Mexico). 

For a good high-level introduction to the concept of water budgeting, read Chapters 1 and 2 of the California Water Budget Handbook in detail.

## Ontology

The intermediate product will be an ontology. Watch this video for a brief into to ontologies.

[![What is an Ontology?](https://www.youtube.com/watch?v=jfUPLuPL3Ho)](https://www.youtube.com/watch?v=jfUPLuPL3Ho)




### Ontology Management
We host ontologies which are managed in [WebProtege](https://webprotege.stanford.edu)! 

### The Resource Description Framework

Ontologies are represented in a paradigm called the "Resource Description Framework", using
 OWL (Web Ontology Language). RDF data can be queried using SPARQL (Protocal and RDF Query Language). These two resources are good introductions to RDF and SPARQL for R users:
 
 - [A tidyverse lover's intro to RDF](https://cran.r-project.org/web/packages/rdflib/vignettes/rdf_intro.html)
 - [The Data Lake and Schema on Read](https://docs.ropensci.org/rdflib/articles/articles/data-lake.html)

## Tool

This common tool will serve as a way to quickly visualize the components associated with each State’s water budgeting framework, and the possible estimation methods, data inputs, data transformation methods, and raw data sources composing each component. There will be an underlying relational database model linking all of these together. There will also be an interactive tool that will allow users to drill down into their components of choice, for example like this:

 https://github.com/metrumresearchgroup/d3Tree

Perhaps with a guided interface like this: 

https://carlganz.shinyapps.io/rintrojsexample/
