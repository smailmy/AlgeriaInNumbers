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


sql_query <- glue_sql("INSERT INTO automobiles.ok_auto_raw (id, title, description, created_at, price,
     price_review, price_type, exchange_type, price_unit, category_name, year, 
     engine, color, energy, papers_state, distance_travelled, brand, model, transmission,
     car_options_en, car_options_fr, user_id, region_id, region_name, city_name,
     insert_date)
     
     VALUES({id}, {title}, {description}, {created_at}, {price}, {price_preview}, 
     {price_type}, {exchange_type}, {price_unit}, {category_name}, {year}, 
     {engine}, {color}, {energy}, {papers_state}, {distance_travelled}, {brand}, 
     {model}, {transmission}, {car_options_en}, {car_options_fr}, {user_id}, 
     {region_id}, {region_name}, {city_name}, CURRENT_TIMESTAMP())",
         .con = con)


dbGetQuery(con, sql_query)



