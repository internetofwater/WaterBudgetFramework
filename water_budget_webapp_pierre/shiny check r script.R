library(shiny)

ui <- fluidPage(
  tags$strong("ssup"), #strong is for bold, em is for emphasis
  tags
  tags$img(height = 100, width = 100, src = ""),
  sliderInput(inputId = "num", label = "Pick a number",
              value = 25, min = 1, max = 100),
  textInput(inputId = "title",
            label = "Write something bruh",
            value = "Default value"),
  plotOutput("hist"),
  verbatimTextOutput("stats"),
  actionButton(inputId = "go", label = "Update"),
  actionButton(inputId = "norm", label = "Normal"),
  actionButton(inputId = "unif", label = "Uniform"),
  HTML(
    
  )





server <- function (input, output) {
  #data <- reactive({
  #  rnorm(input$num)
  #  })
  data <- eventReactive(input$go, {
    rnorm(input$num)
  })
  #output$hist <- renderPlot({ # between curly braces you can put many R lines
  #  hist(data(), main = isolate(input$title)) #input has Id "num" from ui
  #})
  output$stats <- renderPrint({
    summary(rnorm(data()))
  })
 # observeEvent(input$clicks, {
 #   print(as.numeric(input$clicks))
 # })
  rv <- reactiveValues(data = rnorm(100))
  
  observeEvent(input$norm, {rv$data <- rnorm(100)})
  observeEvent(input$unif, {rv$data <- rnorm(100)})
  
  output$hist <- renderPlot({
    hist(rv$data)
  })
}


shinyApp(ui = ui, server = server)




# UI - Input functions, Output functions
# Server - Render functions
# your output should not react to the action button!!! its inefficient...
# observeEvent is useful for server side functionality like saving file etc
# Tips - reduce repetition (look at video around 1:31)
# width of  column is 12 units
# use navbarpage & navbar menu and put tabPanel inside them
