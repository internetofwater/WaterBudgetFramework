# Link for graph database https://terminology.internetofwater.app

# Import packages
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#devtools::install_github("vsenderov/rdf4r")
library(rdf4r)

# Load and parse TTL file from graphDB
#file <- rdf_parse("graphDB2.ttl", format="turtle")
file <- basic_triplestore_access("https://terminology.internetofwater.app", repository="WaterBudgetingFramework_v2_core")

#***************************************************#
#***** I. TABS - COMPONENT, STATE, DATA SOURCE *****#
#***************************************************#

# ----- 1. Creating dataframe for flow and component-subcomponent info ----- #
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

# Submit query to get a dataframe
df_component_full <- submit_sparql(query_component,access_options=file)

# Assign NA to empty values
df_component_full[df_component_full == ""] <- NA

# Remove rows with components not having state name at the end "-__"
df_component_full <- df_component_full[grepl("-[A-Z]*", df_component_full$cL),]

# Similarly remove rows with subcomponents, partial subcomponents and exact matches without state names at the end

#--- For subcomponents
# get row number for which subcomponents are not NAs
index_NA <- which(is.na(df_component_full$scL), arr.ind=TRUE)
# get row numbers for which subcomponents do have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df_component_full$scL), arr.ind=TRUE)
# keep those rows
df_component_full <- df_component_full[c(index_NA, index_state),]

#--- For partial subcomponents
# get row number for which partial subcomponents are not NAs
index_NA <- which(is.na(df_component_full$pscL), arr.ind=TRUE)
# get row numbers for which parrtial subcomponents do have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df_component_full$pscL), arr.ind=TRUE)
# keep those rows
df_component_full <- df_component_full[c(index_NA, index_state),]

#--- For exact matches
# get row number for which exact matches are not NAs
index_NA <- which(is.na(df_component_full$exmL), arr.ind=TRUE)
# get row numbers for which exact matches do have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df_component_full$exmL), arr.ind=TRUE)
# keep those rows
df_component_full <- df_component_full[c(index_NA, index_state),]

# Sort column values in ascending order
df_component_full <- arrange(df_component_full, jL, cL, fsourceL, fsinkL, ftypeL, scL, pscL, exmL)

# Replace NMSOE for New Mexico to NM
df_component_full$cL <- gsub("-NMOSE","-NM", df_component_full$cL)

# Only keep the rows that are associated to the 5 US states (excluding Australia and US river basins)
df_component_full <- df_component_full[grep(".-CA|.-CO|.-NM|.-UT|.-WY", df_component_full$cL),] 

# Remove state names from components
df_component_full$cL <- gsub("-[A-Z][A-Z]","", df_component_full$cL)

# Remove URIs and store in a new dataframe
df_component_flow <- df_component_full[c(1,2,(seq(4,length(df_component_full), 2)))]

# Save as CSVs
write_csv(df_component_full, "www/df_component_full2.csv")
write_csv(df_component_flow, "www/df_component_flow2.csv")

##########################################################################################################################
# checking to get estimation methods

#########################################################################################################################


# ---- 2. creating dataframe state-wise info ---- #

# # Query for components that are directly linked with data sources
# query_state_c2ds <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
# PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
# PREFIX onto: <http://www.ontotext.com/>
#     
# SELECT ?jL ?cL ?dsL ?stateL FROM onto:explicit WHERE {
#     ?c wb:usedBy ?j.
#     ?j rdfs:label ?jL.
#     ?c rdfs:label ?cL.
#     ?c rdf:type wb:Component.
#     
#     ?c wb:hasDataSource ?ds.
#     
#     ?ds rdfs:label ?dsL.
#     ?ds wb:usedBy ?state.
#     
#     ?state rdfs:label ?stateL.
#   
# }"
# 
# # Submit query to get a dataframe
# df_state_c2ds <- submit_sparql(query_state_c2ds,access_options=file)
# 
# # Assign NA to empty values
# df_state_c2ds[df_state_c2ds == ""] <- NA
# 
# # Query for estimation methods that are directly linked with data sources
# query_state_em2ds <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
# PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
# PREFIX onto: <http://www.ontotext.com/>
#     
# SELECT ?jL ?cL ?emL ?dsL ?stateL FROM onto:explicit WHERE {
#     ?c wb:usedBy ?j.
#     ?j rdfs:label ?jL.
#     ?c rdfs:label ?cL.
#     ?c rdf:type wb:Component.
#     
#   OPTIONAL {
#     ?c wb:hasEstimationMethod ?em.
#     ?em wb:hasDataSource ?ds.
#     
#     ?em rdf:type wb:EstimationMethod.
#     ?em rdfs:label ?emL.
#     
#     ?ds rdfs:label ?dsL.
#     ?ds wb:usedBy ?state.
#     
#     ?state rdfs:label ?stateL.
#   }
# }"
# 
# # Submit query to get a dataframe
# df_state_em2ds <- submit_sparql(query_state_em2ds,access_options=file)
# 
# # Assign NA to empty values
# df_state_em2ds[df_state_em2ds == ""] <- NA

# Query for components that are directly linked to estimation methods, parameters, and data sources
query_state_c2em <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>

SELECT ?jL ?cL ?emL FROM onto:explicit WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdf:type wb:EstimationMethod.
    ?em rdfs:label ?emL.
    }
    FILTER regex(?jL, 'NM')
}"

query_state_c2p <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>

SELECT ?jL ?cL ?pL FROM onto:explicit WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasParameter ?p.
    ?p rdf:type wb:Parameter.
    ?p rdfs:label ?pL.
    #?em wb:usedBy ?state. #after adding this line, number of rows increasedby about 100 O_O
    }
    FILTER regex(?jL, 'NM')
}"

query_state_c2ds <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>

SELECT ?jL ?cL ?dsL FROM onto:explicit WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasDataSource ?ds.
    ?ds rdf:type wb:DataSource.
    ?ds rdfs:label ?dsL.
    #?p wb:usedBy ?state.
    #?ds wb:usedBy ?state.
    #?state rdfs:label ?stateL.
    }
    FILTER regex(?jL, 'NM')
}"
    

df_state_c2em <- submit_sparql(query_state_c2em,access_options=file)
df_state_c2em[df_state_c2em == ""] <- NA
df_state_c2p <- submit_sparql(query_state_c2p,access_options=file)
df_state_c2p[df_state_c2p == ""] <- NA
df_state_c2ds <- submit_sparql(query_state_c2ds,access_options=file)
df_state_c2ds[df_state_c2ds == ""] <- NA

index_na_c2em <- which(is.na(df_state_c2em$emL), arr.ind=TRUE)
index_na_c2p <- which(is.na(df_state_c2p$pL), arr.ind=TRUE)
index_na_c2ds <- which(is.na(df_state_c2ds$dsL), arr.ind=TRUE)

common_na <- intersect(intersect(index_na_c2em, index_na_c2p), index_na_c2ds)

df_state_c2em <- df_state_c2em[-c(common_na),]
df_state_c2em$emL <- replace_na(df_state_c2em$emL,"Unknown/NA")
df_state_c2p <- df_state_c2p[-c(common_na),]
df_state_c2p$pL <- replace_na(df_state_c2p$pL,"Unknown/NA")
df_state_c2ds <- df_state_c2ds[-c(common_na),]
df_state_c2ds$dsL <- replace_na(df_state_c2ds$dsL,"Unknown/NA")

# Query for components that are  linked in sequential chain (not directly linked to data sources)
query_state <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>
    
SELECT ?jL ?cL ?emL ?pL ?dsL ?stateL FROM onto:explicit WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdf:type wb:EstimationMethod.
    ?em rdfs:label ?emL.
    }
    
    OPTIONAL {
    ?em wb:hasParameter ?p.
    ?p rdf:type wb:Parameter.
    ?p rdfs:label ?pL.
    #?em wb:usedBy ?state. #after adding this line, number of rows increasedby about 100 O_O
    }
    
    OPTIONAL {
    ?p wb:hasDataSource ?ds.
    ?ds rdf:type wb:DataSource.
    ?ds rdfs:label ?dsL.
    #?p wb:usedBy ?state.
    ?ds wb:usedBy ?state.
    ?state rdfs:label ?stateL.
    }
    
    FILTER regex(?jL, 'NM')
}
"

# Submit query to get a dataframe, returns 3 millions relationships
df_state <- submit_sparql(query_state,access_options=file)

# Assign NA to empty values
df_state[df_state == ""] <- "Unknown/NA"
#df_state[df_state == ""] <- NA

##################################################3
# remove duplicates!!!!
# see components for exsample, sooo manyyyy duplicates!!!
###################################################

# Check if the jurisdiction is same as the state usedBy property
# get index for the rows where usedBy state is not same as jurisdiction 
index <- which(!df_state$jL == df_state$stateL)
# subset using the index
df_state <- df_state[-c(index), ]


# Drop column stateL
df_state <- df_state[,-6]

# Use dataframe having components with direct links to filter this dataframe
# this helps to drop comonents that do not have any estimtion methods, parameters and data sources
check <- df_state %>%
  filter(cL %in% df_state_c2em$cL)

# for a specific component, we only want to keep rows that have those specific parameters

unique_c <- unique(df_state_c2p$cL) #get unique components
n_components <- length(unique(df_state_c2p$cL)) #number of unique components
for (i in 1:n_components){
  index_c <- which(df_state$cL == unique_c[i], arr.ind = TRUE) 
  unique_em <- unique(df_state[c(index_c),3])
  n_em <- length(unique(unique_em))
  print(index_c)
  print(unique_c[i])
  for (j in 1:n_em){
    index_em <- which(df_state$emL == unique_em[j], arr.ind = TRUE)
    check_df <- df_state_c2p[which(df_state_c2p$cL == unique_c[i]),]
    print(index_em)
    print(check_df)
    if ((check_df$pL[1] %in% "Unknown/NA") & (df_state[index_em,3][1] %in% "Unknown/NA")) {
      df_state[c(index_em),]$pL <- "Unknown/NA"
      # or else
    } else {
      # rows where parameters dont match, drop
      index_drop <- which(!df_state$pL %in% check_df$pL)
      df_state <- df_state[-index_drop, ]
    }
    # Similarly for data source (we might not need this coz this in normal case, but might need for unknown case)
    # check_df <- df_state_c2ds[which(df_state_c2ds$cL == unique_c[i]),]
    # if ((check_df$dsL[1] %in% "Unknown/NA") & (df_state[index_em,4][1] %in% "Unknown/NA")) { #probably there is no data source that will be unknown.
    #   df_state[c(index_em),]$dsL <- "Unknown/NA"
    #   # or else
    # } else {
    #   # rows where parameters dont match, drop
    #   index_drop <- which(!df_state$dsL %in% check_df$dsL)
    #   df_state <- df_state[-index_drop, ]
    # }
  } 
    
}

### Think about it,
### What if there are 3 estimation methods, 1 of which has unknown parameters, wtf!!!!
### think about unknown cases :(
### seems to be working so far, comment later

# try an example with 1 component in NM
index_c <- which(df_state$cL == "Irrigated Agriculture Diversions-NMOSE", arr.ind = TRUE) #get index of a specific component
unique_em <- unique(df_state[c(index_c),3]) #for that component, get unique estimation methods
n_em <- length(unique(unique_em)) #number of unique estimation methods
print(index_c)
print(unique_c[i])
# iterate through each estimation method
for (j in 1:n_em){
  index_em <- which(df_state$emL == unique_em[j], arr.ind = TRUE) #get index for the estimation method in main df
  check_df <- df_state_c2p[which(df_state_c2p$cL == "Irrigated Agriculture Diversions-NMOSE"),] #subset parameter df for that specific component
  # if estimation method is unknown and parameter is also unknown  
  if ((check_df$pL[1] %in% "Unknown/NA") & (df_state[index_em,3][1] %in% "Unknown/NA")) {
      df_state[c(index_em),]$pL <- "Unknown/NA"
  # or else
  } else {
      # rows where parameters dont match, drop
      index_drop <- which(!df_state$pL %in% check_df$pL)
      df_state <- df_state[-index_drop, ]
  }
  
  
  # Similarly for data source
  check_df <- df_state_c2ds[which(df_state_c2ds$cL == "Irrigated Agriculture Diversions-NMOSE"),]
  if ((check_df$dsL[1] %in% "Unknown/NA") & (df_state[index_em,4][1] %in% "Unknown/NA")) { #probably there is no data source that will be unknown.
    df_state[c(index_em),]$dsL <- "Unknown/NA"
    # or else
  } else {
    # rows where parameters dont match, drop
    index_drop <- which(!df_state$dsL %in% check_df$dsL)
    df_state <- df_state[-index_drop, ]
  }
} 

index_drop <- which(!df_state[c(index_em),]$pL %in% check_df$pL)



check <- check %>%
  filter((emL %in% df_state_c2em$emL) | (pL %in% df_state_c2p$pL) | (pL %in% df_state_c2p$pL) | (dsL %in% df_state_c2ds$dsL))

check <- df_state %>%
  filter((cL %in% df_state_c2em$cL) & (emL %in% df_state_c2em$emL))

check <- check %>%
  filter((cL %in% df_state_c2p$cL) & (pL %in% df_state_c2p$pL))

check <- check %>%
  filter((cL %in% df_state_c2ds$cL) & (dsL %in% df_state_c2ds$dsL))

check <- unique(check)


index <- which(df_state$cL %in% df_state_c2em$cL)
check <- df_state[index,]

#        
#        %>%
# filter(pL %in% df_state_c2p$pL) %>%
# filter(dsL %in% df_state_c2ds$dsL)





length(unique(df_state$cL))
length(unique(df_state_direct$cL))


################### compare Commercial: Schools-NMOSE in "check" dataframe with df_nm.csv in www folder. Its still repeating... :(

         

# Remove components usedBy river basins
df_state <- df_state[(df_state$jL %in% c("CA", "CO", "NM", "UT", "WY")),]
df_state <- df_state[grep(".-CA|.-CO|.-NMOSE|.-UT|.-WY", df_state$cL),] #Exclude NM

# Drop duplicate rows (for duplicate data sources)
df_state <- unique(df_state)

# Data source tab
df_data_source <- select(df_state, -jL)
df_data_source <- df_data_source[,c(4,3,2,1)]
df_data_source$dsL <- gsub(",","", df_data_source$dsL)
write_csv(df_data_source, "www/df_data_source2.csv")

# Component tab
df_component <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
df_component$cL <- gsub("-[A-Z][A-Z][A-Z][A-Z][A-Z]","", df_component$cL) #remove "-NMOSE" for New mexico in output
df_component$cL <- gsub("-[A-Z][A-Z]","", df_component$cL) # remove state initials from components
df_component$dsL <- gsub(",","", df_component$dsL)
write_csv(df_component, "www/df_component2.csv")

# State tab
df_state <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
df_state$cL <- gsub("-[A-Z][A-Z][A-Z][A-Z][A-Z]","", df_state$cL)
df_state$cL <- gsub("-[A-Z][A-Z]","", df_state$cL) # remove state initials from components
df_state$dsL <- gsub(",","", df_state$dsL)
write_csv(df_state, "www/df_state2.csv")


#---- 3. Everything (including uri & excluding exact matches and subcomponent stuff) ----#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX onto: <http://www.ontotext.com/>

SELECT ?j ?jL ?c ?cL ?em ?emL ?p ?pL ?ds ?dsL ?stateL FROM onto:explicit WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    ?c rdf:type wb:Component.
    
    OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    
    #?em rdf:type wb:EstimationMethod.
    ?em rdfs:label ?emL.
    ?em wb:hasParameter ?p.
    #?em wb:usedBy ?state. #this line reduced the number of rows by 50
    
    #?p rdf:type wb:Parameter.
    ?p rdfs:label ?pL.
    ?p wb:hasDataSource ?ds.
    #?p wb:usedBy ?state.
    
    #?ds rdf:type wb:DataSource.
    ?ds rdfs:label ?dsL.
    ?ds wb:usedBy ?state.
    
    ?state rdfs:label ?stateL.
    }
}
"

# Submit query to get a dataframe
df <- submit_sparql(query,access_options=file)

# Assign NA to empty values
df[df == ""] <- NA

# Check if the jurisdiction is same as the state usedBy property
# get index for the rows where usedBy state is not same as jurisdiction 
index <- which(!df$jL == df$stateL)
df <- df[-c(index), ]

# Drop column stateL
df <- df[,-11]

# Sort columns in ascending order
df <- arrange(df, cL, emL, pL, dsL) 

# Substitute comma with empty character
df$dsL <- gsub(",","", df$dsL)

# Export as a table
write.table(df, file = "./www/hyperlink2.csv", sep = ",",
            qmethod = "double", quote=FALSE, 
            row.name = FALSE)




#*********************************#
#***** II. TABS - INTERSTATE *****#
#*********************************#


# ----- 1. Exact Match ----- #

# Containing all the relevant flow information
# properties like flow type, flowsink and source are put in a separat optional tag for c and with the same optional tag for ex

query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
#PREFIX onto: <http://www.ontotext.com/>
#FROM onto:readwrite (insert at the end of SELECT statement)

SELECT ?state_cL ?ftype_cL ?fsource_cL ?fsink_cL ?cL ?exmL ?state_exmL ?ftype_exmL ?fsource_exmL ?fsink_exmL ?c ?exm WHERE {
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

# Submit query to get a dataframe
df <- submit_sparql(query,access_options=file)

# Assign NA to empty values
df[df == ""] <- NA

# Remove rows with components not having state name at the end "-__"
df <- df[grepl("-[A-Z]*", df$cL),]

# Remove rows where exact matches do not have state name at the end
# get row number for which exact matches are not NAs
index_NA <- which(is.na(df$exmL), arr.ind=TRUE)
# get row numbers for which exact matches have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df$exmL), arr.ind=TRUE)
# keep those rows
df <- df[c(index_NA, index_state),] 

# Remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "NMOSE", "UT", "WY")),]
df <- df[(df$state_exmL %in% c("CA", "CO", "NM", "NMOSE", "UT", "WY", NA)),]
df$empty <- NA

# Export as csv 
write_csv(df, "www/df_exact_match2.csv")


#---- 2. Subcomponent ----#
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

# Submit query to get a dataframe
df <- submit_sparql(query,access_options=file)

# Assign NA to empty values
df[df == ""] <- NA

# Remove rows with components not having state name at the end "-__"
df <- df[grepl("-[A-Z]*", df$cL),]

# Remove rows where subcomponents do not have state name at the end
# get row number for which subcomponents are not NAs
index_NA <- which(is.na(df$scL), arr.ind=TRUE)
# get row numbers for which subcomponents have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df$scL), arr.ind=TRUE)
# keep those rows
df <- df[c(index_NA, index_state),] 

# Remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "NMOSE", "UT", "WY")),]
df <- df[(df$state_scL %in% c("CA", "CO", "NM", "NMOSE", "UT", "WY", NA)),]
df$empty <- NA

# Export as CSV
write_csv(df, "www/df_subcomponent2.csv")


#---- 3. Partial Subcomponent ----#
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

# Submit query to get a dataframe
df <- submit_sparql(query,access_options=file)

# Assign NA to empty values
df[df == ""] <- NA

# Remove rows with components not having state name at the end "-__"
df <- df[grepl("-[A-Z]*", df$cL),]

# Remove rows where partial subcomponents do not have state name at the end
# get row number for which partial subcomponents are not NAs
index_NA <- which(is.na(df$pscL), arr.ind=TRUE)
# get row numbers for which partial subcomponents have a state at the end of their name
index_state <- which(grepl("-[A-Z]*", df$pscL), arr.ind=TRUE)
# keep those rows
df <- df[c(index_NA, index_state),] 

# Remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "UT", "WY")),]
df <- df[(df$state_pscL %in% c("CA", "CO", "NM", "UT", "WY", NA)),]
df$empty <- NA

# Export as CSV
write_csv(df, "www/df_partial_subcomponent2.csv")

# ---X--- #