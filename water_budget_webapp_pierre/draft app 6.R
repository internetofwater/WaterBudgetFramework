library(shiny)
library(shinyjs)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)

file <- rdf_parse("qrUilGBx2x8YZBCY6iSVG.ttl", format="turtle")

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
df_state <- arrange(df_state, jL, cL, emL, pL, dsL) # each column in ascending alphabetical order
df_state$cL <- gsub("-[A-Z][A-Z]","", df_state$cL) # remove state initials from components



#drop-down choices
state_choices <- c("CA","CO","NM","UT")
component_choices <- c(unique(df_component_full$cL))

# Shiny app
ui <- fluidPage(id = "page", theme = "styles.css",
    useShinyjs(),
    tags$head(tags$link(href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&display=swap",
                        rel="stylesheet"),
              tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
              tags$script(src = "https://d3js.org/d3.v5.min.js"),
              tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.10.2/underscore.js"),
              tags$script(src = "index_v8.js")),
    tags$body(HTML('<link rel="shortcut icon", href="favicon.png",
                       type="image/png" />')), # add logo in the tab
    tags$div(class = "header",
             tags$a(href="https://internetofwater.org/", target = "_blank", 
                    tags$img(src = "iow_logo.png", width = 60)),
             tags$h1("IoW Water Budget Tool"),
             titlePanel(title="", windowTitle = "IoW Water Budget App")),
    navbarPage(title = "",
               selected = "Home",
               theme = "styles.css",
               fluid = TRUE,

# ------ Tab - Home ------ #
      tabPanel(title = "Home",
        tags$div(class = "home-banner",
                 tags$img(class = "home-banner-img",
                          src = "image_2.jpg"),
                 tags$div(class = "banner-text",
                          tags$p(class = "h1", "WELCOME")),
                 tags$div(class = "scrolldown",
                          tags$span(),
                          tags$span(),
                          tags$span())
                 ),
        tags$div(class = "instruction",
                 tags$div(class = "text-area",
                          tags$h1("What is IoW Water Budget Tool?"),
                          tags$br(), tags$br(),
                          tags$p("bla bla stuff")
                          )
                 )),

      
# ------ Tab - Component - Begin ------ # 
      tabPanel(title = "Component",
        tags$div(class = "banner", 
                 tags$img(class = "banner-img-component",
                          src = "image_1.jpg"),
                 tags$div(class = "banner-text",
                          tags$p(class = "h1", "Search by component"),
                          tags$p(class = "h3", "Explore the profile of a water budget component")
                          )),
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
        tags$body(hidden(
                  tags$div(id = "component_summary",
                           style = "color:#777777",
                           tags$h3(tags$b(htmlOutput("component_title"))),
                           tags$p(htmlOutput("flow_source")),
                           tags$p(htmlOutput("flow_sink")),
                           tags$p(htmlOutput("flow_type")),
                           tags$p(htmlOutput("subcomponent")),
                           tags$p(htmlOutput("p_subcomponent")),
                           tags$p(htmlOutput("exact_match")),
                           tags$p(style = "font-size: 85%",
                                  tags$i("Estimation methods, 
                                         parameters and data sources 
                                         are presented below"))
                           )),
                  tags$div(id = "component_container"))
      ),
# ------ Tab - Component - End ------ #
      
# ------ Tab - State - Begin ------ #
      tabPanel(title = "State",
        tags$div(class = "banner", 
                 tags$img(class = "banner-img-state",
                          src = "image_3.jpg"),
                 tags$div(class = "banner-text",
                          tags$p(class = "h1", "Search by state"),
                          tags$p(class = "h3", "Explore the water budget framework of a state")
                        )),
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
# ------- Tab - State - End ------- #

    tabPanel(title = "Interstate"),
    navbarMenu(title = "About",
               tabPanel(title = "Other stuff"))
  ))

server <- function(input, output, session){
  
# Update component choices based on states you select
  observe({
    choices_components <- df_state %>%
      filter(jL %in% input$states1)
    choices_components <- c(unique(choices_components$cL))
    
    updateSelectInput(session, "components",
                      choices = choices_components)
  })
  
# Summary of component on Component tab
  observeEvent(input$runButton1, {
    # Show summary div
    show("component_summary")
    
    # Summary URIs
    df_uri <- df_component_full %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      select(-c(1,2,3,4,6,8,10,12,14)) %>% #dropping jL, cL, c columns and retaining uri columns
      as.data.frame()
    
    # Extracting component (title) URI
    uri_title <- df_component_full %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      .$c # selecting component
    
    uri_title <- uri_title[1]
    
    #Summary information 
    component_info <- df_component_flow %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      select(3:length(df_component_flow)) %>% #dropping jL, cL columns 
      as.data.frame()
    
    # URIs
    uri_properties <- c("flow_source", "flow_sink", "flow_type",
                        "subcomponent", "p_subcomponent", "exact_match")
    
    uri_list <- paste("uri", uri_properties, sep="_")
    
    # SUMMARY
    # Property names based on textOutput
    summary_properties <- c("flow_source", "flow_sink", "flow_type",
                    "subcomponent", "p_subcomponent","exact_match")
    
    # Create intermediary objects to hold unique strings from dataframe "component_info"
    # multiple values for a property are separated by commas
    summary_title <- paste(input$components, input$states1, 
                           sep = "-")
    summary_list <- paste("summary", summary_properties, sep="_")
    
    for (i in 1:length(summary_properties)) {
      assign(paste(summary_list[i]), 
             paste(unlist(unique(component_info[i]), use.names = FALSE), collapse=", "))
      
      assign(paste(uri_list[i]), 
             paste(unlist(unique(df_uri[i]), use.names = FALSE), collapse=", "))
    }
    
    # Render output
    output$component_title <- renderText(paste('<a href="', uri_title,
                                               '" target="_blank">',
                                               summary_title, '</a>'))
    properties_display <- c("Flow Source:", "Flow Sink:", "Flow Type:",
                     "Subcomponent of:", "Partial Subcomponent of:","Exact Match:")
    
    # if an attribute has multiple values, it would add 1 hyperlink
    # to all values
    # so first we split each character in a string and see if it has a comma
    # if it does then we assign split it by comma and store each value as a list in
    # a signle variable
    # then we run two different render options depending if a field has  a
    # single value or multiple value
    lapply(1:length(summary_list), function(i){
      split_property <- strsplit(get(summary_list[i]), "")[[1]]
      if ("," %in% split_property){
        split_value <- unlist(strsplit(get(summary_list[i]), "[,]")) %>%
          trimws()
        split_uri <- unlist(strsplit(get(uri_list[i]), "[,]")) %>%
          trimws()
        output[[summary_properties[i]]] <- renderText(paste("<b>", properties_display[i], "</b>",
                                              '<a href="', split_uri[1],'" target="_blank">',
                                              split_value[1], "</a>", 
                                              '<a href="', split_uri[2], '" target="_blank">',
                                              ",",
                                              split_value[2], "</a>"))
      }else if (get(summary_list[i]) == "NA") {
        output[[summary_properties[i]]] <- renderText(paste("<b>", properties_display[i], "</b>",
                                                    get(summary_list[i])))
      }else {
         output[[summary_properties[i]]] <- renderText(paste("<b>", properties_display[i], "</b>",
                                                    '<a href="', get(uri_list[i]),'" target="_blank">',
                                                    get(summary_list[i]), "</a>"))
      }
    })
    
    # lapply(1:length(properties_display), function(i){ 
    #   output[[properties[i]]] <- renderText(paste("<b>", properties_display[i], "</b>",
    #                                               '<a href=', uri_link,'target="_blank">',
    #                                               get(summary_list[i]), "</a>"))
#    }) #FOR loop cannot be used with render options

})

# Chart by component on Component tab
  observeEvent(input$runButton1,{
    selection_df_1 <- df_state %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      as.data.frame()
    selection_df_1 <- select(selection_df_1, -jL, -cL)
    selection_json_1 <- d3_nest(data = selection_df_1, root = "")
    leaf_nodes_1 <- nrow(selection_df_1)
    session$sendCustomMessage(type = "component_height", leaf_nodes_1)
    session$sendCustomMessage(type = "component_json", selection_json_1)
  })
  
# State charts on State tabs
  observeEvent(input$runButton2, {
    selection_df_2 <- df_state %>%
      filter(jL %in% input$states2) %>%
      as.data.frame()
    selection_df_2 <- select(selection_df_2, -jL)
    selection_json_2 <- d3_nest(data = selection_df_2, root = input$states2)
    leaf_nodes_2 <- nrow(selection_df_2)
    session$sendCustomMessage(type = "state_height", leaf_nodes_2)
    session$sendCustomMessage(type = "state_json", selection_json_2)
  })
}


shinyApp(ui = ui, server = server) 