
## What is Shiny?

Shiny is a framework to develop web-based front-ends for applications created in the R programming language. If you have a data-driven analysis written in R and want to create an exploration tool or dashboard using that R code, Shiny is a great option!

Shiny allows you to write both the front-end UI and back-end server in R. It provides functionality to easily connect these two pieces so that when a user interacts with the UI (like a button or a drop down), variables, charts, and other pieces of the server that depend on that changed UI are automatically updated and reflected back in the UI.

## Reactive Programming in Shiny

Shiny uses [Reactivity](https://shiny.rstudio.com/articles/reactivity-overview.html) to achieve this connection between the server and the UI. Concretely, you chunk up your server code in to little pieces and indicate the input dependents for each of these chunks.

A quick example. Say we want a drop-down input in our UI to specify a year. We can create this using the Shiny [selectInput](https://shiny.rstudio.com/reference/shiny/latest/selectInput.html) function.

```R
selectInput("year",
            "Year:",
            c("2015", "2016", "2017"),
            selected = "2015")
```

The important piece of this code is that first input parameter `"year"`. This specifies the `inputId` of the UI component.

In our server portion of the application we will use this `inputId` to indicate that a particular block of server code depends on this input. For example, if we had some data that we wanted to filter by this input year, we could do this using the [reactive](https://shiny.rstudio.com/reference/shiny/latest/reactive.html) function to create a reactive function:

```R
shinyServer(function(input, output) {

  filtered_data <- reactive({
    raw_data %>% filter(year == input$year)
  })

})  
```

The `input` parameter of the `shinyServer` callback function is where all our UI inputs are stored. `reactive` takes a block of code, here its only one line but it could be longer. The binding between UI and server occurs because of the use of `input$year`.

So when our input with an `inputId` of `year` is updated, this reactive block of code will be re-run with the new value, and thus `filtered_data` will be updated. Pretty cool!

## Rendering Output

So the example above provides for modifying a variable of the server code based on a UI input, but how do we send something back to the UI based on this change? Thats where Shiny's suite of `render` functions come into play.

Continuing the above example, say we wanted to use the now `filtered_data` to generate a ggplot plot of say count by month (we can assume for the sake of simplicity that these counts are already part of the data). We can use [renderPlot](https://shiny.rstudio.com/reference/shiny/latest/renderPlot.html) to create a new shiny plot and assign it as an attribute of the `output` list of our `shinyServer` function.

It looks something like this:

```R
output$monthPlot <- renderPlot({
  filtered_data() %>%
    ggplot(aes(x = month, y = count)) +
    geom_bar(stat = "identity") +
    labs(title = "Counts Per Month")
})
```
Here `monthPlot` becomes the `outputId` of this piece of output. Because it uses `filtered_data`, a "reactive" variable, Shiny will re-run the chunk of code passed into `renderPlot` every time `filtered_data` is updated.

An important gotcha here is that due to the details of implementing reactive variables, `filtered_data` is actually a **function** that we call in order to get the updated data, hence the `()` at the end. 

The last piece of the puzzle is to go back to the UI portion of the app and indicate where this plot should be displayed. For that we use [plotOutput](https://shiny.rstudio.com/reference/shiny/latest/plotOutput.html).

So, together with our original `selectInput`, a basic UI for this app would be:

```R
shinyUI(fluidPage(

  selectInput("year",
              "Year:",
              c("2015", "2016", "2017"),
              selected = "2015"),
  plotOutput("monthPlot")
))
```

Here the [fluidPage](https://shiny.rstudio.com/reference/shiny/latest/fluidPage.html) function generates the HTML for a page with fluid layout. R functions like this one and `selectInput` that generate HTML for creating fully featured UIs are a big part of the Shiny library. Check out the [API Reference](https://shiny.rstudio.com/reference/shiny/latest/) for the various layout and input functions, as well as the [tags](https://shiny.rstudio.com/reference/shiny/latest/builder.html) functions for building up custom HTML.

Note how we are using the plots `outputId`: `monthPlot` to reference which plot is to be plotted. You can imagine repeating this paradigm any number of times to create a variety of plots (and other outputs like [tables](https://shiny.rstudio.com/reference/shiny/latest/tableOutput.html)) for your users to consume and interact with.

## Expanding Shiny Functionality

Speaking of interactivity, the base Shiny functions provide a lot of boiler-plate capabilities for generating these R-backed UIs, but you soon start to wonder how to create more interactive components for your displays. Well, you are in luck! There is an additional growing collection of these HTML and JS generating R functions in the [htmlwidgets](http://www.htmlwidgets.org/) package.

For example, you could use the [leaflet](http://rstudio.github.io/leaflet/) htmlwidget to add a slippy map to your Shiny app that can be panned and interacted with, just as if you coded it up in raw Javascript. As an additional benefit, most of these widgets have [Shiny integration instructions](http://rstudio.github.io/leaflet/shiny.html) to get you up and going quickly.

## The Future is Shiny

All in all, Shiny offers a compelling framework and toolkit for building powerful R-powered applications that can be accessed via the web.

bla bla bla....
