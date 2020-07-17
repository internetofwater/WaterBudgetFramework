library(shiny)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG.ttl", format="turtle")

query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
 PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
 PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
 PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
 SELECT ?jL ?cL ?emL ?pL ?dsL WHERE {
   ?c wb:usedBy ?j.
   ?j rdfs:label ?jL.
   ?c rdfs:label ?cL.
   ?c wb:hasEstimationMethod ?em.
   ?em rdfs:label ?emL.
   ?em wb:hasParameter ?p.
   ?p rdfs:label ?pL.
   ?p wb:hasDataSource ?ds.
   ?ds rdfs:label ?dsL.
  
 }"

results <- rdf_query(file, query)
df <- as.data.frame(results)
df <- arrange(df, cL, emL, pL, dsL)# each column in ascending order
df$cL <- gsub("-[A-Z][A-Z]"," ", df$cL)#remove state initials from components
nested_json <- d3_nest(data = df, root = "States")


ui <- fluidPage(
  tags$h1("Water Budget App"),
  tags$body(tags$div(id = "container")),
  tags$script(src = "https://d3js.org/d3.v5.min.js"), 
  tags$script(src = "index v3.js")
)

server <- function(input, output){}

shinyApp(ui = ui, server = server) 
