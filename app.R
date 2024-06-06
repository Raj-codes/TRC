# app.R
setwd("C:\\Users\\rrai\\Documents\\TRC")
library(shiny)

# Source the UI, server, and helper scripts
source("ui.R")
source("server.R")
source("helpers.R")

# Define the Shiny app using the sourced UI and server functions
shinyApp(ui = ui, server = server)
