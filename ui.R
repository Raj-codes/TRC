library(shiny)
library(DiagrammeR)

ui <- fluidPage(
  tags$head(
    tags$link(href="https://fonts.googleapis.com/css2?family=Open+Sans&family=Roboto:wght@700&display=swap", rel="stylesheet"),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('adjustHeight', function(message) {
        var nDestinations = message.nDestinations;
        var baseHeight = 300; // base height for the plot
        var additionalHeightPerDest = 100; // additional height per destination
        var newHeight = baseHeight + (nDestinations * additionalHeightPerDest);
        $('#route_chart').height(newHeight);
      });
    ")),
    tags$style(HTML("
      .selectize-input, .selectize-dropdown {
        display: flex;
        align-items: center;
      }
      .selectize-dropdown-content {
        max-height: 300px;
        overflow-y: auto;
      }
      .selectize-input div, .selectize-dropdown-content div {
        display: flex;
        align-items: center;
      }
      .selectize-input div img, .selectize-dropdown-content div img {
        margin-right: 10px;
      }
    "))
  ),
  titlePanel("Simple Travel Route Map"),
  sidebarLayout(
    sidebarPanel(
      textInput("start", "Starting Point"),
      uiOutput("initial_route"),
      uiOutput("destination_ui"),
      actionButton("add_destination", "Add Another Destination"),
      actionButton("generate", "Generate Route Map"),
      textOutput("limit_message")
    ),
    mainPanel(
      grVizOutput("route_chart", height = "auto")
    )
  )
)

