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
    time_values = epirange(20200401, 20230401),
    geo_values = "ca") %>%
    select(geo_value, time_value, cases = value)

  deaths <- pub_covidcast(
    source = "jhu-csse",
    signals = "deaths_incidence_num",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
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
    #group_by(geo_value) %>%
    #epi_slide(cases_7dav = mean(cases),
    #          deaths_7dav = mean(deaths),
    #          .window_size = 7) %>%
    #slice_tail(n = -6L) %>%
    #ungroup() %>%
    epi_slide(cases_7dav = mean(cases, na.rm = T),
              deaths_7dav = mean(deaths, na.rm = T),
              .window_size = 7) %>%
    select(!c(cases, deaths)) %>%
    rename(cases = cases_7dav,
           deaths = deaths_7dav)

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
range1 = range(ca$cases)
range2 = range(ca$deaths)
trans12 = function(x) trans(x, range1, range2)
trans21 = function(x) trans(x, range2, range1)

