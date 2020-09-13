library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#library(rjson)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG_newer.ttl", format="turtle")

##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

# ---- 1. creating dataframe for flow and component-subcomponent info ---- #
query_component <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?c ?fsourceL ?fsource ?fsinkL ?fsink ?ftypeL ?ftype ?scL ?sc ?pscL ?psc ?exmL ?exm WHERE {
    ?c wb:usedBy ?j.
    ?j rdfs:label ?jL.
    ?c rdfs:label ?cL.
    
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
df_component_full <- df_component_full[grep(".-CA |.-CO|.-NMOSE|.-UT|.-WY", df_component_full$cL),] # exclude NM
df_component_full$cL <- gsub("-[A-Z][A-Z]","", df_component_full$cL)
df_component_flow <- df_component_full[c(1,2,(seq(4,length(df_component_full), 2)))]
write_csv(df_component_full, "www/df_component_full.csv")
write_csv(df_component_flow, "www/df_component_flow.csv")

# ---- 2. creating dataframe state-wise info ---- #
query_state <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
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
} HAVING (?type = 'Component')
" 

results_state <- rdf_query(file, query_state)
df_state <- as.data.frame(results_state) 
df_state <- select(df_state, -type)
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
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?j ?jL ?c ?cL ?em ?emL ?p ?pL ?ds ?dsL ?type WHERE {
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
} HAVING (?type = 'Component')
"

res <- rdf_query(file, query)

# Exporting as dataframe
df <- as.data.frame(res)
#df <- df[which(df$type == 'Component'),]
df <- arrange(df, cL, emL, pL, dsL) # each column in ascending order
df <- select(df, -type)
df$dsL <- gsub(",","", df$dsL)
write.table(df, file = "./www/hyperlink.csv", sep = ",",
            qmethod = "double", quote=FALSE, 
            row.name = FALSE)



##########################################################################################################################
##########################################################################################################################
##########################################################################################################################



#--- Exact Match ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?state_1L ?cL ?exmL ?state_2L ?c ?exm WHERE {
    ?c wb:usedBy ?state_1.
    ?state_1 rdfs:label ?state_1L.
    ?c rdfs:label ?cL.

    ?c skos:isExactMatch ?exm.
    ?exm rdfs:label ?exmL.
    ?exm wb:usedBy ?state_2.
    ?state_2 rdfs:label ?state_2L.
}
"
results <- rdf_query(file, query)
df <- as.data.frame(results)
df$empty <- NA
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$exmL <- gsub("-[A-Z]*","", df$exmL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_1L,"-", df$cL)
df$exmL <- paste0(df$state_2L,"-", df$exmL)

# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
exact_match <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                          exmL = c(df[,"exmL"], df[,"cL"]),
                          state_2L = c(df[,"state_2L"], df[,"state_1L"]),
                          key = c(df[,"exmL"], df[,"cL"]),
                          uri = c(df[,"exm"], df[,"c"]))

# rename column names
# renaming cL as "imports" and scL as "names"
colnames(exact_match) <- c("imports", "name", "state", "key", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why
exact_match$name <- paste("a", 
                          exact_match$name, sep=". ")
exact_match$imports <- paste("a", 
                             exact_match$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "uri")
exact_match <- exact_match[,col_order]
# alphabetical order
exact_match <- arrange(exact_match, state, name, key)
# storing subcomponents separated by comma for a componenet
# subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
exact_match_final <- exact_match %>%
  group_by(state, name, key, uri) %>%
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

# 


df_exact_matchJSON <- toJSON(exact_match_final)

write(df_exact_matchJSON, "www/df_exact_match.json")




#--- Subcomponent ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?state_1L ?cL ?scL ?state_2L ?c ?sc WHERE {
    ?c wb:usedBy ?state_1.
    ?state_1 rdfs:label ?state_1L.
    ?c rdfs:label ?cL.

    ?c wb:isSubComponentOf ?sc.
    ?sc rdfs:label ?scL.
    
    # the next two lines reduce observations by 4
    
    ?sc wb:usedBy ?state_2.
    ?state_2 rdfs:label ?state_2L.
}
"
results <- rdf_query(file, query)
df <- as.data.frame(results)
df$empty <- NA
# scraped this idea: For key names sending state abbreviations after names
# display_names <- c(df[,"scL"], df[,"cL"])
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$scL <- gsub("-[A-Z]*","", df$scL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_1L,"-", df$cL)
df$scL <- paste0(df$state_2L,"-", df$scL)

# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
subcomponent <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                           scL = c(df[,"scL"], df[,"cL"]),
                           state_2L = c(df[,"state_2L"], df[,"state_1L"]),
                           key = c(df[,"scL"], df[,"cL"]),
                           uri = c(df[,"sc"], df[,"c"]))

# rename column names
# renaming cL as "imports" and scL as "names"
colnames(subcomponent) <- c("imports", "name", "state", "key", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why
subcomponent$name <- paste("a", 
                           subcomponent$name, sep=". ")
subcomponent$imports <- paste("a", 
                              subcomponent$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "uri")
subcomponent <- subcomponent[,col_order]
# alphabetical order
subcomponent <- arrange(subcomponent, state, name, key, uri)
# storing subcomponents separated by comma for a componenet
# subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
subcomponent_final <- subcomponent %>%
  group_by(state, name, key, uri) %>%
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

# 


df_subcomponentJSON <- toJSON(subcomponent_final)
write(df_subcomponentJSON, "www/df_subcomponent.json")

# How to get all imports into single row separated by comma? By following:
# abc <- data.frame(a = c(1,1,1,2,2,2), b = c("a", "b", "c", "d", "e", "f")) %>% 
#   group_by(a) %>% 
#   summarise(b = paste(b, collapse = ","))






#--- Partial Subcomponent ---#
query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?state_1L ?cL ?pscL ?state_2L ?c ?psc WHERE {
    ?c wb:usedBy ?state_1.
    ?state_1 rdfs:label ?state_1L.
    ?c rdfs:label ?cL.

    ?c wb:isPartialSubComponentOf ?psc.
    ?psc rdfs:label ?pscL.
    
    ?psc wb:usedBy ?state_2.
    ?state_2 rdfs:label ?state_2L.
    
}
"
results <- rdf_query(file, query)
df <- as.data.frame(results)
df$empty <- NA
# scraped this idea: For key names sending state abbreviations after names
# display_names <- c(df[,"scL"], df[,"cL"])
# Removing state abbreviations to put them before names in next steps (for d3 sorting)
df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
df$pscL <- gsub("-[A-Z]*","", df$pscL)
# Putting state abbreviations before the name so that d3 sorts by state
df$cL <- paste0(df$state_1L,"-", df$cL)
df$pscL <- paste0(df$state_2L,"-", df$pscL)

# putting all components and states in 1 column
# adding a column of "key" for d3 edge bundling
# Keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
partial_subcomponent <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                           scL = c(df[,"pscL"], df[,"cL"]),
                           state_2L = c(df[,"state_2L"], df[,"state_1L"]),
                           key = c(df[,"pscL"], df[,"cL"]),
                           uri = c(df[,"psc"], df[,"c"]))

# rename column names
# renaming cL as "imports" and scL as "names"
colnames(partial_subcomponent) <- c("imports", "name", "state", "key", "uri")

#add "a." in all names to work with d3 edge bundling (bilink function)
#dont ask why
partial_subcomponent$name <- paste("a", 
                                   partial_subcomponent$name, sep=". ")
partial_subcomponent$imports <- paste("a", 
                                      partial_subcomponent$imports, sep=". ")

# rearrange columns
col_order <- c("state","name","key","imports", "uri")
partial_subcomponent <- partial_subcomponent[,col_order]
# alphabetical order
partial_subcomponent <- arrange(partial_subcomponent, state, name, key, uri)
# storing subcomponents separated by comma for a componenet
# subcomponent_final <- aggregate(imports~name, data=subcomponent, paste, sep=",")
partial_subcomponent_final <- partial_subcomponent %>%
  group_by(state, name, key, uri) %>%
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

# 


df_partial_subcomponentJSON <- toJSON(partial_subcomponent_final)
write(df_partial_subcomponentJSON, "www/df_partial_subcomponent.json")



