# API Method --------------------------------------------------------------
print(Sys.time())

library(jsonlite)
library(tidyverse)
library(bigrquery)
library(DBI)
library(glue)

project_id <- "algeria-in-numbers"
dataset <- "automobiles"

con <- dbConnect(
  bigrquery::bigquery(),
  project = project_id,
  dataset = dataset,
  billing = project_id
)

setwd('~/AlgeriaInNumbers/')

source('main_post_request.R')

res <- get_main_listings()

parsed <- fromJSON(content(res, 'text'), flatten=TRUE)

last_datetime <- dbGetQuery(con, "SELECT created_at FROM `algeria-in-numbers.automobiles.ok_auto`
           ORDER BY 1 DESC LIMIT 1") %>% 
  pull(created_at)

last_datetime <- ifelse(length(last_datetime) == 0, '2022-07-22T20:00:00.000Z', last_datetime)

df <- parsed$data$search$announcements$data %>% tibble() %>%
  filter(createdAt > last_datetime) %>% 
  arrange(createdAt)

list_id <- df %>% pull(id)

print(paste(length(list_id), "new listings."))

source('single_post_request.R')

one_row <- tibble(
  id = as.character(),
  title = as.character(),
  description = as.character(),
  created_at = as.character(),
  price = as.character(),
  price_preview = as.character(),
  price_type = as.character(),
  exchange_type = as.character(),
  price_unit = as.character(),
  category_name = as.character(),
  year = as.character(),
  engine = as.character(),
  color = as.character(),
  energy = as.character(),
  papers_state = as.character(),
  distance_travelled = as.character(),
  brand = as.character(),
  model = as.character(),
  transmission = as.character(),
  car_options_en = as.character(),
  car_options_fr = as.character(),
  user_id = as.character(),
  region_id = as.character(),
  region_name = as.character(),
  city_name = as.character(),
  edition = as.character()
)

if (length(list_id) > 0) {
  
  i <- 1
  for (id in list_id) {
    
    res_single <- get_single_listing(id)
    
    parsed_single <- fromJSON(content(res_single, 'text'), flatten=TRUE)
    
    id_value <- id %>% as.character()
    
    title_value <- parsed_single$data$announcement$title %>% as.character()
    
    description_value <- parsed_single$data$announcement$description %>% as.character()
    
    created_at_value <- parsed_single$data$announcement$createdAt %>% as.character()
    
    price_value <- parsed_single$data$announcement$price %>% as.character()
    
    price_preview_value <- parsed_single$data$announcement$pricePreview %>% as.character()
    
    price_type_value <- parsed_single$data$announcement$priceType %>% as.character()
    
    exchange_type_value <- parsed_single$data$announcement$exchangeType %>% as.character()
    
    price_unit_value <- parsed_single$data$announcement$priceUnit %>% as.character()
    
    category_name_value <- parsed_single$data$announcement$category$name %>% as.character()
    
    car_specs <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(!specification.codename == 'car-options') %>%
      unnest(value) %>%
      unnest(valueText) %>%
      select(car_spec = specification.codename, value, value_text = valueText)
    
    year_value <- car_specs %>% filter(car_spec == 'annee') %>% pull(value_text) %>% as.character()
    
    engine_value <- car_specs %>% filter(car_spec == 'car-engine') %>% pull(value_text) %>% as.character()
    
    color_value <- car_specs %>% filter(car_spec == 'couleur_auto') %>% pull(value_text) %>% as.character()
    
    energy_value <- car_specs %>% filter(car_spec == 'energie') %>% pull(value_text) %>% as.character()
    
    papers_state_value <- car_specs %>% filter(car_spec == 'etat_papiers') %>% pull(value_text) %>% as.character()
    
    distance_travelled_value <- car_specs %>% filter(car_spec == 'kilometrage') %>% pull(value) %>% as.character()
    
    brand_value <- car_specs %>% filter(car_spec == 'marque-voiture') %>% pull(value_text) %>% as.character()
    
    model_value <- car_specs %>% filter(car_spec == 'modele') %>% pull(value_text) %>% as.character()
    
    transmission_value <- car_specs %>% filter(car_spec == 'transmission') %>% pull(value_text) %>% as.character()
    
    edition_value <- car_specs %>% filter(car_spec == 'nom_special') %>% pull(value_text) %>% as.character()
    
    car_options_en_value <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(specification.codename == 'car-options') %>%
      unnest(value) %>%
      pull(value) %>%
      glue_collapse(sep = ", ") %>%
      str_trim() %>% as.character()
    
    
    car_options_fr_value <- parsed_single$data$announcement$specs %>% tibble() %>%
      filter(specification.codename == 'car-options') %>%
      unnest(valueText) %>%
      pull(valueText) %>%
      glue_collapse(sep = ", ") %>%
      str_trim() %>% as.character()
    
    user_id_value <- parsed_single$data$announcement$user$id %>% as.character()
    
    region_id_value <- parsed_single$data$announcement$cities$region.id %>% as.character()
    
    region_name_value <- parsed_single$data$announcement$cities$region.name %>% as.character()
    
    city_name_value <- parsed_single$data$announcement$cities$name %>% as.character()
    
    id_value <- ifelse(length(id_value) == 0, NA_character_, id_value)
    title_value <- ifelse(length(title_value) == 0, NA_character_, title_value)
    description_value <- ifelse(length(description_value) == 0, NA_character_, description_value)
    created_at_value <- ifelse(length(created_at_value) == 0, NA_character_, created_at_value)
    price_value <- ifelse(length(price_value) == 0, NA_character_, price_value)
    price_preview_value <- ifelse(length(price_preview_value) == 0, NA_character_, price_preview_value)
    price_type_value <- ifelse(length(price_type_value) == 0, NA_character_, price_type_value)
    exchange_type_value <- ifelse(length(exchange_type_value) == 0, NA_character_, exchange_type_value)
    price_unit_value <- ifelse(length(price_unit_value) == 0, NA_character_, price_unit_value)
    category_name_value <- ifelse(length(category_name_value) == 0, NA_character_, category_name_value)
    year_value <- ifelse(length(year_value) == 0, NA_character_, year_value)
    engine_value <- ifelse(length(engine_value) == 0, NA_character_, engine_value)
    color_value <- ifelse(length(color_value) == 0, NA_character_, color_value)
    energy_value <- ifelse(length(energy_value) == 0, NA_character_, energy_value)
    papers_state_value <- ifelse(length(papers_state_value) == 0, NA_character_, papers_state_value)
    distance_travelled_value <- ifelse(length(distance_travelled_value) == 0, NA_character_, distance_travelled_value)
    brand_value <- ifelse(length(brand_value) == 0, NA_character_, brand_value)
    model_value <- ifelse(length(model_value) == 0, NA_character_, model_value)
    transmission_value <- ifelse(length(transmission_value) == 0, NA_character_, transmission_value)
    car_options_en_value <- ifelse(length(car_options_en_value) == 0, NA_character_, car_options_en_value)
    car_options_fr_value <- ifelse(length(car_options_fr_value) == 0, NA_character_, car_options_fr_value)
    user_id_value <- ifelse(length(user_id_value) == 0, NA_character_, user_id_value)
    region_id_value <- ifelse(length(region_id_value) == 0, NA_character_, region_id_value)
    region_name_value <- ifelse(length(region_name_value) == 0, NA_character_, region_name_value)
    city_name_value <- ifelse(length(city_name_value) == 0, NA_character_, city_name_value)
    edition_value <- ifelse(length(edition_value) == 0, NA_character_, edition_value)
    
    one_row <- one_row %>%
      bind_rows(tibble(id = id_value, 
                       title = title_value, 
                       description = description_value, 
                       created_at = created_at_value, 
                       price = price_value, 
                       price_preview = price_preview_value, 
                       price_type = price_type_value, 
                       exchange_type = exchange_type_value, 
                       price_unit = price_unit_value, 
                       category_name = category_name_value, 
                       year = year_value, 
                       engine = engine_value, 
                       color = color_value, 
                       energy = energy_value, 
                       papers_state = papers_state_value, 
                       distance_travelled = distance_travelled_value, 
                       brand = brand_value, 
                       model = model_value, 
                       transmission = transmission_value, 
                       car_options_en = car_options_en_value, 
                       car_options_fr = car_options_fr_value, 
                       user_id = user_id_value, 
                       region_id = region_id_value, 
                       region_name = region_name_value, 
                       city_name = city_name_value, 
                       edition = edition_value))
    
    print(i)
    i <- i + 1
    Sys.sleep(1)
  }
  
}

ok_table <- bq_table(project = project_id, dataset = dataset, table = "ok_auto")

bq_table_upload(ok_table, one_row, create_disposition='CREATE_IF_NEEDED', write_disposition='WRITE_APPEND')
