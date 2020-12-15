# Code sections can be expanded using ALT+O or collapsed using SHIFT+ALT+O
# Code structure is provided in 'App code structure.docx' file
# The code is divided into 2 main parts: Data processing & Shiny app development
#-------------------------------------------------------------------------------

#*******************************#
#***** I. DATA PREPARATION *****#
#*******************************#

# --------------- 1. Import packages --------------- # ####

library(shiny)
library(shinyjs)
library(tidyverse)
library(rdflib)
library(jsonlite)
library(d3r)

# --------------- 2. Loading CSV files --------------- # ####

# ----- 2.1. Importing CSVs for Component tab ----- #
df_component_full <- read_csv("www/df_component_full2.csv") #dataframe for component summary (including URIs)
df_component_flow <- read_csv("www/df_component_flow2.csv") #dataframe for component summary including flow and interstate information
df_component <- read_csv("www/df_component2.csv") #dataframe for d3 chart on component tab

# ----- 2.2. Importing CSVs for State tab ----- #
df_state <- read_csv("www/df_state2.csv")

# ----- 2.3. Importing CSVs for Data Source tab ----- #
df_data_source <- read_csv("www/df_data_source2.csv")

# ----- 2.4. Importing CSVs for Data Source tab ----- #
df_exact_match <- read_csv("www/df_exact_match2.csv") #dataframe for exact matches
df_subcomponent <- read_csv("www/df_subcomponent2.csv") #dataframe for subcomponents
df_partial_subcomponent <- read_csv("www/df_partial_subcomponent2.csv") #dataframe for partial subcomponents

# --------------- 3. Input choices --------------- # ####

# ----- 3.1. Component tab ----- #
component_choices <- c(unique(df_component_full$cL))

# ----- 3.2. State tab ----- #
state_choices <- c("CA","CO","NM","UT","WY")

# ----- 3.3. Data Source tab ----- #
data_source_choices <- c(unique(df_state$dsL)) #select unique data sources from dsL column
data_source_choices <- sort(data_source_choices[-1]) #remove NA & sort alphabetically

# ----- 3.4. Interstate tab ----- #
interstate_choices <- c("Exact Match", "Subcomponent", "Partial Subcomponent") #possible interstate relatiosnhips between components
interstate_state_choices <- c("SELECT ALL", "CLEAR ALL", "CA","CO","NM","UT","WY") #state choices
# Following choices do not really matter because they will subset based on input state choices
flow_type_choices <- c("All", "Inflow", "Internal Transfer", "Outflow", "Storage Change")
flow_source_choices <- c("All", unique(df_exact_match$fsource_cL))
flow_sink_choices <- c("All", "hello")



#*************************************#
#***** II. SHINY APP DEVELOPMENT *****#
#*************************************#

# --------------- 4. User Interface --------------- # ####

ui <- fluidPage(id = "page", theme = "styles.css",
    useShinyjs(),
    
    # ----- 4.1. Locate supporting files ----- #
    
    tags$head(tags$link(href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&display=swap", #add custom font
                        rel="stylesheet"),
              tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"), #locating CSS file
              tags$script(src = "https://d3js.org/d3.v5.min.js"), #loading D3.js library
              tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.10.2/underscore.js"), #load Underscore.js library
              tags$script(src = "index_v9.js"), #locating JavaScript file creating D3 charts on tabs Component, State and Data Source
              tags$script(src = "interstate_exact_match.js"), #locating JavaScript file creating round D3 chart for exact match components
              tags$script(src = "interstate_subcomponent.js"), #locating JavaScript file creating round D3 chart for subcomponents
              tags$script(src = "interstate_partial_subcomponent.js") #locating JavaScript file creating round D3 chart for partial subcomponents
              ),
    tags$body(HTML('<link rel="shortcut icon", href="favicon.png",
                       type="image/png" />')), #displaying logo on toolbar
    tags$div(class = "header",
             tags$a(href="https://internetofwater.org/", target = "_blank", 
                    tags$img(src = "iow_logo.png", width = 60)), #adding logo on the upper left of window
             tags$h1("Water Budget Navigator"),
             titlePanel(title="", windowTitle = "IoW Water Budget App")), #displaying title on toolbar
    navbarPage(title = "",
               selected = "Home", #creating navbar page which will house all the tabs
               theme = "styles.css", #applying custom CSS from styles.css
               fluid = TRUE, 

      # ----- 4.2. Tabs ---- #
      
      # ----- 4.2.1. Tab - Home - Begin
      
      # Creating welcome banner
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
        
        # Adding all the text appearing on the home page
        tags$div(class = "instruction-1",
                 tags$div(class = "text-area",
                          tags$b("DISCLAIMER: This application is currently in the development stage. 
               All the data is provisional and subject to change. This tool is suited for desktop use and best performs on Google Chrome 
               but is also functional on Mozilla Firefox and Safari.",
                                 style = "color: salmon; font-size: 100%; text-align: center; line-height: 1.2;"),
                          
                          # adding empty space before next section
                          tags$br(),
                          tags$p("  "),
                          tags$br(),
                          tags$p("  "),
                          tags$br(),
                          tags$p("  "),
                          tags$h1("What is Water Budget Navigator?"),
                          tags$br(),
                          tags$h3("Water Budget Navigator is a web application developed by Internet of Water (IoW). It allows users to explore water budget frameworks
                                 across the United States. A state's water budget framework primarily consists of a jurisdiction, components,
                                 estimation methods, parameters and data sources in an ordered manner. The components have additional properties describing
                                  their flow information and relationships with other components within and across states. Here is the framework we use for this tool.
                                  Definition for each term of our framework is provided below."),
                          tags$br()
                          ),
                 tags$div(id = "home_container",
                          tags$img(src = "home_d3.svg")), #svg containing the visualization for water budget framework
                 tags$br(),
                 tags$div(class = "text-area",
                          tags$h1("Why use Water Budget Navigator?"),
                          tags$h3("One-stop place for water budget stuff, first of its kind, each term linked to its definition etc"),
                          tags$br(),
                          tags$br(),
                          tags$br(),
                          tags$br(),
                          tags$h1("What is the definition of the terms used?"),
                          tags$br(),
                          tags$h3("Water Budget Navigator uses a specific terminology to facilitate easy interpretation of the tool to its users. The key terms used in the app are: ",
                                  tags$p(" "),
                                  tags$ul(type="disc", 
                                          tags$li(tags$b("Jurisdiction"),": A state which has its own state-level water budget"),
                                          tags$li(tags$b("Component")),
                                          tags$li(tags$b("Estimation Method"))
                                          )
                                  ),
                          tags$br(),
                          tags$br(),
                          tags$br(),
                          tags$br(),
                          tags$h1("How to use Water Budget Navigator?"),
                          tags$h3("It has follwoing tabs: (explain each tabs)")
                          ),
                 tags$div(class = "text-area",
                          tags$h3("More coming soon...")),
                 ),
          ),
          
      # -X-X-X- Tab - Home - End -X-X-X- 

      
      # ----- 4.2.2. Tab - Component - Begin
      
      tabPanel(title = "Component",
        tags$div(class = "banner", 
                 tags$img(class = "banner-img-component",
                          src = "image_1.jpg"), #tab banner image
                 tags$div(class = "banner-text",
                          tags$p(class = "h1", "Search by component"), #tab banner title
                          tags$p(class = "h3", "Explore the profile of a water budget component") #tab banner sub-title
                          )),
        column(width = 12, 
               column(width = 12,
                      # User instructions
                      tags$p("1. Select a state to see all its water budget components in the drop down menu"),
                      tags$p('2. Select a component to explore its relationship with other components, its flow information, estimation method(s), parameter(s) and data source(s)'),
                      tags$p('3. Click on the button and scroll down to see all the information')
               )
        ),
        column(width = 12,
          column(width = 3,
                 selectInput(inputId = "states1", #users choose a state
                             label = "Select state", 
                             choices = state_choices)), 
          column(width = 3,
                 selectInput(inputId = "components", #users choose a component
                             label = "Select component",
                             choices = component_choices)), 
          column(width = 2,
                 actionButton(inputId = "runButton1", #button to see output
                              label = "",
                              icon = icon("check")) 
                 )),
        tags$body(hidden(
                  tags$div(id = "component_summary", #div for a component's summary info
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
                  tags$div(id = "component_container")) #div containing D3 visualization from JavaScript code
      ),
      
      # -X-X-X- Tab - Component - End -X-X-X- 
      
      # ----- 4.2.3. Tab - State - Begin
      
      tabPanel(title = "State",
        tags$div(class = "banner", 
                 tags$img(class = "banner-img-state", #tab banner image
                          src = "image_3.jpg"),
                 tags$div(class = "banner-text",
                          tags$p(class = "h1", "Search by state"), #tab banner title
                          tags$p(class = "h3", "Explore the water budget framework of a state") #tab banner subt-title
                        )),
        column(width = 12, 
               column(width = 12,
                      # User instructions
                      tags$p("1. Select a state to interact with its water budget framework"),
                      tags$p('2. Click on the button to scroll to the parent node representing the state selected'),
                      tags$p("3. Click on the colored nodes to explore the state's water budget components and the associated estimation method(s), parameter(s), and data source(s), in that order")
               )
        ),
        column(width = 12,
          column(width = 3,
                 selectInput(inputId = "states2", #users input state choice
                             label = "Select state",
                             choices = state_choices)), 
          column(width = 2, 
               actionButton(inputId = "runButton2", #button to see output
                            label = "",
                            icon = icon("check"))
               )),
        tags$body(tags$div(id = "state_sticky"), #sticky div to show headers of each new level of expandible D3 chart
                  tags$div(id = "state_container")) #div containing D3 visualization
    ),
    
    # -X-X-X- Tab - State - End -X-X-X- 

    # ------ 4.2.4. Tab - Data Source - Begin 
    
    tabPanel(title = "Data Source",
             tags$div(class = "banner", 
                      tags$img(class = "banner-img-state", #tab banner image
                               src = "image_4.jpg"),
                      tags$div(class = "banner-text",
                               tags$p(class = "h1", "Search by data source"), #tab banner title
                               tags$p(class = "h3", "Explore the parameters, estimation methods and components used by a data source") #tab banner subtitle
                      )),
             column(width = 12, 
                    column(width = 12,
                           # User intructions
                           tags$p("1. Select a data source that contributed to a water budget"),
                           tags$p('2. Click on the button to see parameters defined in the data source'),
                           tags$p("3. Click on the colored nodes to explore the data source and the associated parameter(s), estimation method(s), and component(s), in that order")
                    )
             ),
             column(width = 12,
                    column(width = 3,
                           selectInput(inputId = "data_source",
                                       label = "Select data source", #users select a data source 
                                       selected = data_source_choices[2], #default choice
                                       choices = data_source_choices)), 
                    column(width = 2, 
                           actionButton(inputId = "runButton3", #button to see output
                                        label = "",
                                        icon = icon("check"))
                    )),
             tags$body(tags$div(id = "data_source_sticky"), #sticky div to show headers of each new level of expandible D3 chart
                       tags$div(id = "data_source_container")) #div containing D3 visualization
    ),
    
    # -X-X-X- Tab - Data Source - End -X-X-X- 


    # ------- 4.2.5 Tab - Interstate - Begin 
    
    tabPanel(title = "Interstate",
             tags$div(class = "banner", 
                      tags$img(class = "banner-img-state", #tab banner image
                               src = "image_7.jpg"),
                      tags$div(class = "banner-text",
                               tags$p(class = "h1-interstate", "Search interstate relationships"), #tab banner title
                               tags$p(class = "h3", "Explore the relationships among water budget components 
                                              within and among states")#tab banner sub-title
                      )),
             column(width = 12, 
                    column(width = 12,
                           tags$b("See All Components", style = "font-size: 130%"), #title for 'See all Components'
                           tags$p(" "),
                           # User instructions to see all components
                           tags$p("1. Choose the type of interstate relationship among water budget components"),
                           tags$p('2. Click on the button below to include all components'),
                           tags$p('3. Hover over a component to explore relationships')
                           )
             ),
             column(width = 12,
                    column(width = 3,
                           selectInput(inputId = "interstate2", #users select an interstate relationship
                                       label = "Select interstate relationship",
                                       choices = interstate_choices)),
                    column(width = 2,
                           actionButton(inputId = "runButton4.1", #button to see D3 output
                                        label = "",
                                        icon = icon("check")
                           ))
                    ), #defined above UI
             
             column(width = 12, 
                    column(width = 12,
                           tags$b("See Selected Components", style = "font-size: 130%"),
                           tags$p(" "),
                           # User instructions to see selected components
                           tags$p('1. Choose the type of interstate relationship among water budget components above'),
                           tags$p('2. Choose "SELECT ALL" and "CLEAR ALL" to select and clear all choices in the fields below'),
                           tags$p('3. Select the states of interest'),
                           tags$p('4. Filter the components by flow type, flow source and flow sink'),
                           tags$p('5. Click on the button to see the relationships of selected components'),
                           tags$p('6. Hover over a component to explore relationships')
                           )
                    ),
             column(width = 12,
                    column(width = 3,
                           selectInput(inputId = "interstate_states2", #users choose a state
                                       label = "Select states",
                                       choices = interstate_state_choices,
                                       multiple = TRUE,
                                       selected = "SELECT ALL")),
                    column(width = 3,
                           selectInput(inputId = "interstate_flowType", #users choose components by specific flow type
                                       label = "Select flow type", 
                                       choices = flow_type_choices, 
                                       multiple = TRUE,
                                       selected = "All"))
                    ),
             column(width = 12,
                    column(width = 3,
                           selectInput(inputId = "interstate_flowSource", #users choose components by specific flow source
                                       label = "Select flow source",
                                       choices = flow_source_choices,
                                       multiple = TRUE,
                                       selected = "All")), 
                    column(width = 3,
                           selectInput(inputId = "interstate_flowSink", #users choose components by specific flow sink
                                       label = "Select flow sink",
                                       choices = flow_sink_choices,
                                       multiple = TRUE,
                                       selected = "All")),
                    column(width = 2, 
                           actionButton(inputId = "runButton4.2", #button to see output
                                        label = "",
                                        icon = icon("check")))
                    ),
             tags$body(tags$div(id = "interstate_container2")) #div containing the D3 visualization
    ),
    
    # -X-X-X- Tab - Interstate - End -X-X-X-


      navbarMenu(title = "About",
               tabPanel(title = "Other stuff"))
  ))

# --------------- 5. Server --------------- # ####

server <- function(input, output, session){
  
  # ---- 5.1. Component ---- #
  
  # ---- 5.1.1. Update component choices based on user-selected states 
  
  observe({
    
    # Filter dataframe by state selected by user and store in a separate dataframe 
    choices_components <- df_component %>%
      filter(jL %in% input$states1) 
    
    # Select rows having unique components
    choices_components <- c(unique(choices_components$cL)) 
    
    # Update input choices for components
    updateSelectInput(session, "components",
                      choices = choices_components)
  })
  
  # ---- 5.1.2. Summary of a component on Component tab
  
  observeEvent(input$runButton1, {
    
    # Activate div containig summary information of a component
    show("component_summary")
    
    # Retaining columns only containing URIs
    df_uri <- df_component_full %>%
      filter(jL %in% input$states1) %>% #filter by user-selected state
      filter(cL %in% input$components) %>% #filter by user-selected component
      select(-c(1,2,3,4,6,8,10,12,14)) %>% #dropping jL, cL, c columns and retaining uri columns for flow and subcomponent info
      as.data.frame() #convert to dataframe
    
    # Extracting component URI for the title of the Summary div
    uri_title <- df_component_full %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      .$c #selecting component
    
    # Selecting column with component name
    uri_title <- uri_title[1] 
    
    # Storing summary information in a separate dataframe except state and component name 
    component_info <- df_component_flow %>%
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      select(3:length(df_component_flow)) %>% #dropping jL, cL columns 
      as.data.frame()
    
    # URIs
    uri_properties <- c("flow_source", "flow_sink", "flow_type",
                        "subcomponent", "p_subcomponent", "exact_match")
    
    # Property names attached with term "uri"
    uri_list <- paste("uri", uri_properties, sep="_")
    
    # SUMMARY
    # Property names based on htmlOutput (from section 4.2.2.)
    summary_properties <- c("flow_source", "flow_sink", "flow_type",
                    "subcomponent", "p_subcomponent","exact_match")
    
    # Create intermediary objects to hold unique strings from dataframe "component_info"
    # Multiple values for a property are separated by commas
    if (input$states1 == "NM"){ #different for NM because in graph database it is written as NMSOE not just NM
      summary_title <- paste(input$components, input$states1, 
                             sep = "-")
      summary_title <- paste0(summary_title, "OSE")
    } else {
      summary_title <- paste(input$components, input$states1, 
                             sep = "-")
    }
    
    # Concatenating "summary" string to property names separated by "_"
    summary_list <- paste("summary", summary_properties, sep="_")
    
    # Iterate through each property defined above
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
    # so first we split each character in a string and see if it is a comma
    # if it is then we split it by comma and store each value as a list in
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
  
  # ---- 5.1.3. Framework chart of a selected component on Component tab 
  
  observeEvent(input$runButton1, 
               autoDestroy = FALSE, {
    selection_df_1 <- df_component %>%
      # Filter dataframe by user inputs
      filter(jL %in% input$states1) %>%
      filter(cL %in% input$components) %>%
      as.data.frame()
    
    # Dropping column containing state and component names
    selection_df_1 <- select(selection_df_1, -jL, -cL)
    
    # Construct hierarchical JSON for D3 visualization
    selection_json_1 <- d3_nest(data = selection_df_1, root = "")
    
    # Count number of leaf nodes, this will help size the div dyanamically
    # In other words, a component with fewer number of leaf nodes (data sources)
    # will be encapsulated within a smaller rectangular div.
    leaf_nodes_1 <- nrow(selection_df_1)
    
    # Send the numebr of leaf nodes to JavaScript file for adjusting div height accordingly
    session$sendCustomMessage(type = "component_height", leaf_nodes_1)
    
    # Send JSON to JavaScript file as well
    session$sendCustomMessage(type = "component_json", selection_json_1)
  })
  
  # ---- 5.2. State ---- #
  
  observeEvent(input$runButton2, {
    selection_df_2 <- df_state %>%
      # Filter dataframe by user inputs
      filter(jL %in% input$states2) %>%
      as.data.frame()
    
    # Remove the column containing state name
    selection_df_2 <- select(selection_df_2, -jL)
    
    # Construct hierarchical JSON for D3 visualization
    selection_json_2 <- d3_nest(data = selection_df_2, root = input$states2)
    
    # Count number of leaf nodes
    leaf_nodes_2 <- nrow(selection_df_2)
    
    # Send the numebr of leaf nodes to JavaScript file for adjusting div height accordingly
    session$sendCustomMessage(type = "state_height", leaf_nodes_2)
    
    # Send the JSON to JavaScript file that makes interactive D3 visualization
    session$sendCustomMessage(type = "state_json", selection_json_2)
  })
  
  # ---- 5.3. Data Source ---- #

  observeEvent(input$runButton3, {
    selection_df_3 <- df_data_source %>%
      # Filter by user-selected data scource
      filter(dsL %in% input$data_source) %>%
      as.data.frame()
    
    # Remove the column conatining data source name
    selection_df_3 <- select(selection_df_3, -dsL)
    
    # Construct hierarchical JSON for D3 visualization
    selection_json_3 <- d3_nest(data = selection_df_3, root = input$data_source)
    
    # Count number of leaf nodes
    leaf_nodes_3 <- nrow(selection_df_3)
    
    # Send the numebr of leaf nodes to JavaScript file for adjusting div height accordingly 
    session$sendCustomMessage(type = "data_source_height", leaf_nodes_3)
    
    # Send the JSON to JavaScript file that makes interactive D3 visualization 
    session$sendCustomMessage(type = "data_source_json", selection_json_3)
  })
  
  # ---- 5.4. Update input choices for Interstate - SEE SELECTED COMPONENTS ---- #
  
  # ---- 5.4.1 Update input choices for interstate relationships among components
  
  observe({

    #--- State choices ---#
    
    # Choose all the states except "SELECT All" and "CLEAR ALL" choices
    if("SELECT ALL" %in% input$interstate_states2){
      selected_choices2 = interstate_state_choices[c(-1, -2)] 
      # Option to clear all states (user-input)
      } else if("CLEAR ALL" %in% input$interstate_states2){
      selected_choices2 = ""
      # Else select states
      } else {
        selected_choices2 = input$interstate_states2
      }
    
    # Update choices based on user input
    updateSelectInput(session, "interstate_states2", selected = selected_choices2)
    
    # ---- 5.4.1.1. Exact Match
    
    # Update flow choices based on Exact Match
    if (input$interstate2 == "Exact Match"){
      
      #--- Flow Type choices ---#
      
      # Filter flow type choices into separate variables based on states selected
      selected_flowType <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_exmL))
      selected_flowType_default <- selected_flowType
      
      # If you select "...ALL" it will add or clear all flow type choices
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
        } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
        # Else store specific choice
        } else {
        selected_flowType_default = input$interstate_flowType
        }
      
      # Update choices flow type 
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      
      # Filter flow source choices in separate variables based on states and flow type selected
      selected_flowSource <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) %>%
        filter(ftype_exmL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_exmL))
      
      # If you select "...ALL" it will add or clear all flow source choices
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2, "...ALL" choices
        } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
        # Else store specific choice
        } else {
        selected_flowSource_default = input$interstate_flowSource
        }
      
      # Update choices for flow source
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      
      # Filter flow sink choices into separate variables based on states, flow type and flow sink selected
      selected_flowSink <- df_exact_match %>%
        filter(state_exmL %in% input$interstate_states2) %>%
        filter(ftype_exmL %in% input$interstate_flowType) %>%
        filter(fsource_exmL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_exmL))
      
      # If you select "...ALL" it will add or clear all flow sink choices
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
        } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
        # Else store specific choice
        } else{
        selected_flowSink_default = input$interstate_flowSink
        }
      
      # Update choices for flow sink
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
    
      
      # ---- 5.4.1.2. Subcomponent
      
      # Update flow choices based on Subcomponent
    } else if (input$interstate2 == "Subcomponent"){
      
      #--- Flow Type choices ---#
      
      # Filter flow type choices into separate variables based on states selected
      selected_flowType <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_scL))
      selected_flowType_default <- selected_flowType
      
      # If you select "...ALL" it will add or clear all flow type choices
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
        } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
        # Else store specific choice
        } else {
        selected_flowType_default = input$interstate_flowType
        }
      
      # Update choices flow type
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      
      # Filter flow source choices in separate variables based on states and flow type selected
      selected_flowSource <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) %>%
        filter(ftype_scL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_scL))
      
      # If you select "...ALL" it will add or clear all flow source choices
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2
        } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
        # Else store specific choice
        } else {
        selected_flowSource_default = input$interstate_flowSource
        }
      
      # Update choices for flow source
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      
      # Filter flow sink choices into separate variables based on states, flow type and flow sink selected
      selected_flowSink <- df_subcomponent %>%
        filter(state_scL %in% input$interstate_states2) %>%
        filter(ftype_scL %in% input$interstate_flowType) %>%
        filter(fsource_scL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_scL))
      
      # If you select "...ALL" it will add or clear all flow sink choices
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
        } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
        # Else store specific choice
        } else{
        selected_flowSink_default = input$interstate_flowSink
        }
      
      # Update choices for flow sink
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
      
      
      # ---- 5.4.1.2. Partial Subcomponent
      
      # Update flow choices based on Partial Subcomponent
    } else if (input$interstate2 == "Partial Subcomponent"){
      
      #--- Flow Type choices ---#
      
      # Filter flow type choices into separate variables based on states selected
      selected_flowType <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) 
      selected_flowType <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowType$ftype_pscL))
      selected_flowType_default <- selected_flowType
      
      # If you select "...ALL" it will add or clear all flow type choices
      if("SELECT ALL" %in% input$interstate_flowType){
        selected_flowType_default = selected_flowType[c(-1, -2)] #choose all the choices except "All"
        } else if("CLEAR ALL" %in% input$interstate_flowType){
        selected_flowType_default = ""
        # Else store specific choice
        } else {
        selected_flowType_default = input$interstate_flowType
        }
      
      # Update choices flow type
      updateSelectInput(session, "interstate_flowType", selected = selected_flowType_default, choices = selected_flowType)
      
      #--- Flow Source choices ---#
      
      # Filter flow source choices in separate variables based on states and flow type selected
      selected_flowSource <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) %>%
        filter(ftype_pscL %in% input$interstate_flowType)
      selected_flowSource <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSource$fsource_pscL))
      
      # If you select "...ALL" it will add or clear all flow source choices
      if("SELECT ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = selected_flowSource[c(-1, -2)] #choose all the choices except 1 and 2, "...ALL" choices
        } else if("CLEAR ALL" %in% input$interstate_flowSource){
        selected_flowSource_default = ""
        # Else store specific choice
        } else {
        selected_flowSource_default = input$interstate_flowSource
        }
      
      # Update choices for flow source
      updateSelectInput(session, "interstate_flowSource", selected = selected_flowSource_default, choices = selected_flowSource)
      
      #--- Flow Sink choices ---#
      
      # Filter flow sink choices into separate variables based on states, flow type and flow sink selected
      selected_flowSink <- df_partial_subcomponent %>%
        filter(state_pscL %in% input$interstate_states2) %>%
        filter(ftype_pscL %in% input$interstate_flowType) %>%
        filter(fsource_pscL %in% input$interstate_flowSource)
      selected_flowSink <- c("SELECT ALL", "CLEAR ALL", unique(selected_flowSink$fsink_pscL))
      
      # If you select "...ALL" it will add or clear all flow sink choices
      if("SELECT ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = selected_flowSink[c(-1, -2)] #choose all the choices except 1 and 2
        } else if("CLEAR ALL" %in% input$interstate_flowSink){
        selected_flowSink_default = ""
        # Else store specific choice
        } else{
        selected_flowSink_default = input$interstate_flowSink
        }
      
      # Update choices for flow sink
      updateSelectInput(session, "interstate_flowSink", selected = selected_flowSink_default, choices = selected_flowSink)
    }
  })
  
  
  # ---- 5.5. Data Processing for D3 visualization ---- #
  
  # ---- 5.5.1. SEE ALL COMPONENTS
  
  observeEvent(input$runButton4.1, {
    interstate_relationship2 <- input$interstate2
    
    # ---- 5.5.1.1. Exact Match
    
    if (interstate_relationship2 == "Exact Match"){
      
      df <- df_exact_match %>%
        as.data.frame()
      
      # Removing state abbreviations to put them before component names in next steps (for d3 sorting)
      df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
      df$exmL <- gsub("-[A-Z]*","", df$exmL)
      
      # Putting state abbreviations before the component names so that D3 later sorts by state
      df$cL <- paste0(df$state_cL,"-", df$cL)
      df$exmL <- paste0(df$state_exmL,"-", df$exmL)
      
      # Putting all components and states in 1 column,
      # adding a column of "key" for d3 edge bundling
      # keeping the "imports" empty for d3 because d3 wants that A has import B but B does not have import A
      exact_match <- data.frame(cL = c(df[,"cL"], df[,"empty"]),
                                exmL = c(df[,"exmL"], df[,"cL"]),
                                state_2L = c(df[,"state_exmL"], df[,"state_cL"]),
                                key = c(df[,"exmL"], df[,"cL"]),
                                ftype = c(df[,"ftype_exmL"], df[,"ftype_cL"]),
                                fsource = c(df[,"fsource_exmL"], df[,"fsource_cL"]),
                                fsink = c(df[,"fsink_exmL"], df[,"fsink_cL"]),
                                uri = c(df[,"exm"], df[,"c"]))
      
      # Rename column names
      # Renaming cL as "imports" and scL as "names"
      colnames(exact_match) <- c("imports", "name", "state", "key", "flow_type",
                                 "flow_source", "flow_sink", "uri")
      
      # Add "a." in all component names to work with d3 edge bundling (bilink function),
      # dont ask why, it is what it is :)
      exact_match$name <- paste("a", 
                                exact_match$name, sep=". ")
      exact_match$imports <- paste("a", 
                                   exact_match$imports, sep=". ")
      
      # Rearrange columns in the dataframe
      col_order <- c("state","name","key","imports", "flow_type",
                     "flow_source", "flow_sink", "uri")
      exact_match <- exact_match[,col_order]
      
      # Sort by alphabetical order
      exact_match <- arrange(exact_match, state, name, key)
      
      # Storing subcomponents separated by comma for a componenet
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
      
      # Replace dot in "No." in component name to "No:, because D3 separates string at dot
      exact_match_final$name <- mapply(gsub, pattern='No.',
                                       replacement="No", exact_match_final$name )
      
      # Drop string 'NA-NA'
      exact_match_final <- exact_match_final[!(exact_match_final$name == "a. NA-NA"),]
      
      # To easily navigate through visualization, add state name at the end to the latter half of the data frame
      # get number of rows
      len <- nrow(exact_match_final)
      # if number of rows is even number, divide by 2 or else add 1 and then divide by 2
      if (len%%2==0){
      rows_drop <- (len)/2
      } else {
      rows_drop <- (len+1)/2
      }
      #drop the first half of the dataframe
      latter_half <- exact_match_final[-c(1:rows_drop),] #drop the initial half of the dataframe
      # extract first half of dataframe
      first_half <- exact_match_final[c(1:rows_drop),]
      # remove state name 
      latter_half$key <- gsub('[A-Z]*-', "", latter_half$key)
      # add state name at the end of the component
      latter_half$key <- paste0(latter_half$key, "-", latter_half$state)
      
      # Combining the two halves back together
      clean <- rbind(first_half, latter_half)
      
      print(len)
      print(rows_drop)
      print(nrow(latter_half))
      print(nrow(first_half))
      write_csv(clean, "www/checkingExactMatch.csv")
      
      # Converting dataframe to JSON for D3 compatibility
      df_exact_matchJSON <- toJSON(clean)
      
      # Sending JSON over to the JavaScript file where D3 visuliazation is constructed
      session$sendCustomMessage(type = "exact_match", df_exact_matchJSON)
    
      # ---- 5.5.1.2. Subcomponent
      
    } else if (interstate_relationship2 == "Subcomponent") {
      
      df <- df_subcomponent %>%
        as.data.frame()
      
      # Removing state abbreviations to put them before component names in next steps (for d3 sorting)
      df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
      df$scL <- gsub("-[A-Z]*","", df$scL)
      
      # Putting state abbreviations before the name so that d3 sorts by state
      df$cL <- paste0(df$state_cL,"-", df$cL)
      df$scL <- paste0(df$state_scL,"-", df$scL)
      
      # Putting all components and states in 1 column,
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
      
      # Rename column names
      # Renaming cL as "imports" and scL as "names"
      colnames(subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                                  "flow_source", "flow_sink", "uri")
      
      # Add "a." in all component names to work with d3 edge bundling (bilink function)
      # dont ask why, it is what it is :)
      subcomponent$name <- paste("a", 
                                 subcomponent$name, sep=". ")
      subcomponent$imports <- paste("a", 
                                    subcomponent$imports, sep=". ")
      
      # Rearrange columns in the dataframe
      col_order <- c("state","name","key","imports", "flow_type",
                     "flow_source", "flow_sink", "uri")
      subcomponent <- subcomponent[,col_order]
      
      # Sort by alphabetical order
      subcomponent <- arrange(subcomponent, state, name, key, uri)
      
      # Storing subcomponents separated by comma for a componenet
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
      
      # Replace dot in "No." in component name to "No", because d3 separates at dot
      subcomponent_final$name <- mapply(gsub, pattern='No.',
                                        replacement="No", subcomponent_final$name )
      
      # Drop string 'NA-NA'
      clean <- subcomponent_final[!(subcomponent_final$name == "a. NA-NA"),]
      
      # Converting dataframe to JSON for D3 compatibility
      df_subcomponentJSON <- toJSON(clean)
      
      # Sending JSON over to the JavaScript file where D3 visuliazation is constructed
      session$sendCustomMessage(type = "subcomponent", df_subcomponentJSON)
    
      # ----- 5.5.1.3. Partial Subcomponent
        
    } else if (interstate_relationship2 == "Partial Subcomponent") {
      
        df <- df_partial_subcomponent %>%
          as.data.frame()
        
        # Removing state abbreviations to put them before names in next steps (for d3 sorting)
        df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
        df$pscL <- gsub("-[A-Z]*","", df$pscL)
        
        # Putting state abbreviations before the name so that d3 sorts by state
        df$cL <- paste0(df$state_cL,"-", df$cL)
        df$pscL <- paste0(df$state_pscL,"-", df$pscL)
        
        # Putting all components and states in 1 column,
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
        
        # Rename column names
        # Renaming cL as "imports" and pscL as "names"
        colnames(partial_subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                                            "flow_source", "flow_sink", "uri")
        
        # Add "a." in all names to work with d3 edge bundling (bilink function)
        # dont ask why, again, it is what it is :)
        partial_subcomponent$name <- paste("a", 
                                           partial_subcomponent$name, sep=". ")
        partial_subcomponent$imports <- paste("a", 
                                              partial_subcomponent$imports, sep=". ")
        
        # Rearrange columns in the dataframe
        col_order <- c("state","name","key","imports", "flow_type",
                       "flow_source", "flow_sink", "uri")
        partial_subcomponent <- partial_subcomponent[,col_order]
        
        # Sort by alphabetical order
        partial_subcomponent <- arrange(partial_subcomponent, state, name, key, uri)
        
        # Store partial_subcomponents separated by comma for a componenet
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
        
        # Replace dot in "No." in component name to "No", because d3 separates at dot
        partial_subcomponent_final$name <- mapply(gsub, pattern='No.',
                                                  replacement="No", partial_subcomponent_final$name )
        
        # Drop string 'NA-NA'
        clean <- partial_subcomponent_final[!(partial_subcomponent_final$name == "a. NA-NA"),]
        
        # Convert dataframe to JSON for D3 compatibility
        df_partial_subcomponentJSON <- toJSON(clean)
        
        # Send JSON over to the JavaScript file where D3 visualization is constructed
        session$sendCustomMessage(type = "partial_subcomponent", df_partial_subcomponentJSON)
      
      }
    
  })
  
  # ---- 5.5.2. SEE SELECTED COMPONENTS
  
  observeEvent(input$runButton4.2, {
    interstate_relationship2 <- input$interstate2
    
    #--- Error Message ---#
    
    # If flow type is left blank
    if(is.null(input$interstate_flowType)){
      # show pop-up
      showModal(modalDialog(
        title = "Invalid Input: Flow type not found",
        paste0('Please select flow type, flow source, and flow sink and try again. If flow information is not required, click the button to "See All Components" '),
        easyClose = TRUE,
        footer = NULL
      ))
    
    # If flow source is left blank
    } else if(is.null(input$interstate_flowSource)){
      # show pop-up
      showModal(modalDialog(
        title = "Invalid Input: Flow source not found",
        paste0('Please select flow source and flow sink and try again. If flow information is not required, click the button to "See All Components" '),
        easyClose = TRUE,
        footer = NULL
      ))
      
    # If flow sink is left blank
    } else if(is.null(input$interstate_flowSink)){
      # show pop-up
      showModal(modalDialog(
        title = "Invalid Input: Flow sink not found",
        paste0('Please select flow sink and try again. If flow information is not required, click the button to "See All Components" '),
        easyClose = TRUE,
        footer = NULL
      ))
    } else {
      
      # ---- 5.5.2.1. Exact Match
      
        if (interstate_relationship2 == "Exact Match"){
          
          # Storing user input in separate variables because directly putting input$___ in filter in next step did not work...
          state <- c(input$interstate_states2)
          flowType <- c(input$interstate_flowType)
          flowSource <- c(input$interstate_flowSource)
          flowSink <- c(input$interstate_flowSink)
          
          # Filter dataframe by user inputs
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
          
          # Removing state abbreviations to put them before component names in next steps (for d3 sorting)
          df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
          df$exmL <- gsub("-[A-Z]*","", df$exmL)
          
          # Putting state abbreviations before the component names so that D3 later sorts by state
          df$cL <- paste0(df$state_cL,"-", df$cL)
          df$exmL <- paste0(df$state_exmL,"-", df$exmL)
          
          # Putting all components and states in 1 column,
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
          
          # Rename column names
          # Renaming cL as "imports" and scL as "names"
          colnames(exact_match) <- c("imports", "name", "state", "key", "flow_type",
                                     "flow_source", "flow_sink", "uri")
          
          # Add "a." in all component names to work with d3 edge bundling (bilink function),
          # dont ask why, it is what it is :)
          exact_match$name <- paste("a", 
                                    exact_match$name, sep=". ")
          exact_match$imports <- paste("a", 
                                       exact_match$imports, sep=". ")
          
          # Rearrange columns in the dataframe
          col_order <- c("state","name","key","imports", "flow_type",
                         "flow_source", "flow_sink", "uri")
          exact_match <- exact_match[,col_order]
          
          # Sort by alphabetical order
          exact_match <- arrange(exact_match, state, name, key)
          
          # Storing subcomponents separated by comma for a componenet
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
          
          # Replace dot in "No." in component name to "No:, because D3 separates string at dot
          exact_match_final$name <- mapply(gsub, pattern='No.',
                                           replacement="No", exact_match_final$name )
          
          # Drop string 'NA-NA'
          clean <- exact_match_final[!(exact_match_final$name == "a. NA-NA"),]
          
          # Converting dataframe to JSON for D3 compatibility
          df_exact_matchJSON <- toJSON(clean)
          
          # Sending JSON over to the JavaScript file where D3 visuliazation is constructed
          session$sendCustomMessage(type = "exact_match", df_exact_matchJSON)
          
          # ---- 5.5.2.2. Subcomponent  
          
        } else if (interstate_relationship2 == "Subcomponent") {
          
          # Storing user input in separate variables because directly putting input$___ in filter in next step did not work...
          state <- c(input$interstate_states2)
          flowType <- c(input$interstate_flowType)
          flowSource <- c(input$interstate_flowSource)
          flowSink <- c(input$interstate_flowSink)
          
          # Filter dataframe by user inputs
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
          
          # Removing state abbreviations to put them before component names in next steps (for d3 sorting)
          df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
          df$scL <- gsub("-[A-Z]*","", df$scL)
          
          # Putting state abbreviations before the name so that d3 sorts by state
          df$cL <- paste0(df$state_cL,"-", df$cL)
          df$scL <- paste0(df$state_scL,"-", df$scL)
          
          # Putting all components and states in 1 column,
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
          
          # Rename column names
          # Renaming cL as "imports" and scL as "names"
          colnames(subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                                      "flow_source", "flow_sink", "uri")
          
          # Add "a." in all component names to work with d3 edge bundling (bilink function)
          # dont ask why, it is what it is :)
          subcomponent$name <- paste("a", 
                                     subcomponent$name, sep=". ")
          subcomponent$imports <- paste("a", 
                                        subcomponent$imports, sep=". ")
          
          # Rearrange columns in the dataframe
          col_order <- c("state","name","key","imports", "flow_type",
                         "flow_source", "flow_sink", "uri")
          subcomponent <- subcomponent[,col_order]
          
          # Sort by alphabetical order
          subcomponent <- arrange(subcomponent, state, name, key, uri)
          
          # Storing subcomponents separated by comma for a componenet
          subcomponent_final <- subcomponent %>%
            group_by(state, name, key, flow_type, flow_source, flow_sink, uri) %>%
            summarise(imports = paste0(imports, collapse = ","))
          
          # Replace dot in "No." in component name to "No", because d3 separates at dot
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
          
          # Drop string 'NA-NA'
          clean <- subcomponent_final[!(subcomponent_final$name == "a. NA-NA"),]
          
          # Converting dataframe to JSON for D3 compatibility
          df_subcomponentJSON <- toJSON(clean)
          
          # Sending JSON over to the JavaScript file where D3 visuliazation is constructed
          session$sendCustomMessage(type = "subcomponent", df_subcomponentJSON)
          
          # ----- 5.5.2.3. Partial Subcomponent
          
        } else if (interstate_relationship2 == "Partial Subcomponent"){
          
          # Storing user input in separate variables because directly putting input$___ in filter in next step did not work...
          state <- c(input$interstate_states2)
          flowType <- c(input$interstate_flowType)
          flowSource <- c(input$interstate_flowSource)
          flowSink <- c(input$interstate_flowSink)
          
          # Filter dataframe by user inputs
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
          
          # Removing state abbreviations to put them before names in next steps (for d3 sorting)
          df$cL <- gsub("-[A-Z]*","", df$cL) #* means zero or more time in regex
          df$pscL <- gsub("-[A-Z]*","", df$pscL)
          
          # Putting state abbreviations before the name so that d3 sorts by state
          df$cL <- paste0(df$state_cL,"-", df$cL)
          df$pscL <- paste0(df$state_pscL,"-", df$pscL)
          
          # Putting all components and states in 1 column,
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
          
          # Rename column names
          # Renaming cL as "imports" and pscL as "names"
          colnames(partial_subcomponent) <- c("imports", "name", "state", "key", "flow_type",
                                              "flow_source", "flow_sink", "uri")
          
          # Add "a." in all names to work with d3 edge bundling (bilink function)
          # dont ask why, again, it is what it is :)
          partial_subcomponent$name <- paste("a", 
                                             partial_subcomponent$name, sep=". ")
          partial_subcomponent$imports <- paste("a", 
                                                partial_subcomponent$imports, sep=". ")
          
          # Rearrange columns in the dataframe
          col_order <- c("state","name","key","imports", "flow_type",
                         "flow_source", "flow_sink", "uri")
          partial_subcomponent <- partial_subcomponent[,col_order]
          
          # Sort by alphabetical order
          partial_subcomponent <- arrange(partial_subcomponent, state, name, key, uri)
          
          # Store partial_subcomponents separated by comma for a componenet
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
          
          # Replace dot in "No." in component name to "No", because d3 separates at dot
          partial_subcomponent_final$name <- mapply(gsub, pattern='No.',
                                                    replacement="No", partial_subcomponent_final$name )
          
          # Drop string 'NA-NA'
          clean <- partial_subcomponent_final[!(partial_subcomponent_final$name == "a. NA-NA"),]
          
          # Convert dataframe to JSON for D3 compatibility
          df_partial_subcomponentJSON <- toJSON(clean)
          
          # Send JSON over to the JavaScript file where D3 visualization is constructed
          session$sendCustomMessage(type = "partial_subcomponent", df_partial_subcomponentJSON)
        }
    }
    
  })
}

# NOTE: Alternatively, I could have made functions to apply similar code for different relationships and different flow information.

# Create shiny app object to display in browser
shinyApp(ui = ui, server = server) 