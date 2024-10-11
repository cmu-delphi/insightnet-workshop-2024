library(epiprocess)
library(tidyverse)
primary <- "#a8201a"
x <- archive_cases_dv_subset
x_latest <- epix_as_of(x, version = max(x$DT$version))
self_max = max(x$DT$version)
versions = seq(as.Date("2020-06-01"), self_max - 1, by = "1 month")
snapshots_all <- map_dfr(versions, function(v) {
  epix_as_of(x, max_version = v) %>% mutate(version = v)}) %>%
  bind_rows(x_latest %>% mutate(version = self_max)) %>%
  mutate(latest = version == self_max)
snapshots <- snapshots_all %>%
  filter(geo_value %in% c("ca", "fl"))

snapshots_all |>
  arrange(geo_value, version, time_value) |>
  # filter(!latest) |>
  ggplot(aes(x = time_value, y = percent_cli)) +
  geom_line(
    aes(color = factor(version), group = interaction(geo_value, version))
  ) +
  scale_y_continuous(expand = expansion(c(0, .05))) +
  scale_x_date(breaks = as.Date(c("2021-01-01", "2021-06-01")),
               expand = expansion(0),
               date_labels = "%B %Y") +
  labs(x = "", y = "% Outpatient visits due to COVID-like\nillness in CA and FL") +
  theme_bw() +
  coord_cartesian(xlim = as.Date(c("2020-10-01", "2021-10-01")), ylim = c(0, NA)) +
  scale_color_viridis_d(option = "B", end = .8) +
  theme(legend.position = "none", panel.background = element_blank()) +
  geom_line(
    data = snapshots %>% filter(latest),
    aes(x = time_value, y = percent_cli, group = geo_value),
    inherit.aes = FALSE, color = primary)

ggsave("assets/img/cover-art.svg", width = 6, height = 6)
