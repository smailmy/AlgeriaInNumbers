# API Method --------------------------------------------------------------
library(jsonlite)
library(tidyverse)
library(bigrquery)
library(DBI)

project_id <- "algeria-in-numbers"
dataset <- "automobiles"

con <- dbConnect(
  bigrquery::bigquery(),
  project = project_id,
  dataset = dataset,
  billing = project_id
)

source('main_post_request.R')

res <- get_main_listings()

parsed <- fromJSON(content(res, 'text'), flatten=TRUE)

last_datetime <- dbGetQuery(con, "SELECT created_at FROM `algeria-in-numbers.automobiles.ok_auto_raw`
           ORDER BY 1 DESC LIMIT 1") %>% 
  pull(created_at)

last_datetime <- ifelse(length(last_datetime) == 0, '2022-07-22T20:00:00.000Z', last_datetime)

df <- parsed$data$search$announcements$data %>% tibble() %>%
  filter(createdAt > last_datetime) %>% 
  arrange(createdAt)

list_id <- df %>% pull(id)

list_id

source('single_post_request.R')

if (length(list_id) > 0) {
  
  i <- 1
  for (id in list_id) {
    
    res_single <- get_single_listing(id)
    
    parsed_single <- fromJSON(content(res_single, 'text'), flatten=TRUE)
    
    id <- id %>% as.character()
    
    title <- parsed_single$data$announcement$title %>% as.character() 
    
    description <- parsed_single$data$announcement$description %>% as.character()
    
    created_at <- parsed_single$data$announcement$createdAt %>% as.character()
    
    price <- parsed_single$data$announcement$price %>% as.character()
    
    price_preview <- parsed_single$data$announcement$pricePreview %>% as.character() 
    
    price_type <- parsed_single$data$announcement$priceType %>% as.character() 
    
    exchange_type <- parsed_single$data$announcement$exchangeType %>% as.character()
    
    price_unit <- parsed_single$data$announcement$priceUnit %>% as.character()
    
    category_name <- parsed_single$data$announcement$category$name %>% as.character()
    
    car_specs <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(!specification.codename == 'car-options') %>% 
      unnest(value) %>% 
      unnest(valueText) %>%
      select(car_spec = specification.codename, value, value_text = valueText)
    
    year <- car_specs %>% filter(car_spec == 'annee') %>% pull(value_text) %>% as.character()
    
    engine <- car_specs %>% filter(car_spec == 'car-engine') %>% pull(value_text) %>% as.character()
    
    color <- car_specs %>% filter(car_spec == 'couleur_auto') %>% pull(value_text) %>% as.character()
    
    energy <- car_specs %>% filter(car_spec == 'energie') %>% pull(value_text) %>% as.character()
    
    papers_state <- car_specs %>% filter(car_spec == 'etat_papiers') %>% pull(value_text) %>% as.character()
    
    distance_travelled <- car_specs %>% filter(car_spec == 'kilometrage') %>% pull(value) %>% as.character()
    
    brand <- car_specs %>% filter(car_spec == 'marque-voiture') %>% pull(value_text) %>% as.character()
    
    model <- car_specs %>% filter(car_spec == 'modele') %>% pull(value_text) %>% as.character()
    
    transmission <- car_specs %>% filter(car_spec == 'transmission') %>% pull(value_text) %>% as.character()
    
    car_options_en <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(specification.codename == 'car-options') %>% 
      unnest(value) %>% 
      pull(value) %>% 
      glue_collapse(sep = ", ") %>% 
      str_trim() %>% as.character()
    
    
    car_options_fr <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(specification.codename == 'car-options') %>% 
      unnest(valueText) %>% 
      pull(valueText) %>% 
      glue_collapse(sep = ", ") %>% 
      str_trim() %>% as.character()
    
    user_id <- parsed_single$data$announcement$user$id %>% as.character()
    
    region_id <- parsed_single$data$announcement$cities$region.id %>% as.character()
    
    region_name <- parsed_single$data$announcement$cities$region.name %>% as.character()
    
    city_name <- parsed_single$data$announcement$cities$name %>% as.character()
    
    source('insert_data.R')
    print(i)
    i <- i + 1
    Sys.sleep(5)
  }
  
}







