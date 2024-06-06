library(shiny)
library(DiagrammeR)
library(lubridate)

source("helpers.R")

server <- function(input, output, session) {
  rv <- reactiveValues(destinations = list(), count = 0, limit_message = "")
  
  observeEvent(input$add_destination, {
    for (i in seq_along(rv$destinations)) {
      rv$destinations[[i]]$end <- input[[paste0("end", i)]]
      rv$destinations[[i]]$transport <- input[[paste0("transport", i)]]
      rv$destinations[[i]]$dep_time <- input[[paste0("dep_time", i)]]
      rv$destinations[[i]]$arr_time <- input[[paste0("arr_time", i)]]
    }
    
    if (rv$count < 10) {
      rv$count <- rv$count + 1
      rv$destinations[[rv$count]] <- list(
        end = "",
        transport = "",
        dep_time = "",
        arr_time = ""
      )
    } else {
      rv$limit_message <- "You have reached the limit for adding additional stops."
    }
    
    session$sendCustomMessage("adjustHeight", list(nDestinations = rv$count))
  })
  
  output$initial_route <- renderUI({
    tagList(
      textInput("end", "Destination"),
      selectInput("transport", "Medium of Transport", choices = c("RE", "S-Bahn", "U-Bahn", "Tram", "Bus")),
      textInput("dep_time", "Departure Time (HH:MM)"),
      textInput("arr_time", "Arrival Time (HH:MM)")
    )
  })
  
  output$destination_ui <- renderUI({
    ui_elements <- list()
    for (i in seq_along(rv$destinations)) {
      ui_elements <- c(ui_elements, list(
        textInput(paste0("end", i), "Destination", value = rv$destinations[[i]]$end),
        selectInput(paste0("transport", i), "Medium of Transport", choices = c("RE", "S-Bahn", "U-Bahn", "Tram", "Bus"), selected = rv$destinations[[i]]$transport),
        textInput(paste0("dep_time", i), "Departure Time (HH:MM)", value = rv$destinations[[i]]$dep_time),
        textInput(paste0("arr_time", i), "Arrival Time (HH:MM)", value = rv$destinations[[i]]$arr_time)
      ))
    }
    do.call(tagList, ui_elements)
  })
  
  observeEvent(input$generate, {
    for (i in seq_along(rv$destinations)) {
      rv$destinations[[i]]$end <- input[[paste0("end", i)]]
      rv$destinations[[i]]$transport <- input[[paste0("transport", i)]]
      rv$destinations[[i]]$dep_time <- input[[paste0("dep_time", i)]]
      rv$destinations[[i]]$arr_time <- input[[paste0("arr_time", i)]]
    }
    
    start_point <- input$start
    end_point <- input$end
    transport <- input$transport
    dep_time <- ymd_hms(paste0("2023-01-01 ", input$dep_time, ":00"))
    arr_time <- ymd_hms(paste0("2023-01-01 ", input$arr_time, ":00"))
    total_time <- as.numeric(difftime(arr_time, dep_time, units = "mins"))
    
    hours <- total_time %/% 60
    minutes <- total_time %% 60
    
    graph_code <- create_graph_code(start_point, end_point, transport, input$dep_time, input$arr_time, hours, minutes)
    
    prev_end_point <- end_point
    prev_arr_time <- arr_time
    
    for (i in seq_along(rv$destinations)) {
      next_end_point <- input[[paste0("end", i)]]
      next_transport <- input[[paste0("transport", i)]]
      next_dep_time <- ymd_hms(paste0("2023-01-01 ", input[[paste0("dep_time", i)]], ":00"))
      next_arr_time <- ymd_hms(paste0("2023-01-01 ", input[[paste0("arr_time", i)]], ":00"))
      next_total_time <- as.numeric(difftime(next_arr_time, next_dep_time, units = "mins"))
      
      next_hours <- next_total_time %/% 60
      next_minutes <- next_total_time %% 60
      
      buffer_time <- as.numeric(difftime(next_dep_time, prev_arr_time, units = "mins"))
      
      buffer_label <- if (buffer_time > 59) {
        buffer_hours <- buffer_time %/% 60
        buffer_minutes <- buffer_time %% 60
        paste0("Buffer: ", buffer_hours, " hrs ", buffer_minutes, " mins")
      } else {
        paste0("Buffer: ", buffer_time, " mins")
      }
      
      graph_code <- paste0(
        graph_code,
        "\n\"", prev_end_point, "\" [label = <<B>", prev_end_point, "</B><BR/><FONT POINT-SIZE=\"10\">", buffer_label, "</FONT>>]",
        "\n\"", prev_end_point, "\" -> \"", next_end_point, 
        "\" [label=<<FONT FACE=\"Arial\">", next_transport, "</FONT><BR/>",
        "Dep: <B>", input[[paste0("dep_time", i)]], "</B><BR/>",
        "Arr: <B>", input[[paste0("arr_time", i)]], "</B><BR/>",
        "Time: ", if (next_hours > 0) paste0(next_hours, " hrs "), next_minutes, " mins>>]",
        "\n\"", next_end_point, "\" [label=<<B>", next_end_point, "</B>>]"
      )
      
      prev_end_point <- next_end_point
      prev_arr_time <- next_arr_time
    }
    
    graph_code <- paste0(graph_code, "\n}")
    
    output$route_chart <- renderGrViz({
      grViz(graph_code)
    })
    
    session$sendCustomMessage("adjustHeight", list(nDestinations = rv$count))
  })
  
  output$limit_message <- renderText({
    rv$limit_message
  })
}
