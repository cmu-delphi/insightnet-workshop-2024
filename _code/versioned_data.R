file_path <- "../_data/data_archive"

if (!file.exists(file_path)) {
  states <- "*"

  cases_archive <- pub_covidcast(
    source = "jhu-csse",
    signals = "confirmed_incidence_prop",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20220101),
    geo_values = states,
    issues = epirange(20200401, 20220101)) %>%
    select(geo_value, time_value, version = issue, case_rate = value) %>%
    arrange(geo_value, time_value) %>%
    as_epi_archive(compactify = FALSE)

  deaths_archive <- pub_covidcast(
    source = "jhu-csse",
    signals = "deaths_incidence_prop",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20220101),
    geo_values = states,
    issues = epirange(20200401, 20220101)) %>%
    select(geo_value, time_value, version = issue, death_rate = value) %>%
    arrange(geo_value, time_value) %>%
    as_epi_archive(compactify = FALSE)

  data_archive <- epix_merge(cases_archive, deaths_archive, sync = "locf")
  saveRDS(data_archive, file = file_path)
} else {
  data_archive <- readRDS(file_path)
}
