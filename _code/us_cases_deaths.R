library(tidyverse)
library(epidatr)
library(epiprocess)
library(epipredict)


file_path <- here::here("_data/us_cases_deaths.rds")
if (!file.exists(file_path)) {
  cases <- pub_covidcast(
    source = "jhu-csse",
    signals = "confirmed_incidence_num",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
    geo_values = "*") %>%
    select(geo_value, time_value, cases = value)

  deaths <- pub_covidcast(
    source = "jhu-csse",
    signals = "deaths_incidence_num",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
    geo_values = "*") %>%
    select(geo_value, time_value, deaths = value)

  us <- left_join(cases, deaths, by = c("time_value", "geo_value")) %>%
    as_epi_df()

  us <- left_join(
    x = us,
    y = state_census %>% select(pop, abbr),
    by = c("geo_value" = "abbr"))

  us <- us %>%
    mutate(cases = cases / pop * 1e5, # cases / 100K
           deaths = deaths / pop * 1e5) %>% # deaths / 100K
    select(-pop)

  us <- us %>%
    epi_slide(cases_7dav = mean(cases, na.rm = T),
              deaths_7dav = mean(deaths, na.rm = T),
              .window_size = 7) %>%
    select(!c(cases, deaths)) %>%
    rename(cases = cases_7dav,
           deaths = deaths_7dav)

  us$deaths[us$deaths < 0] <- 0
  saveRDS(us, file = file_path)
} else {
  us <- readRDS(file_path)
}
