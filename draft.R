# API Method --------------------------------------------------------------
library(jsonlite)
library(tidyverse)

source('main_post_request.R')

res <- get_main_listings()

parsed <- fromJSON(content(res, 'text'), flatten=TRUE)

df <- parsed$data$search$announcements$data %>% tibble()

list_id <- df %>% pull(id)

list_id

source('single_post_request.R')

i = 1

for (id in list_id) {
  
  res_single <- get_single_listing(id)
  
  parsed_single <- fromJSON(content(res_single, 'text'), flatten=TRUE)
  
  df_single <- parsed_single$data$search$announcements$data %>% tibble()
  
  car_specs <- parsed_single$data$announcement$specs %>% tibble() 
  
  print(paste(i, id, nrow(car_specs)))
  
  i = i + 1
  
  Sys.sleep(5)
}




res_single <- get_single_listing("32494823")

parsed_single <- fromJSON(content(res_single, 'text'), flatten=TRUE)
  
df_single <- parsed_single$data$search$announcements$data %>% tibble()

id <- "32496797" %>% as.character()
  
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





