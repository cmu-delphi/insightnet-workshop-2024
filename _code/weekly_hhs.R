library(tidyverse)
library(epiprocess)
library(rlang)
library(purrr)
library(magrittr)

file_path <- here::here("_data/weekly_hhs.rds")

if (!file.exists(file_path)) {
  forecast_dates <- seq.Date(as.Date("2023-10-04"), as.Date("2024-03-27"), by = 7L)

  get_health_data <- function(as_of, disease = c("covid", "flu")) {
    as_of <- as.Date(as_of)
    disease <- arg_match(disease)
    checkmate::assert_date(as_of, min.len = 1, max.len = 1)

    cache_path <- here::here("_data", "healthdata")
    if (!dir.exists(cache_path)) {
      dir.create(cache_path, recursive = TRUE)
    }

    metadata_path <- here::here(cache_path, "metadata.csv")
    if (!file.exists(metadata_path)) {
      meta_data <- readr::read_csv("https://healthdata.gov/resource/qqte-vkut.csv?$query=SELECT%20update_date%2C%20days_since_update%2C%20user%2C%20rows%2C%20row_change%2C%20columns%2C%20column_change%2C%20metadata_published%2C%20metadata_updates%2C%20column_level_metadata%2C%20column_level_metadata_updates%2C%20archive_link%20ORDER%20BY%20update_date%20DESC%20LIMIT%2010000", show_col_types = FALSE)
      readr::write_csv(meta_data, metadata_path)
    } else {
      meta_data <- readr::read_csv(metadata_path, show_col_types = FALSE)
    }

    most_recent_row <- meta_data %>%
      # update_date is actually a time, so we need to filter for the day after.
      filter(update_date <= as_of + 1) %>%
      arrange(desc(update_date)) %>%
      slice(1)

    if (nrow(most_recent_row) == 0) {
      cli::cli_abort("No data available for the given date.")
    }

    data_filepath <- here::here(cache_path, sprintf("g62h-syeh-%s.csv", as.Date(most_recent_row$update_date)))
    if (!file.exists(data_filepath)) {
      data <- readr::read_csv(most_recent_row$archive_link, show_col_types = FALSE)
      readr::write_csv(data, data_filepath)
    } else {
      data <- readr::read_csv(data_filepath, show_col_types = FALSE)
    }
    if (disease == "covid") {
      data %<>% mutate(
        hhs = previous_day_admission_adult_covid_confirmed +
          previous_day_admission_adult_covid_suspected +
          previous_day_admission_pediatric_covid_confirmed +
          previous_day_admission_pediatric_covid_suspected
      )
    } else if (disease == "flu") {
      data %<>% mutate(hhs = previous_day_admission_influenza_confirmed)
    }
    # Minor data adjustments and column renames. The date also needs to be dated
    # back one, since the columns we use report previous day hospitalizations.
    data %>%
      mutate(
        geo_value = tolower(state),
        time_value = date - 1L,
        hhs = hhs,
        .keep = "none"
      ) %>%
      # API seems to complete state level with 0s in some cases rather than NAs.
      # Get something sort of compatible with that by summing to national with
      # na.omit = TRUE. As otherwise we have some NAs from probably territories
      # propagated to US level.
      bind_rows(
        (.) %>%
          group_by(time_value) %>%
          summarize(geo_value = "us", hhs = sum(hhs, na.rm = TRUE))
      )
  }
  daily_to_weekly_archive <- function(epi_arch,
                                      agg_columns,
                                      agg_method = c("sum", "mean"),
                                      day_of_week = 4L,
                                      day_of_week_end = 7L) {
    agg_method <- arg_match(agg_method)
    keys <- key_colnames(epi_arch, exclude = "time_value")
    ref_time_values <- epi_arch$DT$version %>%
      unique() %>%
      sort()
    if (agg_method == "sum") {
      slide_fun <- epi_slide_sum
    } else if (agg_method == "mean") {
      slide_fun <- epi_slide_mean
    }
    too_many_tibbles <- epix_slide(
      epi_arch,
      .before = 99999999L,
      .versions = ref_time_values,
      function(x, group, ref_time) {
        ref_time_last_week_end <-
          floor_date(ref_time, "week", day_of_week_end - 1) # this is over by 1
        max_time <- max(x$time_value)
        valid_slide_days <- seq.Date(
          from = ceiling_date(min(x$time_value), "week", week_start = day_of_week_end - 1),
          to = floor_date(max(x$time_value), "week", week_start = day_of_week_end - 1),
          by = 7L
        )
        if (wday(max_time) != day_of_week_end) {
          valid_slide_days <- c(valid_slide_days, max_time)
        }
        slid_result <- x %>%
          group_by(across(all_of(keys))) %>%
          slide_fun(
            agg_columns,
            .window_size = 7L,
            na.rm = TRUE,
            .ref_time_values = valid_slide_days,
            .prefix = "slide_value_"
          ) %>%
          select(-all_of(agg_columns)) %>%
          rename_with(~ gsub("slide_value_", "", .x)) %>%
          # only keep 1/week
          # group_by week, keep the largest in each week
          # alternatively
          # switch time_value to the designated day of the week
          mutate(time_value = round_date(time_value, "week", day_of_week - 1)) %>%
          as_tibble()
      }
    )
    too_many_tibbles %>%
      pull(time_value) %>%
      max()
    too_many_tibbles %>%
      as_epi_archive(compactify = TRUE)
  }

  health_data <- map(forecast_dates, get_health_data)

  compactified_health_data <- mapply(\(x, y) mutate(x, version = y),
         health_data,
         forecast_dates,
         SIMPLIFY = FALSE) %>%
    bind_rows() %>% filter(!is.na(hhs)) %>%
    as_epi_archive(compactify = TRUE)

  weekly_archive <- compactified_health_data %>%
    daily_to_weekly_archive(agg_columns = "hhs")

  saveRDS(weekly_archive, file = file_path)
} else {
  weekly_archive <- readRDS(file_path)
}
