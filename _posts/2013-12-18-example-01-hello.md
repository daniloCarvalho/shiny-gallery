---
layout: app
title: "01_hello"
date: 2013-12-18 09:27:35
tags: getting-started featured
app_url: "http://gallery.shinyapps.io/01_hello"
source_url: "https://gist.github.com/jjallaire/8021850"
---

This small Shiny application demonstrates Shiny's automatic UI updates.  Click
*Show Code* in the upper right, then look at the code for `server.R`. Move the
*Number of observations* slider and notice how the `renderPlot` expression is
automatically re-evaluated when its dependant, `input$obs`, changes, causing a
new distribution to be generated and the plot to be rendered.



