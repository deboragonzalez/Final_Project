
# Florida's Population & Politics Project
# By: Debora Gonzalez


# These libraries are necessary for the functions and themes used in this app.

library(tidyverse)

# General functions to organize data.

library(readxl)

# Necessary to read in the data.

library(gt)

# To be used in designing and formatting a table.

library(tigris)

# Contains the map files used for the map portion of the app

library(ggthemes)

# Contains the theme I want to use to design my plots/graphs.

library(sf)

# Allows me to work with the Tigris map files.

library(fivethirtyeight)

# Contains the party color schemes I want to use to color my graphics.

library(plotly)

# Provides helpful mapping tools with interactive tooltip.

library(scales)

# Allows to convert the axis number labels into regular notation.

library(viridis)

# Allows to color by scale.

library(DT)

library(shiny)
library(shinythemes)
library(shinyWidgets)


# Provides the background for the app.



# Data Setup: 
# These datasets have been cleaned and built for the purpose of this app. The
# original (raw) data can be found in the Github repository for this app and its
# Background Script file.

party_affiliation_years <- read_rds("party_affiliation_years")

# Dataframe containing voter registration of FL voters by party as
# of Feb. 2019 from 1972 to 2019.

data_by_county <- read_rds("data_by_county")

# SF dataframe containing number of registered voters by party, dominant party,
# median family income, percent foreign born, and geometry variables. To be used
# in mapping.

no_geometry_county <- read_rds("no_geometry_county")

# Dataframe with same information as above, but without the geometry variable
# that made the file SF.

# Defining UI for multi-tab, interactive application 

ui <- fluidPage(
  
  setBackgroundImage(src = "https://www.xmple.com/wallpaper/gradient-white-linear-purple-1920x1080-c2-8a2be2-f5fffa-a-90-f-14.svg"),
  
    # Choosing theme: after exploring the options, journal seemed like the most
    # fitting and aesthetically pleasant
  
   theme = shinytheme("yeti"),
  
   
   # Application title
   
   titlePanel("The 'Purple' Sunshine State: Florida's Population & Politics"),
   h4("A View into Florida's Political Arena"),
  
  # The navbarPage creates the tab layout for each tabpanel that can have
  # subtabs insides
   
   navbarPage("",
      
      # The panel outlines the number of tabs and output functions (by
      # type) the app will have. Each key will be used to render the respective
      # object in the server part of the app.
      
            tabPanel(h4("Florida by County: Political Allegiance & Demographics"),
                     h4("Hover over each county to learn about some of its demographic trends."),
                       
                     # The first line is the tab title, the second line is text
                     # in the general tab.
                     
                     tabsetPanel(
                         tabPanel(h4("Political Map"), htmlOutput("map1"), 
                                  plotlyOutput("map_fl"), br(), br(),
                                  h5("Note that the maps in this app do not account for independent or third-party registered voters. 
                                     The allegiance and color of each county are selected based on the party with the greater raw 
                                     number of registered voters respectively. It is not representative of independent registered voters 
                                     or their allegiance. As a result, counties can turn red or blue on Election Day regardless of their 
                                     allegiance on this map.")),
                         
                         # By opening a tabset panel I can create subtabs under
                         # the previously created tab panel. I use html output
                         # to format the map title text outside the map panel
                         # itself. I then determine the key for the map, add
                         # some space, and add caption text to this tab. The
                         # text relates to the content of the map (and
                         # selections made).
                         
                         tabPanel(h4("Demographic Map"), 
                                  htmlOutput("map2"),
                                    sidebarPanel(
                                      selectInput("select_demo",
                                                "Select Demographic:",
                                                choices = list("Median Family Income" = "dollar",
                                                               "Foreign Born Population" = "percent"),
                                                multiple = FALSE)),
                                  mainPanel(plotlyOutput("map_fl2"),  
                                          h5("Note that the maps in this app do not account for independent or third-party registered voters. 
                                              The allegiance of each county is selected based on the party with the greater raw 
                                              number of registered voters respectively. It is not representative of independent registered voters 
                                              or their allegiance. As a result, counties can turn red or blue on Election Day regardless of their 
                                              allegiance on this map."))))),
      
                          # This tabpanel under the tabset for the page tab
                          # shows a demographic map. Again, html output is used
                          # to title the map. The sidebar panel is so that the
                          # viewer can choose what demographic variable he/she
                          # wants to see. After it is set up, a main Panel tab
                          # can include the map output and the additional
                          # captioning text. Putting the sidebar inside the main
                          # panel can overlap the map and the select widget.
                          # Then, the main panel closes and so does the tab
                          # panel for demographic map, the map tabset, and the
                          # navigation tab page.
            
      
            # This is a new tab page on the navigation bar. 
      
            tabPanel(h4("Political Allegiance over Time"),
                    
                      sidebarPanel(
                        sliderInput("year", 
                                    label = h4("Select Years:"), 
                                    min = min(unique(party_affiliation_years$year)), 
                                    max = max(unique(party_affiliation_years$year)),
                                    value = c(1972, 2019),
                                    sep = ""),
                      
                      # Sidebar with a slider input for years between 1972 to 2019 Using the years
                      # variable from the party_affiliation_years dataset I can create a slider
                      # that will control the number of bars appearing in the bar plots to follow
                      # and the zoom option in the line plot, which essentially show the defined
                      # range of years. It allows the viewer to observe gradual trends and more
                      # detailed year to year changes.
                      
                         selectInput("select_party", 
                                     label = h4("Select Party:"),
                                     choices = list("Republican Party" = "republican_party_of_florida",
                                                    "Democratic Party" = "florida_democratic_party"),
                                     multiple = FALSE)),
                      
                      # In this case, the selectInput maps to a bar graph
                      # showing changes in number of registered voters over
                      # time. The viewer can change to which party s/he wants to
                      # see.
                      
                    mainPanel(h3("Take a look at the trends:"), br(),
                              plotOutput("percents"), 
                              h6("This graph shows the percentage of registered republican, democrat, and independent voters. 
                                 The increase in independent voters adds to the ambivalent political arena in Florida"), br(),
                              plotOutput("parties"), br())),
      
                    # The main panel shows the output keys for each of the
                    # graphs in this tab. I also add some text as a caption to
                    # the line graph. The text is added in the order it should
                    # appear in the output between the appropriate keys.
      
      
            # This navigation tab shows a complete fully formatted table with
            # the clean and tidy data used in this project. It uses gt output in
            # order to fully format the table to the viewer's benefit.
      
            tabPanel(h4("A Deeper Look at the Numbers"),
                             gt_output("county_table")),
      
      
            # This last navigation tab tells the viewer about the project, the
            # data sources, the assumptions and limitations as well as provides
            # information about the developer.
      
            tabPanel(h4("About this Project"),
                          htmlOutput("text"))
   ))

# Define server logic required to draw the app

server <- function(input, output) {
  
  # The map is made with a composite dataframe that includes all by county
  # dataframes and the shape files from the tigris package. It is a ggplot -
  # geom_sf embedded in a ggplotly, which allows for the hover tooltip, which
  # provides useful political and demographic data about each county to be
  # displayed as the viewer hovers over each county respectively. After
  # assigning my ggplot to the data_by_county dataframe, I set "text" equal to
  # the variables I want to display in my tooltip in the aesthetics. It is set
  # using the call "paste()", html syntax, and a comma after each object. The
  # text to be displayed goes in " " and so does the html space code. The
  # variables are not coded. After, we set fill (inside shape color) equal to
  # party_control (binary variable that indicates whether a county is majority
  # democrat or republican) in the geom_sf aesthetics. This helps to fill in
  # with party colors later on. I use theme_map to ensure a map axis and
  # lightened grid. I then use theme_economist to maintain font & aesthetic
  # uniformity throughout the project. Because I am coloring this map by party
  # allegiance of counties, I use scale_fill_fivethirtyeight, which
  # automatically recognizes a party related variable and assigns it party
  # colors. I use fill and not color because color only colors borders, so I
  # leave that with default settings. I use the labs to explain the graphic and
  # make fill - NULL because it's not necessary to have a legend title given
  # that the colors are labeled and are self-explanatory from the title. The
  # theme function helps to clean up the background, axis, ticks, box border
  # lines, etc. I made both the grid and plot background transparent to get rid
  # of both the plot lines and the map grid. After extensive research, I figured
  # out the syntaxt for each call. Setting axis.ticks, axis.text, and line to
  # element_blank() puts the map on a clear background, which accentuates the
  # map shape and colors for the purpose of data display. After theme, I place a
  # comma and call tooltip setting it equal to "text", so that it will show the
  # variable values & text I identified earlier in ggplot aesthetics and not the
  # fill variable from geom_sf. The other two maps use the same steps except
  # they color by different variables to visually examine the geographic
  # distribution of each variable. 
  
  
  output$map1 <- renderText({"<h4><b>County Partisanship by Majority of Registered Voters</b></h4>"})
  
  output$map_fl <- renderPlotly({ 
    ggplotly(ggplot(data = data_by_county, 
                    aes(text = paste(NAMELSAD, "<br>", 
                                     "Major Party:", party_control, "<br>", 
                                     "Foreign Born Population:", percent,"%", "<br>", 
                                     "Median Family Income: $",dollar))) +
               geom_sf(aes(fill = party_control)) +
               theme_map() + 
               theme_economist() + 
               scale_fill_fivethirtyeight() +
               labs(title = "", 
                    subtitle = "Hover over each county to learn about some of its demographic trends.",
                    fill = NULL) +
               theme(
                 panel.grid.major = element_line(colour = 'transparent'), 
                 line = element_blank(),
                 axis.text = element_blank(),
                 axis.ticks = element_blank(),
                 plot.background = element_rect(fill = "transparent")), 
             tooltip = c("text"))
  })
  
  
  output$map2 <- renderText({"<h4><b>Median Family Income & Percent of Foreign Born Population Across Florida by County</b></h4>"})
  
  output$map_fl2 <- renderPlotly({ 
    
    if(input$select_demo == "dollar") {
      ggplotly(ggplot(data = data_by_county, 
                      aes(text = paste(NAMELSAD, "<br>", 
                                       "Major Party:", party_control, "<br>", 
                                       "Foreign Born Population:", percent,"%", "<br>", 
                                       "Median Family Income: $",dollar))) +
                 geom_sf(aes(fill = dollar)) +
                 theme_map() + 
                 theme_economist() + 
                 labs(title = "", 
                      subtitle = "Hover over each county to learn about some of its demographic trends.",
                      fill = NULL) +
                 scale_fill_viridis("Median Income ($)") +
                 theme(
                   panel.grid.major = element_line(colour = 'transparent'), 
                   line = element_blank(),
                   axis.text = element_blank(),
                   axis.ticks = element_blank(),
                   plot.background = element_rect(fill = "transparent")), 
               tooltip = c("text"))}
    
    else{ggplotly(ggplot(data = data_by_county, 
                         aes(text = paste(NAMELSAD, "<br>", 
                                          "Major Party:", party_control, "<br>", 
                                          "Foreign Born Population:", percent,"%", "<br>", 
                                          "Median Family Income: $",dollar))) +
                    geom_sf(aes(fill = percent)) +
                    theme_map() + 
                    labs(title = "", 
                         subtitle = "Hover over each county to learn about some of its demographic trends.",
                         fill = NULL) +
                    theme_economist() +
                    scale_fill_viridis_c("Foreign Born Percent (%)") +
                    theme(
                      panel.grid.major = element_line(colour = 'transparent'), 
                      line = element_blank(),
                      axis.text = element_blank(),
                      axis.ticks = element_blank(),
                      plot.background = element_rect(fill = "transparent")), 
                  tooltip = c("text"))}
    
    # The if/else loop allows for the inclusion of each graphic according to the
    # viewer's preference/selection. It connects the select widget key to the
    # data output.
    
  })
  
  # Percent of registered voters by party
  
  # In order to prepare my data to be plotted, I will create a new object
  # (dataframe), which I will later use to graph. This plot aims to show the
  # percent changes in registered voters over time. To do so, I mutate the
  # variables that correspond to the number of registered republicans,
  # democrats, and others by dividing their values by the total number of
  # registered voters (variable total) and then multiplying by 100. Then, I
  # filter so that the graph only shows the output for the years inputted in the
  # slider built above. To do so, we filter the variable year input$"key". Then,
  # we are ready to build the ggplot. We will use the modified dataset we
  # created, so its name (party_percents) goes inside the ggplot call. This
  # graph requires three geom_lines, one for each "party". The labs and theme
  # provide a professional aesthetic and guide the viewer in his/her analysis.
  # The scale_y_continuous command is used to ensure the y axis labels are not
  # in scientific notation.
   
  output$percents <- renderPlot({
    party_percents <- party_affiliation_years %>% 
      mutate(percent_dem = (florida_democratic_party/total)*100) %>% 
      mutate(percent_rep = (republican_party_of_florida/total)*100) %>% 
      mutate(percent_other = (other_or_no_party_affiliation/total)*100) %>% 
      filter(year >= input$year[1] & year <= input$year[2])
    
    ggplot(party_percents) +
      geom_line(aes(x =year, y = percent_rep,  color = "Republican"), size = 1) + 
      geom_line(aes(x = year, y = percent_dem, color = "Democrat"), size = 1) +
      geom_line(aes(x = year, y = percent_other, color = "Independent"), size = 1) +
      scale_color_manual(values = c("Republican" = "red3", "Democrat" = "blue4", "Independent" = "green")) +
      labs(y = "Percentage of Registered Voters",
           x = "Year Range",
           title = "Changes in Political Allegiance Over Time",
           color = "Party Allegiance:") + 
      theme_economist() +
      scale_y_continuous(labels = comma)
    })
  
  
  # The following two bar plots are structurally the same and show the raw
  # number of registered voters over time for the two major parties
  # respectively. The new subset created takes the party_affiliation_years
  # dataset and filters it for the inputted years (the same way as in the line
  # graph above) to ensure the plot outputs the data for the years selected. The
  # ggplot refers to the newly created data subset. It contains the filtered
  # year on the x axis and the registered number of voters (of the corresponding
  # party) on the y axis. On the geom_bar aesthetics, I assign fill (the inside
  # coloring) to party color (red for Republicans and Blue for Democrats) and
  # the color (the borders/outline) itself to black to facilitate visual
  # clarity. I decided not to label the y axis because the title of the graph
  # makes it self-explanatory. I use theme_economist for aesthetic consistency
  # and the scale_y_continuous call to avoid scientific notation. Using the
  # inputselect call from the ui with an if/else statement makes it so that the
  # viewer can choose what party's trend to analyze.
  
   output$parties <- renderPlot({
    
     gop_subset <- party_affiliation_years %>% 
       filter(year >= input$year[1] & year <= input$year[2])
     
     if(input$select_party == "republican_party_of_florida") {
     
     ggplot(gop_subset, aes(x = year, y = republican_party_of_florida)) + 
       geom_bar(stat="identity", fill = "red", colour = "black") +
       labs(y = NULL,
            x = "Year Range",
            title = "Number of Registered Republicans over Time") + 
       theme_economist()+
       scale_y_continuous(labels = scales::comma)}
     
     else{ggplot(gop_subset, aes(x = year, y = florida_democratic_party)) + 
         geom_bar(stat="identity", fill = "blue", colour = "black") +
         labs(y = NULL,
              x = "Year Range",
              title = "Number of Registered Democrats over Time") + 
         theme_economist()+
         scale_y_continuous(labels = scales::comma)}
       })
 
     
     
     output$county_table <- render_gt({
       
       # This table shows the numerical data we have been exploring through the
       # interactive map in the previous tab. It utilizes the dataframe that was
       # transformed into a tibble in the background script. 
       
       no_geometry_county %>% 
         select(NAMELSAD, florida_democratic_party, republican_party_of_florida, party_control, percent, dollar) %>%
         mutate(percent = percent/100) %>% 
         
         # I'm mutating the variable percent into a percent decimal so that I
         # can later use fmt_percent to give it proper percent formatting.
         
         gt() %>% 
         tab_header(title = "The Purple State in Numbers",
                    subtitle = "Politics & Selected Demographics in Florida by County") %>% 
         tab_spanner("Registered Voters", columns = vars(florida_democratic_party, republican_party_of_florida)) %>% 
         cols_label(NAMELSAD = "County",
                    florida_democratic_party = "Democrat",
                    republican_party_of_florida = "Republican",
                    party_control = "Dominant Party",
                    percent = "Percent of Foreign Born",
                    dollar = "Median Family Income") %>% 
         
         # Once the table is a gt, I add a title and subtitle that guide the
         # viewer in understanding the data at hand. I can use tab_spanner and
         # cols_label to name and group my variables.
         
         tab_footnote(footnote = "Florida's weighted median annual income is $61,442. The average median income of all counties is $57,448.",
                      locations = cells_column_labels(
                        columns = vars(dollar))) %>%
         tab_footnote(footnote = "Florida's weighted average of foreign born population is 20.2%. The unweighted average of all counties is 9.6%.", 
                      locations = cells_column_labels(
                        columns = vars(percent))) %>% 
         
         # These numbers are taken from the U.S. Census data. Including them as
         # footnotes is a useful tool, so I made the footnote refer to the
         # column/variable itself.
         
         fmt_currency(columns = vars(dollar)) %>% 
         fmt_percent(columns = vars(percent), 
                     decimals = 1) %>% 
         fmt_number(columns = vars(florida_democratic_party, republican_party_of_florida),  
                    decimals = 0) 
       
         # These last few lines provide a professional look to the data table by
         # formatting each number with its corresponding labels (percent,
         # commas, etc.
       
       
       })
     
     # I used htmlOutput to render formatted text using html syntax. The first tab
     # shows a brief description of the project, the raw data sources,
     # acknowledgements, and a link to the repository.
     
     output$text <- renderText({
       
       "<h3><b>The Sunshine State Turns Purple on Election Day</b></h3>
       <h4> Data Visualization Project at Harvard University </h4>
       <h5> By: Debora Gonzalez </h5> 
       <br/>
       <p>This project explores Florida's political allegiance changes from 1972 to the present 
       and highlights selected demographic trends that may relate to party affiliation in the Sunshine State. </br> </br> 

       Click on the different tabs to learn more about Florida's demographics and politics. </br> </br>

       The maps and graphics in this app do not account for independent or third-party registered voters when 
       determining the 'allegiance' of counties. The allegiance and/or color of each county are determined based 
       on the party with the greater raw number of registered voters respectively. It is not representative of 
       independent registered voters or their allegiance. As a result, counties can turn red or blue on Election 
       Day regardless of their allegiance on this map.</br> </br>

       Florida, as a southern state, has an inherent Democratic bias. This bias stems from the state's historical context. 
       In the pre-FDR era, most southern states were majority Democratic. The party ideology switch left many previously 
       registered democratic voters voting Republican on election day. Over time, this influence, or bias, has diminished, 
       but can still be observed in the graphics showing voter registration trends over time. In addition, the increasing 
       number of independent registered voters denoted in the Allegiance Over Time section of this app are significant in 
       explaining the 'purple' nature of Florida's political arena. These registered voters are actively participating in 
       political decisions, but do not label themselves with a political affiliation, which makes them 'volatile' and very 
       much necessary to win the state.</p></b> <br/>
       
       Using data from: <br/>
       <ul>
       <br/><li>U.S. Census Bureau, 2013-2017 American Community Survey 5-Year Estimates 
       
       <ul>
       <li>Median Family Income (In 2017 Inflation-Adjusted Dollars): State -- County </li>
       <li>Percent Of People Who Are Foreign Born: State -- County </li>
       </ul>
       </li>
       <br/><li>Florida Department of State - Division of Elections Voter Registration
       
       <ul>
       <li>Registration reports by County (2019) </li>
       <li>Registration reports by County and by Party (1972-2019) </li>
       </ul>
       </li>
       <br/><li>Tigris R Package: Shapes files - by County, State #12 </li>
       </ul>
       <br/>
       <b> A special thank you to Dr. David Kane and Albert Rivero for extensive feedback in the creation of this project.</b></br>
       <p></p>
       <a href='https://github.com/deboragonzalez/Purple_Sunshine_State'>Learn more about this project: Github</a>
       <br/> <br/>
       <h5> Contact the developer: <h5/>
       Email Debora: deboragonzalez@college.harvard.edu
       <br/> <a href='https://www.linkedin.com/in/debora-gonzalez'>Connect with Debora on LinkedIn</a>
       <br/> <br/>"})
     
}

# Run the application 
shinyApp(ui = ui, server = server)

