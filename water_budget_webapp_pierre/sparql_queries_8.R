# Link for graph database https://terminology.internetofwater.app
devtools::install_github("vsenderov/rdf4r")
# Import packages
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
library(rdf4r)

# Load and parse TTL file from graphDB
#file <- rdf_parse("graphDB2.ttl", format="turtle")
file <- basic_triplestore_access("https://terminology.internetofwater.app", repository="WaterBudgetingFramework_core")

# ----- 1. creating dataframe for flow and component-subcomponent info ----- #
query_component <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?c ?fsourceL ?fsource ?fsinkL ?fsink ?ftypeL ?ftype ?scL ?sc ?pscL ?psc ?exmL ?exm WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL{
    ?c wb:flowSource ?fsource.
    ?fsource rdfs:label ?fsourceL.
    }
    OPTIONAL{
    ?c wb:flowSink ?fsink.
    ?fsink rdfs:label ?fsinkL.
    }
    OPTIONAL{
    ?c wb:isFlowType ?ftype.
    ?ftype rdfs:label ?ftypeL.
    }
    OPTIONAL{
    ?c wb:isSubComponentOf ?sc.
    ?sc rdfs:label ?scL.
    }
    OPTIONAL{
    ?c wb:isPartialSubComponentOf ?psc.
    ?psc rdfs:label ?pscL.
    }
    OPTIONAL{
    ?c skos:isExactMatch ?exm.
    ?exm rdfs:label ?exmL.
    }
}
"
df_component_full <- submit_sparql(query_component,access_options=file)

# Assign NA to empty values
df_component_full[df_component_full == ""] <- NA

# Remove rows with components not having state name at the end "-__"
df_component_full <- df_component_full[grepl("-[A-Z]*", df_component_full$cL),]

# Similarly remove rows with subcomponents, partial subcomponents and exact matches without state names at the end
# for subcomponents
for (i in 1:nrow(df_component_full)){
  # Retain rows with NAs and remove others with names other than the ones that have state at the end
  if (!is.na(df_component_full$scL[i])){
    df_component_full <- df_component_full[-i] #drop the rows that are not NA (checking)(NOT WORKING)
  }
}

# for subcomponents
df_component_full <- df_component_full[grepl("-[A-Z]*", df_component_full$scL),]

# for partial subcomponents
df_component_full <- df_component_full[grepl("-[A-Z]*", df_component_full$pscL),]

# for exact matches
df_component_full <- df_component_full[grepl("-[A-Z]*", df_component_full$exmL),]


df_component_full <- arrange(df_component_full, jL, cL, fsourceL, fsinkL, ftypeL, scL, pscL, exmL)
df_component_full$cL <- gsub("-NMOSE","-NM", df_component_full$cL)
df_component_full <- df_component_full[grep(".-CA|.-CO|.-NM|.-UT|.-WY", df_component_full$cL),] 
df_component_full$cL <- gsub("-[A-Z][A-Z]","", df_component_full$cL)
df_component_flow <- df_component_full[c(1,2,(seq(4,length(df_component_full), 2)))]
write_csv(df_component_full, "www/df_component_full.csv")
write_csv(df_component_flow, "www/df_component_flow.csv")

#----------------------------REMOVER THIS LATER-------------------------------#
query_state <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    
SELECT ?jL ?cL ?emL ?pL ?dsL WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    
    ?em wb:usedBy ?j.
    ?em rdf:type wb:EstimationMethod.
    ?em rdfs:label ?emL.
    ?em wb:hasParameter ?p.
    
    ?p wb:usedBy ?j.
    ?p rdf:type wb:Parameter.
    ?p rdfs:label ?pL.
    ?p wb:hasDataSource ?ds.
    
    ?ds wb:usedBy ?j.
    ?ds rdf:type wb:DataSource.
    ?ds rdfs:label ?dsL.
    }
}
"
results_state <- rdf_query(file, query_state)
#----------------------------REMOVER THIS LATER (above)-------------------------------#

#----------------------------REMOVER THIS LATER-------------------------------#
query_state <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    
SELECT ?jL ?cL ?emL ?pL ?dsL WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
#    	?em wb:usedBy ?j.
      ?c wb:hasEstimationMethod ?em.
    
    	?em rdfs:label ?emL.
#      ?p wb:usedBy ?j.
    	?em wb:hasParameter ?p.
    
    	?p rdfs:label ?pL.
    	?ds wb:usedBy ?j.
      ?p wb:hasDataSource ?ds.
    
    	?ds rdfs:label ?dsL.
    }
} 
"
results_state <- rdf_query(file, query_state)
#----------------------------REMOVER THIS LATER (above)-------------------------------#

# ---- 2. creating dataframe state-wise info ---- #
query_state <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    
SELECT ?jL ?cL ?emL ?pL ?dsL WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.

    ?em rdfs:label ?emL.
    ?em wb:hasParameter ?p.

    ?p rdfs:label ?pL.
    ?p wb:hasDataSource ?ds.

    ?ds rdfs:label ?dsL.
    }
}
" 

results_state <- rdf_query(file, query_state)
df_state <- as.data.frame(results_state) 
# remove components usedBy river basins
df_state <- df_state[(df_state$jL %in% c("CA", "CO", "NM", "UT", "WY")),]
#df_state <- select(df_state, -type)
df_state <- df_state[grep(".-CA|.-CO|.-NMOSE|.-UT|.-WY", df_state$cL),] #Exclude NM
#$cL <- gsub("-NMOSE","-NM", df_state$cL) 

# Data source tab
df_data_source <- select(df_state, -jL)
df_data_source <- df_data_source[,c(4,3,2,1)]
df_data_source$dsL <- gsub(",","", df_data_source$dsL)
write_csv(df_data_source, "www/df_data_source.csv")

# Component tab
df_component <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
df_component$cL <- gsub("-[A-Z][A-Z][A-Z][A-Z][A-Z]","", df_component$cL) #remove "-NMOSE" for New mexico in output
df_component$cL <- gsub("-[A-Z][A-Z]","", df_component$cL) # remove state initials from components
df_component$dsL <- gsub(",","", df_component$dsL)
write_csv(df_component, "www/df_component.csv")

# State tab
df_state <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
df_state$cL <- gsub("-[A-Z][A-Z][A-Z][A-Z][A-Z]","", df_state$cL)
df_state$cL <- gsub("-[A-Z][A-Z]","", df_state$cL) # remove state initials from components
df_state$dsL <- gsub(",","", df_state$dsL)
write_csv(df_state, "www/df_state.csv")


# Everything (including url)
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?j ?jL ?c ?cL ?em ?emL ?p ?pL ?ds ?dsL ?type WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdfs:label ?emL.
    ?em wb:hasParameter ?p.
    ?p rdfs:label ?pL.
    ?p wb:hasDataSource ?ds.
    ?ds rdfs:label ?dsL.
    }
}
"

res <- rdf_query(file, query)

# Exporting as dataframe
df <- as.data.frame(res)
#df <- df[which(df$type == 'Component'),]
df <- arrange(df, cL, emL, pL, dsL) # each column in ascending order
#df <- select(df, -type)
df$dsL <- gsub(",","", df$dsL)
write.table(df, file = "./www/hyperlink.csv", sep = ",",
            qmethod = "double", quote=FALSE, 
            row.name = FALSE)




##########################################################################################################################
##########################################################################################################################
##########################################################################################################################
# INTERSTATE

# --- Exact Match --- # 
# containing all the relevant flow information
# properties like flow type, flowsink and source are put in a separat optional tag for c and with the same optional tag for ex

query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>

SELECT ?state_cL ?ftype_cL ?fsource_cL ?fsink_cL ?cL ?exmL ?state_exmL ?ftype_exmL ?fsource_exmL ?fsink_exmL ?c ?exm FROM onto:readwrite WHERE {
    ?c wb:usedBy ?state_c.
    ?state_c rdfs:label ?state_cL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
  OPTIONAL {
    ?c skos:isExactMatch ?exm.
    ?exm rdfs:label ?exmL.
    ?exm wb:usedBy ?state_exm.
    ?state_exm rdfs:label ?state_exmL.
    
    ?exm wb:isFlowType ?ftype_exm.
    ?ftype_exm rdfs:label ?ftype_exmL.
    
    ?exm wb:flowSource ?fsource_exm.
    ?fsource_exm rdfs:label ?fsource_exmL.
    
    ?exm wb:flowSink ?fsink_exm.
    ?fsink_exm rdfs:label ?fsink_exmL.
  }
  
  OPTIONAL {
    ?c wb:isFlowType ?ftype_c.
    ?ftype_c rdfs:label ?ftype_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSource ?fsource_c.
    ?fsource_c rdfs:label ?fsource_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSink ?fsink_c.
    ?fsink_c rdfs:label ?fsink_cL.
  }
}
"
# Getting dataframe from SPARQL query
df <- submit_sparql(query,access_options=file)

# Remove rows with components and exact matches not having state name at the end "-__"
df <- df[grepl("-[A-Z]*", df$cL),]
df <- df[grepl("-[A-Z]*", df$exmL),]

# Assign NA to empty values
df_component_full[df_component_full == ""] <- NA

# remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "UT", "WY")),]
df <- df[(df$state_exmL %in% c("CA", "CO", "NM", "UT", "WY", NA)),]
df$empty <- NA
# check how will user input work in R shiny based on 
write_csv(df, "www/df_exact_match.csv")


#--- Subcomponent ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?state_cL ?ftype_cL ?fsource_cL ?fsink_cL ?cL ?scL ?state_scL ?ftype_scL ?fsource_scL ?fsink_scL ?c ?sc WHERE {
    ?c wb:usedBy ?state_c.
    ?state_c rdfs:label ?state_cL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
  
  OPTIONAL {
    ?c wb:isSubComponentOf ?sc.
    ?sc rdfs:label ?scL.
    ?sc wb:usedBy ?state_sc.
    ?state_sc rdfs:label ?state_scL.
    
    ?sc wb:isFlowType ?ftype_sc.
    ?ftype_sc rdfs:label ?ftype_scL.
    
    ?sc wb:flowSource ?fsource_sc.
    ?fsource_sc rdfs:label ?fsource_scL.
    
    ?sc wb:flowSink ?fsink_sc.
    ?fsink_sc rdfs:label ?fsink_scL.
  }
    
  OPTIONAL {
    ?c wb:isFlowType ?ftype_c.
    ?ftype_c rdfs:label ?ftype_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSource ?fsource_c.
    ?fsource_c rdfs:label ?fsource_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSink ?fsink_c.
    ?fsink_c rdfs:label ?fsink_cL.
  }
}
"
results <- rdf_query(file, query)
df <- as.data.frame(results)

# remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "UT", "WY")),]
df <- df[(df$state_scL %in% c("CA", "CO", "NM", "UT", "WY", NA)),]
df$empty <- NA
# export dataframe for R shiny 
# df_subcomponent.csv right now has components without flow info and D3 works with that
# but with flow information d3 doesnt work...
# so change the file name below so i can go back and forth between flow info/no flow info
write_csv(df, "www/df_subcomponent.csv")


#--- Partial Subcomponent ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?state_cL ?ftype_cL ?fsource_cL ?fsink_cL ?cL ?pscL ?state_pscL ?ftype_pscL ?fsource_pscL ?fsink_pscL ?c ?psc WHERE {
    ?c wb:usedBy ?state_c.
    ?state_c rdfs:label ?state_cL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
  
  OPTIONAL {
    ?c wb:isPartialSubComponentOf ?psc.
    ?psc rdfs:label ?pscL.
    ?psc wb:usedBy ?state_psc.
    ?state_psc rdfs:label ?state_pscL.
    
    ?psc wb:isFlowType ?ftype_psc.
    ?ftype_psc rdfs:label ?ftype_pscL.
    
    ?psc wb:flowSource ?fsource_psc.
    ?fsource_psc rdfs:label ?fsource_pscL.
    
    ?psc wb:flowSink ?fsink_psc.
    ?fsink_psc rdfs:label ?fsink_pscL.
  }
    
  OPTIONAL {
    ?c wb:isFlowType ?ftype_c.
    ?ftype_c rdfs:label ?ftype_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSource ?fsource_c.
    ?fsource_c rdfs:label ?fsource_cL.
  }
  
  OPTIONAL {
    ?c wb:flowSink ?fsink_c.
    ?fsink_c rdfs:label ?fsink_cL.
  }
}
"
results <- rdf_query(file, query)
df <- as.data.frame(results)

# remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "UT", "WY")),]
df <- df[(df$state_pscL %in% c("CA", "CO", "NM", "UT", "WY", NA)),]
df$empty <- NA
# export dataframe for R shiny 
# df_subcomponent.csv right now has components without flow info and D3 works with that
# but with flow information d3 doesnt work...
# so change the file name below so i can go back and forth between flow info/no flow info
write_csv(df, "www/df_partial_subcomponent.csv")

# ---X--- #