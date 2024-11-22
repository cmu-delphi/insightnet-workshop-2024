library(tidyverse)

file_path <- here::here("_data/bccovid.rds")
if (!file.exists(file_path)) {
  library(tidyverse)
  path <- "http://www.bccdc.ca/Health-Info-Site/Documents/BCCDC_COVID19_Dashboard_Case_Details.csv"
  bccovid <- read_csv(path, col_types = cols(.default = "c")) |>
    rename(
      `Reported Date` = Reported_Date,
      `Health Authority` = HA,
      `Age group` = Age_Group
    ) |>
    mutate(
      `Age group` = recode(`Age group`, `19-Oct` = "10-19"),
      `Reported Date` = as.Date(
        `Reported Date`, tryFormats = c("%Y-%m-%d", "%m/%d/%Y"))
    ) |>
    count(date = `Reported Date`, name = "cases")
  saveRDS(bccovid, file = file_path)
} else {
  bccovid <- readRDS(file_path)
}

