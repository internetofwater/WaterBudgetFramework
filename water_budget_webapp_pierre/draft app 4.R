library(shiny)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG.ttl", format="turtle")

# ---- 1. creating dataframe for search by component ---- #
query1 <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX : <http://webprotege.stanford.edu/project/qrUilGBx2x8YZBCY6iSVG#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?jL ?cL ?fsourceL ?fsinkL ?ftypeL ?scL ?pscL ?exmL WHERE {
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

results1 <- rdf_query(file, query1)
df1 <- as.data.frame(results1)
df1 <- arrange(df1, jL, cL, fsourceL, fsinkL, ftypeL, scL, pscL, exmL)
df1$cL <- gsub("-[A-Z][A-Z]","", df1$cL)


# ---- 2. creating dataframe state-wise info ---- #
query2 <- "PREFIX wb: <http://purl.org/iow/WaterBudgetingFramework#>
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

results2 <- rdf_query(file, query2)
df2 <- as.data.frame(results2) 
#df2 <- df2[which(df2$type == 'Component'),]# remove rows that have "type" other than "components"
#used SPARQL for selecting type as components
df2 <- select(df2, -type)
df2 <- arrange(df2, jL, cL, emL, pL, dsL)# each column in ascending order
df2$cL <- gsub("-[A-Z][A-Z]","", df2$cL)#remove state initials from components



#drop-down choices
state_choices <- c("CA","CO","NM","UT")
component_choices <- c(unique(df1$cL))

ui <- fluidPage(id = "page", theme = "styles.css",
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
              tags$script(src = "https://d3js.org/d3.v5.min.js"),
              tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.10.2/underscore.js"),
              tags$script(src = "index_v7.js")),
    tags$body(HTML('<link rel="icon", href="favicon.png",
                       type="image/png" />')), # add logo in the tab
    tags$div(class = "header",
             tags$img(src = "iow_logo.png", width = 75),
             tags$h1("US Water Budget App"),
             titlePanel(title="", windowTitle = "IoW Water Budget App")),
    navbarPage(title = "",
               selected = "Home",
               theme = "styles.css",
               fluid = TRUE,
      tabPanel(title = "Home"),
      
# ------ Tab - Search - Begin ------ # 
      tabPanel(title = "Search",
        column(width = 12,
          column(width = 3,
                 selectInput(inputId = "states1",
                             label = "Select state", 
                             choices = state_choices)),
          column(width = 3,
                 selectInput(inputId = "components",
                             label = "Select component",
                             choices = component_choices)),
          column(width = 2,
                 actionButton(inputId = "runButton1",
                              label = "",
                              icon = icon("check"))
                 )),
        tags$body(tags$div(id = "search_summary", 
                           tags$h3(textOutput("component_title")), 
                           tags$p(textOutput("flow_source")),
                           tags$p(textOutput("flow_sink")),
                           tags$p(textOutput("flow_type")),
                           tags$p(textOutput("subcomponent")),
                           tags$p(textOutput("p_subcomponent")),
                           tags$p(textOutput("exact_match"))
                           ),
                  tags$div(id = "search_container"))
      ),
# ------ Tab - Search - End ------ #
      
# ------ Tab - State - Begin ------ #
      tabPanel(title = "State",
        column(width = 12,
          column(width = 3,
                 selectInput(inputId = "states2",
                             label = "Select state",
                             choices = state_choices)), #defined above UI
          column(width = 2, 
               actionButton(inputId = "runButton2", 
                            label = "",
                            icon = icon("check"))
               )),
        tags$body(tags$div(id = "state_sticky"),
                  tags$div(id = "state_container"))
    ),
# ------- Tab - Intrastate - End ------- #

    tabPanel(title = "Interstate"),
    navbarMenu(title = "About",
               tabPanel(title = "Other stuff"))
  ))

server <- function(input, output, session){
  
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
  
  
# Update component choices based on states you select
  observe({
    choices_components <- df2 %>%
      filter(jL %in% input$states1)
    choices_components <- c(unique(choices_components$cL))
    
    updateSelectInput(session, "components",
                      choices = choices_components)
  })
  
# Summary of component
  observeEvent(input$runButton1, {
    #Summary 
    component_info <- df1 %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      select(3:length(df1)) %>%
      as.data.frame()
    # Property names based on UI textOutput
    properties <- c("flow_source", "flow_sink", "flow_type",
                    "subcomponent", "p_subcomponent","exact_match")
    
    # Create intermediary objects to hold unique strings from dataframe "component_info"
    # multiple values for a property are separated by commas
    summary_title <- paste(input$components, input$states1, 
                           sep = "-")
    summary_list <- paste("summary", properties, sep="_")
    for (i in 1:length(properties)) {
      assign(paste(summary_list[i]), 
             paste(unlist(unique(component_info[i]), use.names = FALSE), collapse=", "))
    } 
    
    # Render output
    output$component_title <- renderText(paste(summary_title))
    properties_display <- c("Flow Source:", "Flow Sink:", "Flow Type:",
                     "Subcomponent:", "Partial Subcomponent:","Exact Match:")
    lapply(1:length(properties_display), function(i){ 
      output[[properties[i]]] <- renderText(paste(properties_display[i], get(summary_list[i])))
    }) #FOR loop cannot be used
  })
    
  observeEvent(input$runButton1,{
    selection_df_1 <- df2 %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      as.data.frame()
    selection_df_1 <- select(selection_df_1, -jL, -cL)
    selection_json_1 <- d3_nest(data = selection_df_1, root = "")
    leaf_nodes_1 <- nrow(selection_df_1)
    session$sendCustomMessage(type = "search_height", leaf_nodes_1)
    session$sendCustomMessage(type = "json", selection_json_1)
  })
  
  observeEvent(input$runButton2, {
    selection_df_2 <- df2 %>%
      filter(jL %in% input$states2) %>%
      as.data.frame()
    selection_df_2 <- select(selection_df_2, -jL)
    selection_json_2 <- d3_nest(data = selection_df_2, root = input$states2)
    leaf_nodes_2 <- nrow(selection_df_2)
    session$sendCustomMessage(type = "canvas_height", leaf_nodes_2)
    session$sendCustomMessage(type = "nested_json", selection_json_2)
  })
}


shinyApp(ui = ui, server = server) 