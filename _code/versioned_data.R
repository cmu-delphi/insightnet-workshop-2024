file_path_1 <- here::here("_data/covid_archive.rds")
file_path_2 <- here::here("_data/covid_archive_dv.rds")

forecast_dates <- seq(from = as.Date("2021-04-01"), to = as.Date("2023-03-01"), by = "1 week")

if (!file.exists(file_path_1) | !file.exists(file_path_2)) {
  states <- "*"

  cases_archive <- pub_covidcast(
    source = "jhu-csse",
    signals = "confirmed_incidence_prop",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
    geo_values = states,
    issues = epirange(20200401, 20230401)) %>%
    select(geo_value, time_value, version = issue, case_rate = value) %>%
    arrange(geo_value, time_value) %>%
    as_epi_archive(compactify = FALSE)

  dv_archive <- pub_covidcast(
    source = "doctor-visits",
    signals = "smoothed_adj_cli",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
    geo_values = states,
    issues = epirange(20200401, 20230401)) %>%
    select(geo_value, time_value, version = issue, dv = value) %>%
    arrange(geo_value, time_value) %>%
    as_epi_archive(compactify = FALSE)

  deaths_archive <- pub_covidcast(
    source = "jhu-csse",
    signals = "deaths_incidence_prop",
    time_type = "day",
    geo_type = "state",
    time_values = epirange(20200401, 20230401),
    geo_values = states,
    issues = epirange(20200401, 20230401)) %>%
    select(geo_value, time_value, version = issue, death_rate = value) %>%
    arrange(geo_value, time_value) %>%
    as_epi_archive(compactify = FALSE)

  covid_archive <- epix_merge(cases_archive, deaths_archive, sync = "locf")
  covid_archive <- covid_archive |>
    epix_slide(
      .before = Inf,
      .versions = forecast_dates,
      function(x, gk, rtv) {
        x |>
          group_by(geo_value) |>
          epi_slide_mean(case_rate, .window_size = 7L, .suffix = "_7d_av") |>
          epi_slide_mean(death_rate, .window_size = 7L, .suffix = "_7d_av") |>
          ungroup()
      }
    ) |>
    rename(
      cases = case_rate_7d_av,
      deaths = death_rate_7d_av,
    ) |>
    select(version, time_value, geo_value, cases, deaths
           ) |>
    as_epi_archive(compactify = TRUE)
  saveRDS(covid_archive, file = file_path_1)

  covid_archive_dv <- epix_merge(deaths_archive, dv_archive, sync = "locf")
  covid_archive_dv <- covid_archive_dv |>
    epix_slide(
      .before = Inf,
      .versions = forecast_dates,
      function(x, gk, rtv) {
        x |>
          group_by(geo_value) |>
          epi_slide_mean(death_rate, .window_size = 7L, .suffix = "_7d_av") |>
          epi_slide_mean(dv, .window_size = 7L, .suffix = "_7d_av") |>
          ungroup()
          )
      }
    ) |>
    rename(
      deaths = death_rate_7d_av,
      doctor_visits = dv_7d_av
    ) |>
    select(version, time_value, geo_value, deaths, doctor_visits) |>
    as_epi_archive(compactify = TRUE)
  saveRDS(covid_archive_dv, file = file_path_2)

} else {
  covid_archive <- readRDS(file_path_1)
  covid_archive_dv <- readRDS(file_path_2)
}
