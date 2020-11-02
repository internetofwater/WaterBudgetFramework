library(shiny)
library(shinyjs)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)
#library(htmlwidgets)

# ---- 1. Loading data for flow and component-subcomponent info ---- #
df_component_full <- read_csv("www/df_component_full.csv") # dataframe for component summary (including URIs)
df_component_flow <- read_csv("www/df_component_flow.csv") # dataframe for component summary
df_component <- read_csv("www/df_component.csv") # dataframe for d3 chart on component tab

# ---- 2. Loading dataframe state-wise info ---- #
df_data_source <- read_csv("www/df_data_source.csv") # dataframe for d3 chart on data source tab
df_state <- read_csv("www/df_state.csv") # dataframe for d3 chart on state tab

# ---- 3. Loading dataframe for interstate tab ---- #
#df_exact_match <- read_csv("www/exact_match_test.csv") 
# Not required, choice is sent to JS where relevant csv is read and used for D3

# ---- 4. Importing dataframe for Interstate v2 tab --- #
df_exact_match <- read_csv("www/df_exact_match_v2.csv")
df_subcomponent <- read_csv("www/df_subcomponent_v2.csv")
df_partial_subcomponent <- read_csv("www/df_partial_subcomponent_v2.csv")

#drop-down choices
state_choices <- c("CA","CO","NM","UT","WY") # later change it to unique values from dataframe
component_choices <- c(unique(df_component_full$cL))
data_source_choices <- c(unique(df_state$dsL))
data_source_choices <- sort(data_source_choices[-1]) # remove NA & reorder
interstate_choices <- c("Exact Match", "Subcomponent", "Partial Subcomponent")
interstate_state_choices <- c("SELECT ALL", "CLEAR ALL", "CA","CO","NM","UT","WY")
# following choices do not really matter because they will subset based on state choices
flow_type_choices <- c("All", "Inflow", "Internal Transfer", "Outflow", "Storage Change")
flow_source_choices <- c("All", unique(df_exact_match$fsource_cL))
flow_sink_choices <- c("All", "hello")

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
              #tags$script(src = "https://d3js.org/d3.v6.min.js"),
              tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.10.2/underscore.js"),
              tags$script(src = "index_v8.js"),
              #tags$script(src = "interstate.js"),
              #tags$script(src = "interstate_exact_match.js"),
              tags$script(src = "interstate_exact_match_v2.js"),
              #tags$script(src = "interstate_subcomponent.js"),
              tags$script(src = "interstate_subcomponent_v2.js"),
              #tags$script(src = "interstate_partial_subcomponent.js"),
              tags$script(src = "interstate_partial_subcomponent_v2.js")
              #tags$script(type="text/javascript", src = "index_home_chart.js")
             # tags$script(JS('drawChart()'))
              ),
    tags$body(HTML('<link rel="shortcut icon", href="favicon.png",
                       type="image/png" />')), # add logo in the tab
    tags$div(class = "header",
             tags$a(href="https://internetofwater.org/", target = "_blank", 
                    tags$img(src = "iow_logo.png", width = 60)),
             tags$h1("Water Budget Navigator"),
             titlePanel(title="", windowTitle = "IoW Water Budget App")),
    navbarPage(title = "",
               selected = "Home",
               theme = "styles.css",
               fluid = TRUE,

# ------ Tab - Home - Begin ------ #
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
        tags$b("DISCLAIMER: This application is currently in the development stage. 
               All the data is provisional and subject to change. This tool best performs on Google Chrome 
               but is also functional on Mozilla Firefox and Safari.",
               style = "color: salmon; font-size: 120%; text-align: center;"),
        tags$div(class = "instruction-1",
                 tags$div(class = "text-area",
                          tags$h1("What is IoW's Water Budget Navigator?"),
                          tags$br(),
                          tags$h3("Water Budget Navigator is a web application that allows users to explore water budget frameworks
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
# ------ Tab - Home - End ------ #

      
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


# ------- Tab - Interstate - Begin ------- #
        tabPanel(title = "Interstate",
                 tags$div(class = "banner", 
                          tags$img(class = "banner-img-state",
                                   src = "image_7.jpg"),
                          tags$div(class = "banner-text",
                                   tags$p(class = "h1", "Search interstate relationships"),
                                   tags$p(class = "h3", "Explore the relationship among water budget components 
                                          within and among states")
                          )),
                 column(width = 12,
                        column(width = 3,
                               selectInput(inputId = "interstate",
                                           label = "Select relationship",
                                           choices = interstate_choices)), #defined above UI
                        column(width = 3,
                               selectInput(inputId = "interstate_states",
                                           label = "Select states",
                                           choices = interstate_state_choices,
                                           multiple = TRUE,
                                           selected = "All")),
                        column(width = 2, 
                               actionButton(inputId = "runButton4", 
                                            label = "",
                                            icon = icon("check"))
                        )),
                 tags$body(tags$div(id = "interstate_container"))
                 ),
# ------- Tab - Interstate - End ------- #


# ------- Tab - Interstate v2 - Begin ------- #
                tabPanel(title = "Interstate 2",
                         tags$div(class = "banner", 
                                  tags$img(class = "banner-img-state",
                                           src = "image_7.jpg"),
                                  tags$div(class = "banner-text",
                                           tags$p(class = "h1", "Search interstate relationships"),
                                           tags$p(class = "h3", "Explore the relationships among water budget components 
                                                          within and among states")
                                  )),
                         column(width = 12, 
                                column(width = 12,
                                       tags$b("See All Components", style = "font-size: 130%"),
                                       tags$p(" "),
                                       tags$p("1. Choose the type of interstate relationship among water budget components"),
                                       tags$p('2. Click on the button to include components with no relationships as well')
                                       )
                         ),
                         column(width = 12,
                                column(width = 3,
                                       selectInput(inputId = "interstate2",
                                                   label = "Select interstate relationship",
                                                   choices = interstate_choices)),
                                column(width = 2,
                                       actionButton(inputId = "runButton4.1",
                                                    label = "",
                                                    icon = icon("check")
                                       ))
                                ), #defined above UI
                         
                         column(width = 12, 
                                column(width = 12,
                                       tags$b("See Selected Components", style = "font-size: 130%"),
                                       tags$p(" "),
                                       tags$p('1. Choose "SELECT ALL" and "CLEAR ALL" to select and clear all choices in the fields below'),
                                       tags$p('2. Select the states of interest'),
                                       tags$p('3. Filter the components by flow type, flow source and flow sink'),
                                       tags$p('4. Click on the button to see the relationships of selected components')
                                       )
                                ),
                         column(width = 12,
                                column(width = 3,
                                       selectInput(inputId = "interstate_states2",
                                                   label = "Select states",
                                                   choices = interstate_state_choices,
                                                   multiple = TRUE,
                                                   selected = "SELECT ALL")),
                                column(width = 3,
                                       selectInput(inputId = "interstate_flowType",
                                                   label = "Select flow type", 
                                                   choices = flow_type_choices, 
                                                   multiple = TRUE,
                                                   selected = "All"))
                                ),
                         column(width = 12,
                                column(width = 3,
                                       selectInput(inputId = "interstate_flowSource",
                                                   label = "Select flow source",
                                                   choices = flow_source_choices,
                                                   multiple = TRUE,
                                                   selected = "All")), 
                                column(width = 3,
                                       selectInput(inputId = "interstate_flowSink",
                                                   label = "Select flow sink",
                                                   choices = flow_sink_choices,
                                                   multiple = TRUE,
                                                   selected = "All")),
                                column(width = 2, 
                                       actionButton(inputId = "runButton4.2", 
                                                    label = "",
                                                    icon = icon("check")))
                                ),
                         tags$body(tags$div(id = "interstate_container2"))
),
# ------- Tab - Interstate v2 - End ------- #


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
  
  # Interstate relationship select states
  # Interstate v1
  observe({
    if("All" %in% input$interstate_states)
      selected_choices = interstate_state_choices[-1] #choose all the choices except "All"
    else
      selected_choices = input$interstate_states
    updateSelectInput(session, "interstate_states", selected = selected_choices)
  })
  
  # Interstate v2
  # Update choices
  observe({
    
    #--- State choices ---#
    if("SELECT ALL" %in% input$interstate_states2)
      selected_choices2 = interstate_state_choices[c(-1, -2)] #choose all the choices except "All"
    else if("CLEAR ALL" %in% input$interstate_states2)
      selected_choices2 = ""
    else
      selected_choices2 = input$interstate_states2
    updateSelectInput(session, "interstate_states2", selected = selected_choices2)
    
    # Update flow choices based on Exact Match, Subcomponent or Partial Subcomponent input
    if (input$interstate2 == "Exact Match"){
      
      #--- Flow Type choices ---#
      # Updating flow choices based on states selected
      selected_flowType <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_exmL))
      selected_flowType_default <- selected_flowType
      
      # if you select "All" it will add all flow types (it doesnt :()
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
      } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
      } else {
        selected_flowType_default = input$interstate_flowType
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      selected_flowSource <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) %>%
        filter(ftype_exmL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_exmL))
      
      # if you select "All" it will add all flow sources
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
      } else {
        selected_flowSource_default = input$interstate_flowSource
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      selected_flowSink <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) %>%
        filter(ftype_exmL %in% input$interstate_flowType) %>%
        filter(fsource_exmL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_exmL))
      
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
      } else{
        selected_flowSink_default = input$interstate_flowSink
      }
      # Update choices
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
    
    } else if (input$interstate2 == "Subcomponent"){
      
      #--- Flow Type choices ---#
      # Updating flow choices based on states selected
      selected_flowType <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_scL))
      selected_flowType_default <- selected_flowType
      
      # if you select "All" it will add all flow types (it doesnt :()
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
      } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
      } else {
        selected_flowType_default = input$interstate_flowType
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      selected_flowSource <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) %>%
        filter(ftype_scL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_scL))
      
      # if you select "All" it will add all flow sources
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
      } else {
        selected_flowSource_default = input$interstate_flowSource
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      selected_flowSink <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) %>%
        filter(ftype_scL %in% input$interstate_flowType) %>%
        filter(fsource_scL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_scL))
      
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
      } else{
        selected_flowSink_default = input$interstate_flowSink
      }
      # Update choices
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
      
    } else if (input$interstate2 == "Partial Subcomponent"){
      
      #--- Flow Type choices ---#
      # Updating flow choices based on states selected
      selected_flowType <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_pscL))
      selected_flowType_default <- selected_flowType
      
      # if you select "All" it will add all flow types (it doesnt :()
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
      } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
      } else {
        selected_flowType_default = input$interstate_flowType
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      selected_flowSource <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) %>%
        filter(ftype_pscL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_pscL))
      
      # if you select "All" it will add all flow sources
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
      } else {
        selected_flowSource_default = input$interstate_flowSource
      }
      
      # Update choices
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      selected_flowSink <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) %>%
        filter(ftype_pscL %in% input$interstate_flowType) %>%
        filter(fsource_pscL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_pscL))
      
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
      } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
      } else{
        selected_flowSink_default = input$interstate_flowSink
      }
      # Update choices
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
    }
    
    
  })
  
  # Interstate relationship chart
  # Interstate v1
  observeEvent(input$runButton4, {
      interstate_relationship <- input$interstate
      if (interstate_relationship == "Exact Match"){
        session$sendCustomMessage(type = "exact_match", interstate_relationship)
      } else if (interstate_relationship == "Subcomponent") {
        session$sendCustomMessage(type = "subcomponent", interstate_relationship)
      } else if (interstate_relationship == "Partial Subcomponent") {
        session$sendCustomMessage(type = "partial_subcomponent", interstate_relationship)
      }
  })
  
  # Interstate v2
  
  ### --- SEE ALL COMPONENTS --- ###
  observeEvent(input$runButton4.1, {
    interstate_relationship2 <- input$interstate2
    
    ### - EXACT MATCH - ###
    
    if (interstate_relationship2 == "Exact Match"){
      
      df <- df_exact_match %>%
        as.data.frame()
      
      # Copy pasted from my sparql_queries file
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
      # write_csv(abc, "www/df_exact_match_v2.csv")
      
      
      # Empty imports dont work in d3, so assigning imports same as name for ones that dont have imports
      # abc$imports[abc$imports == ""] <- abc$name
      # abc$imports <- with(abc, ifelse(imports == "", name, imports ) )
      
      df_exact_matchJSON <- toJSON(clean)
      session$sendCustomMessage(type = "exact_match2", df_exact_matchJSON)
    
      ### - SUBCOMPONENT - ###
      
    } else if (interstate_relationship2 == "Subcomponent") {
      
      df <- df_subcomponent %>%
        as.data.frame()
      
      # Copy pasted from my sparql_queries file
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
      session$sendCustomMessage(type = "subcomponent2", df_subcomponentJSON)
    
      ### - PARTIAL SUBCOMPONENT - ###
        
    } else if (interstate_relationship2 == "Partial Subcomponent") {
      
        df <- df_partial_subcomponent %>%
          as.data.frame()
        
        # Copy pasted from my sparql_queries file
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
        session$sendCustomMessage(type = "partial_subcomponent2", df_partial_subcomponentJSON)
      
      }
    
  })
  
  #### --- SEE SELECTED COMPONENTS --- ###
  
  observeEvent(input$runButton4.2, {
    interstate_relationship2 <- input$interstate2
    
    ### - EXACT MATCH - ###
    if (interstate_relationship2 == "Exact Match"){
      # storing user input in separate variables, directly putting input$___ in filter did not work...
      state <- c(input$interstate_states2)
      flowType <- c(input$interstate_flowType)
      flowSource <- c(input$interstate_flowSource)
      flowSink <- c(input$interstate_flowSink)
      
      df <- df_exact_match %>%
         filter(state_cL %in% state) %>%
         filter(state_exmL %in% state) %>%
         filter(ftype_exmL %in% flowType) %>%
         filter(ftype_cL %in% flowType) %>%
         filter(fsource_exmL %in% flowSource) %>%
         filter(fsource_cL %in% flowSource) %>%
         filter(fsink_exmL %in% flowSink) %>%
         filter(fsink_cL %in% flowSink) %>%
        as.data.frame()
      
      # Copy pasted from my sparql_queries file
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
      # write_csv(abc, "www/df_exact_match_v2.csv")
      
      
      # Empty imports dont work in d3, so assigning imports same as name for ones that dont have imports
      # abc$imports[abc$imports == ""] <- abc$name
      # abc$imports <- with(abc, ifelse(imports == "", name, imports ) )
      
      df_exact_matchJSON <- toJSON(clean)
      session$sendCustomMessage(type = "exact_match2", df_exact_matchJSON)
    
      ### - SUBCOMPONENT - ###  
    } else if (interstate_relationship2 == "Subcomponent") {
      
      state <- c(input$interstate_states2)
      flowType <- c(input$interstate_flowType)
      flowSource <- c(input$interstate_flowSource)
      flowSink <- c(input$interstate_flowSink)
      
      df <- df_subcomponent %>%
        filter(state_cL %in% state) %>%
        filter(state_scL %in% state) %>%
        filter(ftype_scL %in% flowType) %>%
        filter(ftype_cL %in% flowType) %>%
        filter(fsource_scL %in% flowSource) %>%
        filter(fsource_cL %in% flowSource) %>%
        filter(fsink_scL %in% flowSink) %>%
        filter(fsink_cL %in% flowSink) %>%
        as.data.frame()
      
      # Copy pasted from sparql_queries file
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
      session$sendCustomMessage(type = "subcomponent2", df_subcomponentJSON)
    
      ### - PARTIAL SUBCOMPONENT - ###
    } else if (interstate_relationship2 == "Partial Subcomponent"){
        
        state <- c(input$interstate_states2)
        flowType <- c(input$interstate_flowType)
        flowSource <- c(input$interstate_flowSource)
        flowSink <- c(input$interstate_flowSink)
        
        df <- df_partial_subcomponent %>%
          filter(state_cL %in% state) %>%
          filter(state_pscL %in% state) %>%
          filter(ftype_pscL %in% flowType) %>%
          filter(ftype_cL %in% flowType) %>%
          filter(fsource_pscL %in% flowSource) %>%
          filter(fsource_cL %in% flowSource) %>%
          filter(fsink_pscL %in% flowSink) %>%
          filter(fsink_cL %in% flowSink) %>%
          as.data.frame()
        
        # Copy pasted from sparql_queries file
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
        session$sendCustomMessage(type = "partial_subcomponent2", df_partial_subcomponentJSON)
    }
  })
}


shinyApp(ui = ui, server = server) 