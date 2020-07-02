library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#library(rjson)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG.ttl", format="turtle")

#--- Parent-child ---#
# Only completed states (Colorado):
 # query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
 # PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
 # PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
 # PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
 # SELECT ?jL ?cL ?emL ?pL ?dsL WHERE {
 #   ?c wb:usedBy ?j.
 #   ?j rdfs:label ?jL.
 #   ?c rdfs:label ?cL.
 #   ?c wb:hasEstimationMethod ?em.
 #   ?em rdfs:label ?emL.
 #   ?em wb:hasParameter ?p.
 #   ?p rdfs:label ?pL.
 #   ?p wb:hasDataSource ?ds.
 #   ?ds rdfs:label ?dsL.
 #  
 # }"

# Everything
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?emL ?pL ?dsL ?type WHERE {
    ?c wb:usedBy ?j.
    ?c rdf:type ?t.
    ?t rdfs:label ?type.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdfs:label ?emL.
    ?em wb:hasParameter ?p.
    ?p rdfs:label ?pL.
    ?p wb:hasDataSource ?ds.
    ?ds rdfs:label ?dsL.
    }
} "

res <- rdf_query(file, query)

# Exporting as dataframe
df <- as.data.frame(res)
df <- df[which(df$type == 'Component'),]
df <- arrange(df, cL, emL, pL, dsL) # each column in ascending order
df$cL <- gsub("-[A-Z][A-Z]"," ", df$cL)#remove state initials from components
#df_colorado <- df[which(df$jL == 'CO'),]
#df_colorado <- select(df, -jL)
#df_colorado <- # SORT by components
#write_csv(df, "water_budget_june8.csv")

# checking
# state <- "CO"
# abc = df %>%
#   filter(jL %in% state)


# data <- data.frame(
#   level1="CEO",
#   level2=c( rep("boss1",4), rep("boss2",4)),
#   level3=paste0("mister_", letters[1:8])
# )

#data_json_example <- d3_nest(data)

nested_json <- d3_nest(data = df, root = "States");


#nested_json_colorado <- d3_nest(df_colorado, root = "CO")

write(nested_json, "../sample_json.json")
#write(nested_json, "../sample_json_full.json") # edit query to use prefLabel to remove state name
#write(nested_json_colorado, "../sample_json_colorado.json")



# Converting to JSON
# install.packages("reticulate")
# library("reticulate")
# library("jsonlite")
# df_json <- toJSON(df)
# df_json_2 <- serializeJSON(df)

#### -------------------------- Exploring dataframe to make options for "Search" tab

# flowSource, flowSink, isFlowType 
query2 <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?fsourceL ?fsinkL ?ftypeL WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    
    OPTIONAL{
    ?c wb:flowSource ?fsource.
    ?fsource rdfs:label ?fsourceL.
    
    ?c wb:flowSink ?fsink.
    ?fsink rdfs:label ?fsinkL.
    
    ?c wb:isFlowType ?ftype.
    ?ftype rdfs:label ?ftypeL.
    }
}
"
res2 <- rdf_query(file, query2)

# Exporting as dataframe
df2 <- as.data.frame(res2)


# everything with flowSource, flowSink and isFlowType
query3 <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?fsourceL ?fsinkL ?ftypeL ?emL ?pL ?dsL ?type WHERE {
    ?c wb:usedBy ?j.
    ?c rdf:type ?t.
    ?t rdfs:label ?type. 
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    
    OPTIONAL {
    ?c wb:flowSource ?fsource.
    ?fsource rdfs:label ?fsourceL.
    }
    OPTIONAL {
    ?c wb:flowSource ?fsink.
    ?fsink rdfs:label ?fsinkL.
    }
    OPTIONAL {
    ?c wb:flowSource ?ftype.
    ?ftype rdfs:label ?ftypeL.
    }
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdfs:label ?emL.
    }
    OPTIONAL {
    ?em wb:hasParameter ?p.
    ?p rdfs:label ?pL.
    }
    OPTIONAL {
    ?p wb:hasDataSource ?ds.
    ?ds rdfs:label ?dsL.
    }
    
} HAVING (?type = 'Component')
"

res3 <- rdf_query(file, query3)

# Exporting as dataframe
df3 <- as.data.frame(res3)
#df <- arrange(df, cL, emL, pL, dsL)
# unique flow source: zone groundwater, zone land system, zone surface water, 
# atmosphere, external groundwater, external surface water
# unique flow sink: everyhting above and external land system
# unique 
df3 <- df3[which(df3$type == 'Component'),]


# Only flow info and sub-component or partial sub-component info

query4 <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?fsourceL ?fsinkL ?ftypeL ?scL ?pscL WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    
  OPTIONAL {  
    ?c wb:isSubComponentOf ?sc.
    ?sc rdfs:label ?scL.
    
    ?c wb:isPartialSubComponentOf ?psc.
    ?psc rdfs:label ?pscL.
    
    ?c wb:flowSource ?fsource.
    ?fsource rdfs:label ?fsourceL.
    
    ?c wb:flowSink ?fsink.
    ?fsink rdfs:label ?fsinkL.
    
    ?c wb:isFlowType ?ftype.
    ?ftype rdfs:label ?ftypeL.
  }
}
"

res4 <- rdf_query(file, query4)

df4 <- as.data.frame(res4)








#### ----------------------------- Developing and exploring SPARQL queries

#--- Query 1: Jurisdiction -> Component ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?jL ?cL WHERE {
  ?c wb:usedBy ?j.
  ?c rdfs:label ?cL.
  ?j rdfs:label ?jL.
} "

results <- rdf_query(file, query)
df <- as.data.frame(result)

#--- Query 2: Component -> EstimationMethod ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?cL ?emL WHERE {
  ?c wb:usedBy ?j.
  ?c wb:hasEstimationMethod ?em.
  ?j rdfs:label ?jL.
  ?c rdfs:label ?cL.
  ?em rdfs:label ?emL.
} HAVING (?jL = 'CO')"

results <- rdf_query(file, query)
results

#--- Query 3: EstimationMethod -> Parameter ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?emL ?pL WHERE {
  ?c wb:usedBy ?j.
  ?c wb:hasEstimationMethod ?em.
  ?em wb:hasParameter ?p.
  ?j rdfs:label ?jL.
  ?c rdfs:label ?cL.
  ?em rdfs:label ?emL.
  ?p rdfs:label ?pL.
} HAVING (?jL = 'CO')"

results <- rdf_query(file, query)
results

#--- Query 4: Parameter -> DataSource ---# some data sources can not be filtered using states
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?pL ?dsL WHERE {
  ?c wb:usedBy ?j.
  ?c wb:hasEstimationMethod ?em.
  ?em wb:hasParameter ?p.
  ?p wb:hasDataSource ?ds.
  ?j rdfs:label ?jL.
  ?c rdfs:label ?cL.
  ?em rdfs:label ?emL.
  ?p rdfs:label ?pL.
  ?ds rdfs:label ?dsL.
}"

results <- rdf_query(file, query)
results

#--- Query 6: Sub Component ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?c2L WHERE {
  ?c1 wb:isSubComponentOf ?c2.
  ?c1 rdfs:label ?c1L.
  ?c2 rdfs:label ?c2L.
}"

results <- rdf_query(file, query)
results

#--- Query 6: Partial Sub Component ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?c2L WHERE {
  ?c1 wb:isPartialSubComponentOf ?c2.
  ?c1 rdfs:label ?c1L.
  ?c2 rdfs:label ?c2L.
}"

results <- rdf_query(file, query)
results

#--- Query 7: Flow Sink ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?c2L WHERE {
  ?c1 wb:flowSink ?c2.
  ?c1 rdfs:label ?c1L.
  ?c2 rdfs:label ?c2L.
}"

results <- rdf_query(file, query)
results

#--- Query 8: Flow Source ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?c2L WHERE {
  ?c1 wb:flowSource ?c2.
  ?c1 rdfs:label ?c1L.
  ?c2 rdfs:label ?c2L.
}"

results <- rdf_query(file, query)
results

#--- Query 9: Flow Type ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?ftL WHERE {
  ?c1 wb:isFlowType ?ft.
  ?c1 rdfs:label ?c1L.
  ?ft rdfs:label ?ftL.
}"

results <- rdf_query(file, query)
results
)

# ------------------------------------ separate

#--- Query: Exact Matches ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?c1L ?c2L WHERE {
  ?c1 skos:isExactMatch ?c2.
  ?c1 rdfs:label ?c1L.
  ?c2 rdfs:label ?c2L.
}"

results <- rdf_query(file, query) #some are repeated like a-b b-a

# ---------------------------------------- TEST

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
results <- as.data.frame(results)

# lookup optional sparql

