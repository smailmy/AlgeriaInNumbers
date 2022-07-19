# java -Dwebdriver.chrome.driver="C:\Users\smail\Downloads\chromedriver_win32\chromedriver.exe" -jar selenium-server-standalone-4.0.0-alpha-2.jar

library(tidyverse)
library(RSelenium)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  browserName = "chrome"
)

remDr$close()
remDr$open()

remDr$navigate("https://www.ouedkniss.com/automobiles/1?hasPrice=true")



i = 1
len_elements = 0

while (len_elements != 48) {
  
  webElem <- remDr$findElement("css", "body")
  webElem$sendKeysToElement(list(key = "end"))
  
  Sys.sleep(5)
  
  webElems <- remDr$findElements(using = "xpath", '//div[@class="d-flex flex-column full-h"]/a')
  listing_links <- unlist(lapply(webElems, function(x) {x$getElementAttribute("href")}))
  len_elements <- length(listing_links)
  
  i = i + 1
  
  
  
  if (i == 20) {
    break
  }
}

cat("Number of iterations:", i)
cat("Length of elements:", len_elements)





# listings_titles <- unlist(lapply(webElems, function(x) {x$getElementText()}))
# 
# listings_titles

listings = list()

for (j in listing_links) {
  
  remDr$navigate(j)
  
  Sys.sleep(5)
  
  feature_elements <- remDr$findElements(using = "css", ".grey--text")
  feature_list <- unlist(lapply(feature_elements, function(x) {x$getElementText()}))
  
  value_elements <- remDr$findElements(using = "css", ".col-7")
  value_list <- unlist(lapply(value_elements, function(x) {x$getElementText()}))
  
  # price_element <- remDr$findElements(using = "css", ".text-h6")
  # price_value <- unlist(lapply(price_value, function(x) {x$getElementText()}))
  
  location_element <- remDr$findElements(using = "css", ".py-2")
  location_value <- unlist(lapply(location_element, function(x) {x$getElementText()}))
  
  print(j)
  # print(value_list)
  
  # print("=======")
  # print(j)
  # print(length(feature_list))
  # print(length(value_list))
  # print(length(price_value))
  # print(length(location_value))
  # print("=======")
  # 
  single_listing_tbl <- tibble(feature_list, value_list) %>%
    bind_rows(c(feature_list = "location", value_list = location_value)) %>%
    pivot_wider(names_from = "feature_list", values_from = "value_list") %>%
    janitor::clean_names()
  
  listings = append(listings, single_listing_tbl)
  # 
  # 
  # init_tbl <- init_tbl %>%
  #   bind_rows(single_listing_tbl)
  
}

webElems[[2]]$click()



feature_elements <- remDr$findElements(using = "css", ".grey--text")
feature_list <- unlist(lapply(feature_elements, function(x) {x$getElementText()}))

value_elements <- remDr$findElements(using = "css", ".col-7")
value_list <- unlist(lapply(value_elements, function(x) {x$getElementText()}))

price_element <- remDr$findElements(using = "css", ".text-h6")
price_value <- unlist(lapply(price_value, function(x) {x$getElementText()}))

location_element <- remDr$findElements(using = "css", ".py-2")
location_value <- unlist(lapply(location_element, function(x) {x$getElementText()}))


init_tbl <- tibble(
  numero = character(),
  date = character(),
  vues = character(),
  boite = character(),
  finition = character(),
  modele = character(),
  marque = character(),
  papiers = character(),
  energie = character(),
  couleur = character(),
  moteur = character(),
  kilometrage = character(),
  annee = character(),
  # price = character(),
  location = character()
)

single_listing_tbl <- tibble(feature_list, value_list) %>% 
  bind_rows(c(feature_list = "price", value_list = price_value),
            c(feature_list = "location", value_list = location_value)) %>% 
  pivot_wider(names_from = "feature_list", values_from = "value_list") %>% 
  janitor::clean_names()


init_tbl <- init_tbl %>% 
  bind_rows(single_listing_tbl)

# API Method --------------------------------------------------------------


library(httr)

headers = c(
  'Content-Type' = 'application/json'
)

body = readLines('ok_auto_main_body.txt')

res <- VERB("POST", url = "https://api.ouedkniss.com/graphql", body = body, add_headers(headers))

cat(content(res, 'text'))


