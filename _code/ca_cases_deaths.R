library(tidyverse)
library(epidatr)
library(epiprocess)
library(epipredict)


file_path <- here::here("_data/ca_cases_deaths.rds")
if (!file.exists(file_path)) {
  cases <- pub_covidcast(
    source = "jhu-csse",
    signals = "confirmed_incidence_num",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20220101),
    geo_values = "ca") %>%
    select(geo_value, time_value, cases = value)

  deaths <- pub_covidcast(
    source = "jhu-csse",
    signals = "deaths_incidence_num",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20220101),
    geo_values = "ca") %>%
    select(geo_value, time_value, deaths = value)

  ca <- left_join(cases, deaths, by = c("time_value", "geo_value")) %>%
    as_epi_df()

  ca <- left_join(
    x = ca,
    y = state_census %>% select(pop, abbr),
    by = c("geo_value" = "abbr"))

  ca <- ca %>%
    mutate(cases = cases / pop * 1e5, # cases / 100K
           deaths = deaths / pop * 1e5) %>% # deaths / 100K
    select(-pop)

  ca <- ca %>%
    epi_slide(cases = mean(cases), .window_size = 7) %>%
    epi_slide(deaths = mean(deaths), .window_size = 7)

  ca$deaths[ca$deaths < 0] <- 0
  saveRDS(ca, file = file_path)
} else {
  ca <- readRDS(file_path)
}

# Handy function to produce a transformation from one range to another
trans = function(x, from_range, to_range) {
  (x - from_range[1]) / (from_range[2] - from_range[1]) *
    (to_range[2] - to_range[1]) + to_range[1]
}

# Compute ranges of the two signals, and transformations in b/w them
range1 = ca %>% select(cases) %>% range()
range2 = ca %>% select(deaths) %>% range()
trans12 = function(x) trans(x, range1, range2)
trans21 = function(x) trans(x, range2, range1)
