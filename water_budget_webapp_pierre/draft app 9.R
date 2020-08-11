library(shiny)
library(shinyjs)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#library(htmlwidgets)

# ---- 1. Loading data for flow and component-subcomponent info ---- #
df_component_full <- read_csv("www/df_component_full.csv") # dataframe for component summary
df_component_flow <- read_csv("www/df_component_flow.csv") # dataframe for component summary
df_component <- read_csv("www/df_component.csv") # dataframe for d3 chart on component tab

# ---- 2. Loading dataframe state-wise info ---- #
df_data_source <- read_csv("www/df_data_source.csv") # dataframe for d3 chart on data source tab
df_state <- read_csv("www/df_state.csv") # dataframe for d3 chart on state tab


#drop-down choices
state_choices <- c("CO","NM","UT","WY") # later change it to unique values from dataframe
component_choices <- c(unique(df_component_full$cL))
data_source_choices <- c(unique(df_state$dsL))
data_source_choices <- sort(data_source_choices[-1]) # remove NA & reorder

#home tab chart
# home_d3 <- fromJSON("www/home_chart.json")
# home_d3_df <- lapply(home_d3, function(a) # Loop through each "play"
# {
#   data.frame(matrix(unlist(a), ncol=5, byrow=TRUE))
# })


# Shiny app
ui <- fluidPage(id = "page", theme = "styles.css",
    useShinyjs(),
    #includeScript("www/index_home_test.js"),
    tags$head(tags$link(href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&display=swap",
                        rel="stylesheet"),
              tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
              tags$script(src = "https://d3js.org/d3.v5.min.js"),
              tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.10.2/underscore.js"),
              tags$script(src = "index_v8.js"),
              #tags$script(type="text/javascript", src = "index_home_chart.js")
             # tags$script(JS('drawChart()'))
              ),
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
        tags$div(class = "instruction-1",
                 tags$div(class = "text-area",
                          tags$h1("What is IoW Water Budget Tool?"),
                          tags$br(),
                          tags$h3("IoW Water Budget Tool is a web application that allows users to explore water budget frameworks
                                 across the United States. A state's water budget framework primarily consists of a jurisdiction, components,
                                 estimation methods, parameters and data sources. The components have additional properties describing
                                  flow information and relationship with other components within and across states."),
                          tags$br()
                          ),
                 tags$div(id = "home_container",
                          tags$img(src = "home_d3.svg")),
                 tags$br(),
                 tags$div(class = "text-area",
                          tags$h3("More coming soon..."))
                 ),
          ),
        

      
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

# ------ Tab - Data Sources (reverse chart) - Begin ------ #
        tabPanel(title = "Data Source",
                 tags$div(class = "banner", 
                          tags$img(class = "banner-img-state",
                                   src = "image_4.jpg"),
                          tags$div(class = "banner-text",
                                   tags$p(class = "h1", "Search by data source"),
                                   tags$p(class = "h3", "Explore the estimation methods and components used by a data source")
                          )),
                 column(width = 12,
                        column(width = 3,
                               selectInput(inputId = "data_source",
                                           label = "Select data source",
                                           selected = data_source_choices[2],
                                           choices = data_source_choices)), 
                        column(width = 2, 
                               actionButton(inputId = "runButton3", 
                                            label = "",
                                            icon = icon("check"))
                        )),
                 tags$body(tags$div(id = "data_source_sticky"),
                           tags$div(id = "data_source_container"))
        ),
# ------- Tab - Data Sources (reverse chart) - End ------- #

    tabPanel(title = "Interstate"),
    navbarMenu(title = "About",
               tabPanel(title = "Other stuff"))
  ))


server <- function(input, output, session){
  
# Home tab - send random custom message to communicate with d3 (instead saved as png)
  # runjs('
  #       var home_chart = document.createElement("script");
  #       home_chart.src = "index_home_chart.js";
  #       document.head.appendChild(home_chart)
  #       ')
  
  
# Update component choices based on states you select
  observe({
    choices_components <- df_component %>%
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
    if (input$states1 == "NM"){
      summary_title <- paste(input$components, input$states1, 
                             sep = "-")
      summary_title <- paste0(summary_title, "OSE")
    } else {
      summary_title <- paste(input$components, input$states1, 
                             sep = "-")
    }
    
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
})

# Chart by component on Component tab
  observeEvent(input$runButton1, 
               autoDestroy = FALSE, {
    selection_df_1 <- df_component %>%
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
  
# Data source chart
  observeEvent(input$runButton3, {
    selection_df_3 <- df_data_source %>%
      filter(dsL %in% input$data_source) %>%
      as.data.frame()
    selection_df_3 <- select(selection_df_3, -dsL)
    selection_json_3 <- d3_nest(data = selection_df_3, root = input$data_source)
    leaf_nodes_3 <- nrow(selection_df_3)
    session$sendCustomMessage(type = "data_source_height", leaf_nodes_3)
    session$sendCustomMessage(type = "data_source_json", selection_json_3)
  })
}


shinyApp(ui = ui, server = server) 