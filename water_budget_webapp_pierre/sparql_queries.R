library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#library(rjson)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG_new.ttl", format="turtle")

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
    ?c wb:isExactMatch ?exm.
    ?exm rdfs:label ?exmL.
    }
}
"

results_component <- rdf_query(file, query_component)
df_component_full <- as.data.frame(results_component)
df_component_full <- arrange(df_component_full, jL, cL, fsourceL, fsinkL, ftypeL, scL, pscL, exmL)
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

# Data source tab
df_data_source <- select(df_state, -jL)
df_data_source <- df_data_source[,c(4,3,2,1)]
df_data_source$dsL <- gsub(",","", df_data_source$dsL)
write_csv(df_data_source, "www/df_data_source.csv")

# State tab
df_state <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
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
} "

res <- rdf_query(file, query)

# Exporting as dataframe
df <- as.data.frame(res)
df <- df[which(df$type == 'Component'),]
df <- arrange(df, cL, emL, pL, dsL) # each column in ascending order
df <- select(df, -type)
df$dsL <- gsub(",","", df$dsL)
write.table(df, file = "./www/hyperlink.csv", sep = ",",
            qmethod = "double", quote=FALSE, 
            row.name = FALSE)

##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

















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
} "

res <- rdf_query(file, query)

# Exporting as dataframe
df <- as.data.frame(res)
df <- df[which(df$type == 'Component'),]
df <- arrange(df, cL, emL, pL, dsL) # each column in ascending order
#df$cL <- gsub("-[A-Z][A-Z]","", df$cL)#remove state initials from components
#df <- df[which(df$jL == 'CO'),]
#df <- select(df, -jL)
df <- select(df, -type)
df$dsL <- gsub(",","", df$dsL)
df$dsL
#df_table <- cat(format_csv(df))
write.table(df, file = "./www/hyperlink.csv", sep = ",",
                        qmethod = "double", quote=FALSE, 
            row.name = FALSE)


#df_colorado <- # SORT by components
#write_csv(df, "water_budget_june8.csv")

################### WORK ON THIS
# treemap(
#   df,
#   index=c("jL", "cL", "emL", "pL", "dsL"),
#   vSize="population",
#   vColor="GNI",
#   type="value",
#   draw=FALSE
# ) %>%
#   {.$tm} %>%
#   select(continent,iso3,color,vSize) %>%
#   d3_nest(value_cols = c("color", "vSize"))

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
# Everything (excluding url)
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
df$cL <- gsub("-[A-Z][A-Z]","", df$cL)#remove state initials from components
df <- df[which(df$jL == 'CO'),]
#df <- select(df, -jL)
df <- select(df, -type)

nested_json <- d3_nest(data = df, root = "States");


#nested_json_colorado <- d3_nest(df_colorado, root = "CO")

write(nested_json, "./www/sample_json_v2.json")
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
  #  OPTIONAL {
    ?c wb:hasEstimationMethod ?em.
    ?em rdfs:label ?emL.
 #   }
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
    ?c wb:isExactMatch ?exm.
    ?exm rdfs:label ?exmL.
    }
}
"

res4 <- rdf_query(file, query4)

df4 <- as.data.frame(res4)

# properties_display <- c("Flow Source:", "Flow Sink:", "Flow Type:", 
 #                "Subcomponent:", "Partial Subcomponent:","Exact Match:")

# abc <- data.frame()
# 
# hello_list <- list()
# hello_list <- c(summary_flow_source, "summary_flow_sink", "summary_flow_type")
# 
# for (i in 1:length(properties_display)) {
#   assign(paste0("abc", "$", properties[i]), paste(paste(properties_display[i], 
#                                                       hello_list[1])))
# }
# 
# output$flow_source <- renderText(paste("Flow Source:", 
#                                        summary_flow_source))

# hello <- paste("Flow Sink:", summary_flow_sink)
# abc <- df4[which(df4$cL == 'Conveyance Seepage-CA'),]
# abc <- as.data.frame(abc)
# 
# flow_source <- c(unique(abc$fsourceL))
# subcomponent <- unique(abc$scL)
# 
# length <- length(subcomponent)
# for (n in subcomponent){
#   cat(paste(n, collapse=","))
# }
# cat(paste(subcomponent, collapse=", "))
# print(abc)
# length(unique(abc$scL))
# abc2 <- paste(c(unique(abc$scL)), collapse =", ")

# creating for loop for app
#abc

##cat(paste("summary", "title", sep="_"))
# abc <- df4[which(df4$cL == 'Conveyance Seepage-CA'),]
# properties <- c("flow_source", "flow_sink", "flow_type", "subcomponent", "p_subcomponent","exact_match")
#col_names <- c(fsourceL, "abc$fsinkL", "abc$ftypeL", "abc$scL", "abc$pscL", "abc$exmL")

# baba <- paste("summary", properties, sep="_")

# get(baba[3]) #it is looking for object, after removing quotes

# for (i in 1:length(properties)) {
   
#   baba[i] <- paste(unlist(unique(abc[i+2]), use.names = FALSE), collapse=", ") #i+2 because we dont want cL and jL
  #print (i)
# } 

# lhs <- paste("summary", properties, sep="_")
# rhs <- paste(abc[3:length(abc)])
# #rhs <- lapply(rhs, unique)
# eq   <- paste(paste(lhs, rhs, sep="<-"), collapse = ";")
# eval(parse(text=eq))

#a <- unlist(unique(abc[4+2]), use.names = FALSE)
# 
# component_info <- df1 %>%
#   filter(jL %in% "CA") %>%
#   filter(cL %in% "Conveyance Evaporation") %>%
#   select(3:length(df1))

# for (i in 1:length(properties)) {
#   cat(paste("summary", properties[i], sep="_")) 
#   if (i == 1){
#     break}
# } 
# 
# def <- abc[3:8]
# 
# for (i in 1:length(properties)) {
#   cat(paste(c(unique(abc[i+2])), collapse = ","))  
#   if (i == 1){
#     break}
# } 

# summary_title <- paste(input$components, input$states1, 
#                        sep = "-")
# summary_flow_source <- paste(c(unique(component_info$fsourceL)),
#                              collapse =", ")
# summary_flow_sink <- paste(c(unique(component_info$fsinkL)),
#                            collapse =", ")
# summary_flow_type <- paste(c(unique(component_info$ftypeL)),
#                            collapse =", ")
# summary_subcomponent <- paste(c(unique(component_info$scL)),
#                               collapse =", ")
# summary_p_subcomponent <- paste(c(unique(component_info$pscL)),
#                                 collapse =", ")
# summary_exact_match <- paste(c(unique(component_info$exmL)),
#                              collapse =", ")


# output$component_title <- renderText(input$components)
# 
# output$summary <- renderText({
#   
#   component_info <- df1 %>%
#     filter(jL %in% input$states1) %>%
#     filter(cL %in% input$components)
#   
#   print(component_info)
#   
#   flow_source <- c(unique(component_info$fsourceL))
#   flow_sink <- c(unique(component_info$fsinkL))
#   flow_type <- c(unique(component_info$ftypeL))
#   subcomponent <- c(unique(component_info$scL))
#   p_subcomponent <- c(unique(component_info$pscL))
#   exact_match <- c(unique(component_info$exmL))
#     
#   paste("Flow source:", flow_source,
#         "Flow sink:", flow_sink, 
#         "Flow type:", flow_type, 
#         "Sub-component of:", subcomponent, 
#         "Partial sub-component of:", p_subcomponent, 
#         "Exact match:", exact_match)
#   
# })

########## Testing hyperlink feature for search summary
abc_no_uri <- df4[which(df4$cL == 'Conveyance Evaporation-CA'),] %>%
  select(c(seq(3, length(colnames(df4)), 2)))

abc_w_uri <- df4[which(df4$cL == 'Conveyance Evaporation-CA'),] %>%
  select(-1, -2, -c(seq(3, 14, 2))) %>% #dropping jL, cL columns and retaining uri columns
  as.data.frame()

uri_title <- df4[which(df4$cL == 'Conveyance Evaporation-CA'),] %>%
  .$c

properties_display <- c("Flow Source:", "Flow Sink:", "Flow Type:", 
                        "Subcomponent:", "Partial Subcomponent:","Exact Match:")

properties <- c("flow_source", "flow_sink", "flow_type",
                "subcomponent", "p_subcomponent","exact_match")

summary_list <- paste("summary", properties, sep="_")

# assigning summary_list_flowstufffs (there are 5 total)
for (i in 1:length(properties)) {
  assign(paste(summary_list[i]), 
         paste(unlist(unique(abc_no_uri[i]), use.names = FALSE), collapse=", "))
} 

# Splitting multiple values in one property
for (i in 1:length(summary_list)){
  #split all characters
  split_property <- strsplit(get(summary_list[i]), "")[[1]]
  #check if there is a comma
  if ("," %in% split_property){
    #if ya then split by comma
    split_value <- unlist(strsplit(get(summary_list[i]), "[,]")) %>%
      trimws()
    
    cat(paste(properties_display[i],
              split_value[1], 
              split_value[2]))
    
  }
}

#### URI

uri_properties <- c("", "flow_source", "", "flow_sink", "", "flow_type",
              "", "subcomponent", "", "p_subcomponent", "", "exact_match")

uri_list <- paste("uri", uri_properties, sep="_")

for (i in seq(2,length(abc_w_uri), 2)) {
  assign(paste(uri_list[i]), 
         paste(unlist(unique(abc_w_uri[i]), use.names = FALSE), collapse=", "))
} 

# remove empty var
uri_list <- uri_list[-c(seq(1, length(uri_list), 2))]

for (i in 1:length(uri_list)) {
  split_uri_values <- strsplit(get(uri_list[i]), "")[[1]]
  if ("," %in% split_uri_values) {
    split_uri <- unlist(strsplit(get(uri_list[i]), "[,]")) %>%
      trimws()
    cat(paste(split_uri[1], 
              split_uri[2]))
  } 
}



####################### Reverse JSON ################################

query <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?dsL ?pL ?emL ?cL ?jL ?type WHERE {
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
df <- arrange(df, dsL, pL, emL, cL) # each column in ascending order
#df$cL <- gsub("-[A-Z][A-Z]","", df$cL)#remove state initials from components
df <- df[which(df$jL == 'CO'),]
#df <- select(df, -jL)
df <- select(df, -type, -jL)

nested_json <- d3_nest(data = df, root = "Data Source");
#nested_json_colorado <- d3_nest(df_colorado, root = "CO")
write(nested_json, "./www/sample_json_reverse.json")


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

