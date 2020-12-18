# Import packages
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)

# Load and parse TTL file from graphDB
file <- rdf_parse("graphDB2.ttl", format="turtle")

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

results_component <- rdf_query(file, query_component)
df_component_full <- as.data.frame(results_component)
df_component_full <- arrange(df_component_full, jL, cL, fsourceL, fsinkL, ftypeL, scL, pscL, exmL)
df_component_full$cL <- gsub("-NMOSE","-NM", df_component_full$cL)
df_component_full <- df_component_full[grep(".-CA|.-CO|.-NM|.-UT|.-WY", df_component_full$cL),] 
df_component_full$cL <- gsub("-[A-Z][A-Z]","", df_component_full$cL)
df_component_flow <- df_component_full[c(1,2,(seq(4,length(df_component_full), 2)))]
write_csv(df_component_full, "www/df_component_full.csv")
write_csv(df_component_flow, "www/df_component_flow.csv")

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
results <- rdf_query(file, query)
df <- as.data.frame(results)
# remove components usedBy river basins
df <- df[(df$state_cL %in% c("CA", "CO", "NM", "UT", "WY")),]
df <- df[(df$state_exmL %in% c("CA", "CO", "NM", "UT", "WY", NA)),]
df$empty <- NA
# check how will user input work in R shiny based on 
write_csv(df, "www/df_exact_match.csv")
# import the exported dataframe above ####################################NEW WAY######################
df2 <- read_csv("www/df_exact_match.csv")

choice1 <- c("Outflow", "Inflow", "Internal Transfer")
choice2 <- c("CO", "NM", "UT", "CA", "WY")
df <- df2 %>%
  #filter(ftype_cL %in% choice1) %>%
  #filter(ftype_exmL %in% choice1) %>%
  filter(state_cL %in% choice2) %>%
  filter(state_exmL %in% choice2) %>%
  as.data.frame()


######### Copy below code to RShiny to apply the following steps only to the state and flow info chosen by
######### the user.....
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$exmL <- gsub("-[A-Z]*","", df$exmL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_cL,"-", df$cL)
df$exmL <- paste0(df$state_exmL,"-", df$exmL)
# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
exact_match <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                          exmL = c(df[,"exmL"], df[,"cL"]),
                          state_2L = c(df[,"state_exmL"], df[,"state_cL"]),
                          key = c(df[,"exmL"], df[,"cL"]),
                          ftype = c(df[,"ftype_exmL"], df[,"ftype_cL"]),
                          fsource = c(df[,"fsource_exmL"], df[,"fsource_cL"]),
                          fsink = c(df[,"fsink_exmL"], df[,"fsink_cL"]),
                          uri = c(df[,"exm"], df[,"c"]))

# rename column names
# renaming cL as "imports" and scL as "names"
colnames(exact_match) <- c("imports", "name", "state", "key", "flow_type",
                           "flow_source", "flow_sink", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why
exact_match$name <- paste("a", 
                          exact_match$name, sep=". ")
exact_match$imports <- paste("a", 
                             exact_match$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "flow_type",
               "flow_source", "flow_sink", "uri")
exact_match <- exact_match[,col_order]
# alphabetical order
exact_match <- arrange(exact_match, state, name, key)
# storing subcomponents separated by comma for a componenet
# subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
exact_match_final <- exact_match %>%
  group_by(state, name, key, flow_type, flow_source, flow_sink, uri) %>%
  summarise(imports = paste0(imports, collapse = ","))

# Replace NAs with "" in imports column for later emptying in JS
exact_match_final$imports <- mapply(gsub, pattern='\\,a. NA\\b',
                                    replacement="", exact_match_final$imports )
exact_match_final$imports <- mapply(gsub, pattern='a. NA',
                                    replacement="", exact_match_final$imports )
exact_match_final$imports <- mapply(gsub, pattern='\\,a. NA,\\b',
                                    replacement="", exact_match_final$imports )
exact_match_final$imports <- mapply(gsub, pattern='\\a. NA,\\b',
                                    replacement="", exact_match_final$imports )
# Replace dot in "No." in component name to nothing, because d3 separates at dot and just shows 81
exact_match_final$name <- mapply(gsub, pattern='No.',
                                 replacement="No", exact_match_final$name )

# Drop NA-NA
clean <- exact_match_final[!(exact_match_final$name == "a. NA-NA"),]

# Export to csv 
# write_csv(abc, "www/df_exact_match.csv")


# Empty imports dont work in d3, so assigning imports same as name for ones that dont have imports
# abc$imports[abc$imports == ""] <- abc$name
# abc$imports <- with(abc, ifelse(imports == "", name, imports ) )

df_exact_matchJSON <- toJSON(clean)

write(df_exact_matchJSON, "www/df_exact_match.json")





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



# scraped this idea: For key names sending state abbreviations after names
# display_names <- c(df[,"scL"], df[,"cL"])
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$scL <- gsub("-[A-Z]*","", df$scL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_cL,"-", df$cL)
df$scL <- paste0(df$state_scL,"-", df$scL)

# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
subcomponent <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                           scL = c(df[,"scL"], df[,"cL"]),
                           state_scL = c(df[,"state_scL"], df[,"state_cL"]),
                           key = c(df[,"scL"], df[,"cL"]),
                           ftype = c(df[,"ftype_scL"], df[,"ftype_cL"]),
                           fsource = c(df[,"fsource_scL"], df[,"fsource_cL"]),
                           fsink = c(df[,"fsink_scL"], df[,"fsink_cL"]),
                           uri = c(df[,"sc"], df[,"c"]))

# rename column names
# renaming cL as "imports" and scL as "names"
colnames(subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                            "flow_source", "flow_sink", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why...
subcomponent$name <- paste("a", 
                           subcomponent$name, sep=". ")
subcomponent$imports <- paste("a", 
                              subcomponent$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "flow_type",
               "flow_source", "flow_sink", "uri")
subcomponent <- subcomponent[,col_order]
# alphabetical order
subcomponent <- arrange(subcomponent, state, name, key, uri)
# storing subcomponents separated by comma for a componenet
# subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
subcomponent_final <- subcomponent %>%
  group_by(state, name, key, flow_type, flow_source, flow_sink, uri) %>%
  summarise(imports = paste0(imports, collapse = ","))

# Replace NAs with "" in imports column for later emptying in JS
subcomponent_final$imports <- mapply(gsub, pattern='\\,a. NA\\b',
                                     replacement="", subcomponent_final$imports )
subcomponent_final$imports <- mapply(gsub, pattern='a. NA',
                                     replacement="", subcomponent_final$imports )
subcomponent_final$imports <- mapply(gsub, pattern='\\,a. NA,\\b',
                                     replacement="", subcomponent_final$imports )
subcomponent_final$imports <- mapply(gsub, pattern='\\a. NA,\\b',
                                     replacement="", subcomponent_final$imports )

# Replace dot in "No." in component name to nothing, because d3 separates at dot and just shows 81
subcomponent_final$name <- mapply(gsub, pattern='No.',
                                 replacement="No", subcomponent_final$name )

# Drop NA-NA
clean <- subcomponent_final[!(subcomponent_final$name == "a. NA-NA"),]

df_subcomponentJSON <- toJSON(clean)
write(df_subcomponentJSON, "www/df_subcomponent.json")




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



# scraped this idea: For key names sending state abbreviations after names
# display_names <- c(df[,"pscL"], df[,"cL"])
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$pscL <- gsub("-[A-Z]*","", df$pscL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_cL,"-", df$cL)
df$pscL <- paste0(df$state_pscL,"-", df$pscL)

# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
partial_subcomponent <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                           pscL = c(df[,"pscL"], df[,"cL"]),
                           state_pscL = c(df[,"state_pscL"], df[,"state_cL"]),
                           key = c(df[,"pscL"], df[,"cL"]),
                           ftype = c(df[,"ftype_pscL"], df[,"ftype_cL"]),
                           fsource = c(df[,"fsource_pscL"], df[,"fsource_cL"]),
                           fsink = c(df[,"fsink_pscL"], df[,"fsink_cL"]),
                           uri = c(df[,"psc"], df[,"c"]))

# rename column names
# renaming cL as "imports" and pscL as "names"
colnames(partial_subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                            "flow_source", "flow_sink", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why...
partial_subcomponent$name <- paste("a", 
                                   partial_subcomponent$name, sep=". ")
partial_subcomponent$imports <- paste("a", 
                                      partial_subcomponent$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "flow_type",
               "flow_source", "flow_sink", "uri")
partial_subcomponent <- partial_subcomponent[,col_order]
# alphabetical order
partial_subcomponent <- arrange(partial_subcomponent, state, name, key, uri)
# storing partial_subcomponents separated by comma for a componenet
# partial_subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
partial_subcomponent_final <- partial_subcomponent %>%
  group_by(state, name, key, flow_type, flow_source, flow_sink, uri) %>%
  summarise(imports = paste0(imports, collapse = ","))

# Replace NAs with "" in imports column for later emptying in JS
partial_subcomponent_final$imports <- mapply(gsub, pattern='\\,a. NA\\b',
                                     replacement="", partial_subcomponent_final$imports )
partial_subcomponent_final$imports <- mapply(gsub, pattern='a. NA',
                                     replacement="", partial_subcomponent_final$imports )
partial_subcomponent_final$imports <- mapply(gsub, pattern='\\,a. NA,\\b',
                                     replacement="", partial_subcomponent_final$imports )
partial_subcomponent_final$imports <- mapply(gsub, pattern='\\a. NA,\\b',
                                     replacement="", partial_subcomponent_final$imports )

# Replace dot in "No." in component name to nothing, because d3 separates at dot and just shows 81
partial_subcomponent_final$name <- mapply(gsub, pattern='No.',
                                  replacement="No", partial_subcomponent_final$name )

# Drop NA-NA
clean <- partial_subcomponent_final[!(partial_subcomponent_final$name == "a. NA-NA"),]

df_partial_subcomponentJSON <- toJSON(clean)
write(df_partial_subcomponentJSON, "www/df_partial_subcomponent.json")
