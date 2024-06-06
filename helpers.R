create_graph_code <- function(start_point, end_point, transport, dep_time, arr_time, hours, minutes) {
  paste0(
    "digraph route {",
    "\nnode [shape=box, style=filled, color=lightblue]",
    "\nedge [color=blue, arrowhead=vee, style=bold]",
    "\n\"", start_point, "\" [label=<", start_point, ">]",
    "\n\"", start_point, "\" -> \"", end_point, 
    "\" [label=<",
    "<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\">",
    "<TR><TD>", transport, "</TD></TR>",
    "<TR><TD>Dep: <B>", dep_time, "</B></TD></TR>",
    "<TR><TD>Arr: <B>", arr_time, "</B></TD></TR>",
    "<TR><TD>Time: ", if (hours > 0) paste0(hours, " hrs "), minutes, " mins</TD></TR>",
    "</TABLE>>]",
    "\n\"", end_point, "\" [label=<", end_point, ">]",
    "\n}"
  )
}
