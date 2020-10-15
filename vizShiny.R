#shiny ui
ui <- dashboardPage(
  dashboardHeader(title = "NYC Weather & Crime"),
  dashboardSidebar(
    sidebarMenu(
      
      menuItem("Introduction", tabName = "introduction", icon = icon("info")),
      menuItem("Crime per Borough", tabName = "borough", icon = icon("globe")),
      menuItem("Crime Heat Map", tabName = "heatmap", icon = icon("fire")),
      menuItem("Crime & Weather", icon = icon("bar-chart"),
               menuSubItem('Crime by Month',tabName='month',icon = icon("calendar")),
               menuSubItem('Crime by Hour',tabName='hour',icon = icon("clock-o")))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "introduction",
              HTML('<center><img src="https://i.picsum.photos/id/149/3454/2288.jpg?hmac=JoHMBHymDuk59QWHK89nquWAXE4Su1mF07OKdvmpN3g" height = 300, width = 800></center>'),
              h1("Introduction", align = "center", style = "font-family: 'times'; font-si16pt"),
              h3("The data about weather is intrinsically interesting, 
                 it can be useful as well when it correlated with other types of data.", 
                 style = "font-family: 'times'; font-si16pt"),
              h3("There is such a scene in many movies, a man attacked a passer on a rainy day at night. 
                 Furthermore, crime always happens at night with bad weather in the real world. 
                 It means the potentially interesting connection between weather and crime.", 
                 style = "font-family: 'times'; font-si16pt"),
              h3("In this project, I will use real weather data and criminal records to determine the relationship between them. 
                 Both data sources come from New York City which is a big city in America.", align = "left", 
                 style = "font-family: 'times'; font-si16pt"),
              br(),
              h2("Data Source", align = "left", style = "font-family: 'times'; font-si16pt"),
              h4("a. Historical hourly weather data: https://www.kaggle.com/selfishgene/historical-hourly-weather-data#temperature.csv",
                 style = "font-family: 'times'; font-si16pt"),
              h4("b. NYPD complaint Data Historic : https://data.cityofnewyork.us/Public-Safety/NYPD-Complaint-Data-Historic/qgea-i56i",
                 style = "font-family: 'times'; font-si16pt")
      ),
      
      # Second tab content
      tabItem(tabName = "borough",
              h3("Crime per Borough in NYC", align = "center"),
              box(
                title = "Choropleth", status = "primary", solidHeader = TRUE, width = 9, height = 720,
                leafletOutput("map",height = 650, width = 830),
              ),
              box(
                title = "Information", status = "warning", solidHeader = TRUE, width = 3,
                "Choropleth:",br(), "Total number of crimes reported per borough", 
                br(), br(), "Pie Chart:", br(),"Three most common types of crime per boroug",
              ),
              box(
                title = "Control Panel", solidHeader = TRUE, width = 3, status = "primary",
                sliderInput("tab1year", "Year:", 2013, 2016, 1),
                checkboxInput("piecheck", "Display PieChart", TRUE),
              ),
      ),
      
      # Third tab content
      tabItem(tabName = "heatmap",
              h3("Common Crime in NYC", align = "center"),
              box(
                title = "Heat Map", status = "primary", solidHeader = TRUE, width = 9, height = 720,
                leafletOutput("heatmap",height = 650, width = 830),
              ),
              box(
                title = "Information", status = "warning", solidHeader = TRUE, width = 3,
                "Heat Map:",br(), "The geographical distribution of each common type of crime", 
                br(), br(), "*Note - Top 5 common types of crime",
              ),
              box(
                title = "Control Panel", solidHeader = TRUE, width = 3, status = "primary",
                sliderInput("tab2year", "Year:", 2013, 2016, 1),
                selectInput("crimetype", "Crime Type:", 
                            c("Petit Larceny" = "PETIT LARCENY", 
                              "Harrassment 2" = "HARRASSMENT 2",
                              "Assault 3 & Related Offenses" = "ASSAULT 3 & RELATED OFFENSES",
                              "Criminal Mischief & Related of" = "CRIMINAL MISCHIEF & RELATED OF",
                              "Grand Larceny" = "GRAND LARCENY")
                ),
                radioButtons("broughgroup", label = h3("Borough"),
                             choices = list("All" = 1, "Bronx" = "BRONX", 
                                            "Brooklyn" = "BROOKLYN", "Manhattan" = "MANHATTAN",
                                            "Queens" = "QUEENS", "Staten Island" = "STATEN ISLAND"), 
                             selected = 1),
              ),
      ),
      
      # Fourth tab content
      tabItem(tabName = "month",
              h3("Crime & Weather by Month", align = "center"),
              box(
                title = "Line and Bar Chart", status = "primary", solidHeader = TRUE, width = 9, height = 720,
                plotlyOutput("monthmap",height = 650, width = 830),
              ),
              box(
                title = "Information", status = "warning", solidHeader = TRUE, width = 3,
                "Line Chart:",br(), "Average tempeature per month", 
                br(), br(), "Bar Chart:", br(),"Total number of crimes per month",
              ),
              box(
                title = "Control Panel", solidHeader = TRUE, width = 3, status = "primary",
                sliderInput("tab4year", "Year:", 2013, 2016, 1),
              ),
      ),
      
      # Fifth tab content
      tabItem(tabName = "hour",
              h3("Crime & Weather by Hour", align = "center"),
              box(
                title = "Bar Chart", status = "primary", solidHeader = TRUE, width = 9, height = 720,
                plotlyOutput("hourmap",height = 650, width = 830),
              ),
              box(
                title = "Information", status = "warning", solidHeader = TRUE, width = 3,
                "Left Chart:",br(), "Total number of crimes per hour", 
                br(), br(), "Right Chart:", br(),"Average tempeature per hour",
              ),
              box(
                title = "Control Panel", solidHeader = TRUE, width = 3, status = "primary",
                sliderInput("tab5year", "Year:", 2013, 2016, 1),
              ),
      )
    )
  )
)

#shiny server
server <- function(input, output) {
  output$map <- renderLeaflet({
    #get the year from input
    syear <- input$tab1year
    
    #for design sheet 1
    #count the number of crime in each borough
    recentcrime <- crime[which(crime$year == syear),]
    crimeamount <- data.frame(table(recentcrime$BORO_NM))
    names(crimeamount)[1] <- "subregion"
    names(crimeamount)[2] <- "Total"
    crimeamount <- subset(crimeamount, crimeamount$subregion != "")
    
    #sort the frequency of each crime per borough
    freq <- data.frame(table(recentcrime$OFNS_DESC, recentcrime$BORO_NM))
    freq <- subset(freq,freq$Var2 != "") 
    freq <- arrange(freq, Var2, -Freq)
    #reshape the format
    freq <- reshape(freq, idvar = "Var2", timevar = "Var1", direction = "wide")
    names(freq)[1] <- "borough"
    names(freq)[2] <- "Petit Larceny"
    names(freq)[3] <- "Assault 3 & Related Offense"
    names(freq)[4] <- "Harrassment 2"
    names(freq)[5] <- "long"
    names(freq)[6] <- "lat"
    #add longtitude and latitude to each borough
    freq[1,5] = -73.865433
    freq[1,6] = 40.837048
    freq[2,5] = -73.949997
    freq[2,6] = 40.650002
    freq[3,5] = -73.96625
    freq[3,6] = 40.78343
    freq[4,5] = -73.769417
    freq[4,6] = 40.742054
    freq[5,5] = -74.151535
    freq[5,6] = 40.579021
    
    #load shapefile to plot the NYC map
    nyc = readOGR(dsn = "./shape", layer = "geo_export_3b66cf1e-ae12-4da2-b637-8f4be7fa6a0b") #name of file 
    
    #Add color difference 
    bins <- c(0, 20000, 50000, 100000, 120000, 140000, Inf)
    pal <- colorBin("YlOrRd", domain = crimeamount$Total, bins = bins)
    
    #add tooltips
    labels <- sprintf(
      "<strong>%s</strong><br/>%g reported crimes",
      crimeamount$subregion, crimeamount$Total
    ) %>% lapply(htmltools::HTML)
    
    #Display map with lengend and add some interactive features
    #Make a choropleths map
    crimemap <- leaflet(nyc) %>% 
      setView(-73.76942, 40.74205, 10) %>% 
      addPolygons(
        fillColor = ~pal(crimeamount$Total),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = FALSE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"))%>%
      addLegend(pal = pal, values = ~crimeamount$Total, opacity = 0.7, title = "Total Amount",
                position = "bottomright")
    
    if(input$piecheck){
      crimemap %>%
        addMinicharts(freq$long, freq$lat, type = "pie", 
                      chartdata = freq[, c("Petit Larceny", "Assault 3 & Related Offense","Harrassment 2")], 
                      width = 40, height = 40)
    }else{
      crimemap
    }
  })
  
  output$heatmap <- renderLeaflet({
    #get the year from input
    s2year <- input$tab2year
    recentcrime <- crime[which(crime$year == s2year),]
    
    #Get the specific crime from input
    ctype <- input$crimetype
    
    #clean the data to make sure that the data have NA's in the latitude or longitude.
    coordcrime <- recentcrime[which(!is.na(recentcrime$Latitude)),]
    nocoordcrime <- recentcrime[which(is.na(recentcrime$Latitude)),]
    commCrime <- coordcrime[which(coordcrime$OFNS_DESC == ctype),]
    
    #get the specific borough from input
    borough <- input$broughgroup
    if (borough != 1){
      commCrime <- commCrime[which(commCrime$BORO_NM == borough),]
    }
    
    #for design sheet 2
    # Another Leaflet
    heatPlugin <- htmlDependency("Leaflet.heat", "99.99.99",
                                 src = c(href = "http://leaflet.github.io/Leaflet.heat/dist/"),
                                 script = "leaflet-heat.js")
    registerPlugin <- function(map, plugin) {
      map$dependencies <- c(map$dependencies, list(plugin))
      map}
    
    #Create map new style
    commCrime %>%
      leaflet() %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB) %>%
      addWebGLHeatmap(lng=commCrime$Longitude, lat=commCrime$Latitude, size = 300)
  })
  
  output$monthmap <- renderPlotly({
    #get the specific from input
    s3year = input$tab4year
    converyear = s3year - 2000
    recentcrime <- crime[which(crime$year == s3year),]
    recentweather <- weather[which(weather$year == converyear),]
    
    #get the average temp and calculate the total reported crimes
    weatherresult <- aggregate( New.York ~ mon, recentweather, mean )
    names(weatherresult)[2] <- "m"
    crimeresult <- group_by(subset(recentcrime,recentcrime$mon != ""), mon) %>% tally()
    
    #draw them in the same plot
    combinemap <- ggplot(data = crimeresult, aes(x = mon, y = n, fill=as.factor(mon),
                                                 text = paste("Month: ", mon,
                                                              "<br>Amount:", n))) + 
      geom_col() + 
      labs(y = "Amount",
           x = "Month",
           colour = "Parameter") + 
      theme(legend.position="top", legend.title = element_blank())
    
    #another y-axis
    ay <- list(
      range=c(250,300),
      tickfont = list(size=11.7),
      titlefont= list(size=13),
      overlaying = "y",
      nticks = 3,
      side = "right",
      title = "Tempeature"
    )
    
    #using ggplot to add tooltips
    newmap <- ggplotly(combinemap, tooltip = "text") %>%
      add_lines(x=~mon, y=~m, colors= "green", yaxis="y2", name = "Average temp",
                data=weatherresult, showlegend=TRUE, inherit=FALSE, hoverinfo = 'text',
                text = ~paste("Temp:", m, " Fahrenheit")) %>%
      layout(yaxis2 = ay, yaxis = list(range=c(0,60000)), 
             legend = list(orientation = "h", x = 0.4, y = -0.2), margin = list( r = 30))
  })
  
  output$hourmap <- renderPlotly({
    #get the specific from input
    s4year = input$tab5year
    convertyear = s4year - 2000
    recentcrime <- crime[which(crime$year == s4year),]
    recentweather <- weather[which(weather$year == convertyear),]
    
    #get the average temp and calculate the total reported crimes
    weatherresult <- aggregate( New.York ~ shr, recentweather, mean )
    names(weatherresult)[2] <- "n"
    crimeresult <- group_by(subset(recentcrime,recentcrime$shr != ""), shr) %>% tally()
    b <- rbind(crimeresult, weatherresult)
    
    gmid <- ggplot(b,aes(x=1,y=shr,text = paste("Hour:", shr)))+geom_text(aes(label=shr))+
      geom_segment(aes(x=0.94,xend=0.96,yend=shr))+
      geom_segment(aes(x=1.04,xend=1.065,yend=shr))+
      ggtitle("")+
      ylab(NULL)+
      scale_x_continuous(expand=c(0,0),limits=c(0.94,1.065))+
      theme(axis.title=element_blank(),
            panel.grid=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            panel.background=element_blank(),
            axis.text.x=element_text(color=NA),
            axis.ticks.x=element_line(color=NA),
            plot.margin = unit(c(1,-1,1,-1), "mm"))
    
    g11 <- ggplot(data = subset(b,b$n > 400), aes(x = shr, y = n, 
                                                  fill=as.factor(shr), text = paste("Hour: ", shr,
                                                                                    "<br>Amount:", n))) +
      geom_bar(stat = "identity") +
      theme(axis.title.x = element_blank(), 
            axis.title.y = element_blank(), 
            axis.text.y = element_blank(), 
            axis.ticks.y = element_blank(), 
            plot.margin = unit(c(1,-1,1,0), "mm"),
            legend.position="none") +
      scale_y_reverse() + coord_flip()
    
    g22 <- ggplot(data = subset(b,b$n < 400), aes(x = shr, y = n, 
                                                  fill=as.factor(shr), text = paste("Hour: ", shr,
                                                                                     "<br>Temp:", n))) +
      xlab(NULL)+
      geom_bar(stat = "identity") +
      theme(axis.title.x = element_blank(), axis.title.y = element_blank(), 
            axis.text.y = element_blank(), axis.ticks.y = element_blank(),
            plot.margin = unit(c(1,0,1,-1), "mm"), legend.position="none") +
      coord_flip()
    
    ax1 <- list(
      range=c(250,300))
    
    ply0 <- ggplotly(gmid, tooltip = "text")
    ply1 <- ggplotly(g11, tooltip = "text")
    ply2 <- ggplotly(g22, tooltip = "text") %>%layout(xaxis = ax1)
    
    subplot(ply1,ply0,ply2,widths=c(4/9,1/9,4/9))

  })
}

shinyApp(ui, server)