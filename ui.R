ui <- navbarPage(
  
  title = "Used Car on Ebay Kleinanzeigen", 
  
  tabsetPanel(id = 'selected_tab',
              tabPanel("Company", uiOutput("company_info")), 
              tabPanel("Car", uiOutput("car_info")), 
              tabPanel("Prediction", uiOutput("price_prediction"))
  )
  
)