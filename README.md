# IoW Water Budget Framework

This is the repository describing the Water Budget Framework (WBF) project. A Water Budget (sometimes called Water Account or Water Balance) is ["...an accounting of the rates of water movement and the change in water storage in all or parts of the atmosphere, land surface, and subsurface."](https://water.usgs.gov/watercensus/AdHocComm/Background/WaterBudgets-FoundationsforEffectiveWater-ResourcesandEnvironmentalManagement.pdf)

Water Budgets generally track water within a ZONE, where the basic equation is 

Change in Storage = Outflows - Inflows

The WBF is a mapping of

1. California DWR [Water Budget Handbook With or Without Models]
2. USGS [Colorado River Basin Specifically](https://www.usgs.gov/mission-areas/water-resources/science/colorado-river-basin-focus-area-study?qt-science_center_objects=0#qt-science_center_objects)
3. Utah DWR [Water Budget Model](https://www.westernstateswater.org/utah-division-of-water-resources-water-budget-program-methods-description/)
4. New Mexico [Dynamic Statewide Water Budget](https://nmwrri.nmsu.edu/new-mexico-dynamic-statewide-water-budget/)
5. Colorado [StateWB](https://www.colorado.gov/pacific/cdss/statewb)
6. Australia [National Water Accounts](http://www.bom.gov.au/water/nwa/2018/)

The documentation describing each of this water budgeting frameworks are in the folders in this repository. Some water budegting frameworks are integrated models that run on one computer program (e.g. Colorado). Some are ensemble models (e.g. New Mexico). Some will vary by region (e.g. USGS, California, Australia).

## Ontology

The intermediate product will be an ontology. Watch this video for a brief into to ontologies.

[![What is an Ontology?](https://i.ytimg.com/vi/jfUPLuPL3Ho/hqdefault.jpg)](https://www.youtube.com/watch?v=jfUPLuPL3Ho-Y "What is an Ontology")

### Ontology Management
We host ontologies which are managed in WebProtege. Go here to make an account and log in [WebProtege Link](https://webprotege.stanford.edu)


### How our ontology works

Our ontology tracks 4 basic aspects of water budgets and relates them together. Let's see all four in action with an important element of most water budgets: Evapotranspiration.

1. Components: These are the flows and/or changes in volumes of water within a zone. For example: Evapotranspiration

[![Component properties encoded in our WBF ontology](https://raw.githubusercontent.com/internetofwater/waterbudgetframework/master/Blank%20Diagram.png)]

2. Estimation Methods: These are the models, which include 1 or more systems of 1 or more equations used to estimate the volumes of components. For example, the [Penman-Montieth equation](http://www.fao.org/3/X0490E/x0490e06.htm) estimates Referance Evapotranspiration.

3. Parameters: The individual elements of Estimation Methods. For example, R<sub>n</sub>  is a parameter for "Net Radiation", one of many terms in the Penman-Montieth Equation.

4. Data Sources: The data sources reccomended and/or approved for use in a given Water Budgeting Framework for a given parameter. For example, one jurisdication's WBF might reccomend the [NASA FlashFlux Daily Solar Radiation dataset](https://neo.sci.gsfc.nasa.gov/view.php?datasetId=CERES_NETFLUX_D&date=2019-12-01) for the "Net Radiation" parameter.
