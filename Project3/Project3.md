<html> 
  <head> 
  </head> 
  
  <body>
  <h5> App Link </h5> 
  <a href = "https://vivekb.shinyapps.io/Project3/"> Shiny Apps Project 3 Link (Was not uploaded to shiny apps this time)</a> 
  <br>
  <br>
  <div class = "description">
    <h3> Introduction and Description </h3> 
    <p> Project 3 is a project focused on learning how to develop shiny app web applications for data manipulation and visualization. However, Project 3 adds onto the concepts covered in Project 3 and adds more complex graphing capabilities especially when it comes to maps. Some of the things covered within this app is learning how to import data, manipulate said data and then create a user interface for visualizing the data with mapview maps. </p> 
    
   <br> 
    
   <p>  The project focuses on visualizing the energy usage and other demographics for chicago looking at the data for 2010 per block and tract regionally. There is a focus on 2 resources overall: Electricity and Gas. Other demographics pertain to population factors and to the buildings themselves: population, total population, renter population, building stories, and building age. </p> 
   
   <br> 
   
   <p> The first page displays the demographics for the Near West Loop within Chicago in the year 2010 and allows the user to toggle through the selection options to see the information per block. </p> 
   
   <br> 
   <figure> 
    <img src="Project3_images/First_Page.png"> 
  <figcaption> A picture of the first tab that shows the Near West Loop Blocks  </figcaption> 
  </figure>  
   
   <br> 
   
   <p> The second page allows the user to interact with two different communities and the user is allowed to choose energy sources and other demographics to compare between the two. They are able to select the same location and compare the different information or different sources for instance. The user is also able to select multiple different energy sources, multiple demographics, and two different locations for comparison. The data displayed shows mapview plots for blocks in 2010 per the 77 communities in chicago. The mpaview plot allows for the user to see the actual contribution of each block by hovering over and clicking each block and seeing the visual size of each block contribution. </p> 
   <br> 
   
   <figure> 
    <img src="Project3_images/Second_Page.png"> 
  <figcaption> A picture of the second tab that shows the state to state comparison data charts </figcaption> 
  </figure> 
   <br> 
   <p> Finally the user is allowed to compare the energy sources by a range of production values while looking at the US holistically.   </p>
    <br> 
    
    <figure> 
      <img src="Project2_images/Third_Page.png"> 
      <figcaption> A picture of the third tab that shows the energy production for the US </figcaption> 
    </figure> 

  <br>
  <p> There is an about page on the fourth tab. </p> 
  </div>
  
  <br>
  <br>
  
  <div class = "data_description"> 
  <h3> Data Processing </h3> 
  <p> 
  The data was collected from the US Energy Protection Agency. The dataset was the net generation of energy organized by State and Type of Producer and Plant Coordiantes. The website had data for almost every year so a more indepth time series could have been performed.  
  </p> 
  <br>
  <figure> 
    <img src="Project2_images/data_cleaning.png"> 
  <figcaption> A picture of the that shows the commands done to the dataset in R to clean the data</figcaption> 
  </figure> 
  <br>
  <p> 
    The initial data manipulation done to the dataset involved cleaning up the dataset such that it was easier to handle and more focused on the information trying to be collected.
  </p> 
  <br> 
  <p> 
    The first steps in cleaning up the data involved converting the dataset to the proper format. In this case certain features such as the GENERATION column was read in as string where in actuality it was a numeric value used to measure the production amount for the data. The other columns were converted to be more friendly values by converting them to factors. 

</p> 

<br> 
<p> 
  The second step involved missing data and incorrectly labeled data. There was a lot of missing data that needed to be filled in with 0s. The data was also problematic as it had minor issues here and there that led to issues with the information being problematic such as the longitude values being negative which needed to be adjusted.   
  </p> 
  <br> 
  <p> 
  The final measure was calculating the percents for each type of energy source and calculating those values for all the dataset. 
    </p> 
  </div> 
  
  <br> 
  <br> 
  
  <div class="instructions">
  <h3> Instructions to operate </h3>  
  <a href="https://github.com/Vivek2018/CS424Project2"> Github Project Repo </a> 
  <p> 
    To run this project there are a few requirements: <br> 
    1) Correct libraries and proper library versions
    2) Downloading the repo and opening the R project to start an R-Studio session
    3) Going to https://www.epa.gov/egrid/download-data
    4) Downloading the data for 2000, 2010, 2018 
  </p>
  <br> 
  <p> These instructions are enough to get the project working, however to make sure everything is compatable it is assumed that you have R-Studio and Shiny Apps already installed. Otherwise the user will need to install said software beforehand. There are a lot of libraries involved within the project so it is best to have everything up to date with this project. <br>

The libraries include: <br> 
library(shinydashboard) <br> 
library(shiny) <br> 
library(leaflet) <br> 
library("readxl") <br> 
library(rgeos) <br> 
library(maps) <br> 
library(mapdata) <br> 
library(maptools) <br> 
library(ggthemes) <br> 
library(ggmap) <br> 
library(sp) <br> 
library(stringr) <br> 
library(plyr) <br> 
  </p>
  </div>
  
  <br> 
  <br> 
  
  <div class="facts"> 
  <h3> Interesting Features </h3> 
  <p> 
    The data showed interesting trends in terms of the growth in energy and specific usages of energy. Historical technological growth and environmental preservation motivations are easily seen in the data. Another thing that can be seen is the lack of natural resources and drop in their usage overtime. 
    </p> 
<br> 
  <p> 
    The most notable trend that you can see is overall growth in all energy forms but specifically renewable energy becoming a large factor for energy production within the US. 
  </p> 
  <figure> 
    <img src="Project2_images/energy.png"> 
  <figcaption> A picture displaying the overall growth in the energy over time </figcaption> 
  </figure> 
  <p> 
    There is a drop off in some energy sources that can be explained with an increase in other more green technologies. With a larger focus on remaining environmental friendly some energy sources have been utilized more and other energy sources are dropping off.
  </p> 
  <br> 
  <p> 
    For instance when looking at energy sources such as coal and its usage over time you can see that there were more plantations to created but the overall production capability of the coal plantations were reduced. However, wind across Illinois went from nonexistent to becoming heavily used in the span of 2000 to 2018. 
  </p> 
  <br> 
  
  
  <figure> 
    <img src="Project2_images/coal.png"> 
  <figcaption> A picture of the coal data demonstrating the drop off in usage and production </figcaption> 
  </figure> 
  <br>
  <figure> 
    <img src="Project2_images/wind.png"> 
  <figcaption> A picture of the wind energy demonstrating the increase in usage and production </figcaption> 
  </figure> 
  <br>
  <br>
  <p> 
    In contrast energies like solar, hydro, and wind sky rocket in usage in the more recent years to compensate for energy production that nonrenewable resources have dropped off in. 
  </p>
  <br> 
  <figure> 
    <img src="Project2_images/energy.png"> 
  <figcaption> A picture of the renewable energy demonstrating the increase in usage and production </figcaption> 
  </figure> 
  </div> 
  <br>
  <br>
  <div class="video"> 
  <h3> Youtube Video </h3> 
  <a href="https://youtu.be/iCxduwXcf1s"> Youtube Video Link </a> 
  <br>
  <br>
  <iframe width="420" height="345" src="https://www.youtube.com/embed/iCxduwXcf1s">
  </iframe>
  </div>
  </body>
 </html>
