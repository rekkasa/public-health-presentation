#!/usr/bin/env Rscript

# ===================================================
# Description:
#   Generates the discrimination plots
# Input:
#   - sample size
#   - auc
#   - value
# Output:
#   - figures/rmse_*.tiff
# Depends:
#   - data/processed/analysisIds.csv
#   - data/processed/discrimination.csv
#   - code/helpers/CreateManuscriptPlots.R
#   - code/helpers/PlotResult.R
# ===================================================

args <- commandArgs(trailingOnly = TRUE)
args_base <- as.character(args[1])
args_sampleSize <- as.numeric(args[2])
args_auc <- as.numeric(args[3])
args_value <- as.character(args[4])


library(tidyverse)
library(glue)
library(ggtext)
source("code/helpers/CreateManuscriptPlots.R")
source("code/helpers/PlotResult.R")

scenarioIds <- readr::read_csv("data/processed/analysisIds.csv") %>%
  filter(
    base == args_base,
    harm != "negative",
    !(type %in% c("quadratic-moderate", "linear-moderate")),
    sampleSize == args_sampleSize,
    auc == args_auc
  ) 

metric <- "discrimination"

titles <- scenarioIds %>%
  mutate(
    title = ifelse(
      type == "constant",
      str_to_sentence(glue("{str_replace_all(type, '-', ' ')} treatment effect")),
      str_to_sentence(glue("{str_replace_all(type, '-', ' ')} deviation"))
    )
  ) %>%
  select(title) %>%
  unlist() %>%
  unique()

names(titles) <- NULL

metricFile <- paste(metric, "csv", sep = ".")

processed <- readr::read_csv(
  file = file.path("data/processed", metricFile)
)
scenarios <- scenarioIds %>%
  filter(harm == "absent") %>%
  select(scenario) %>%
  unlist()
names(scenarios) <- NULL

plotList <- plotResult(scenarios, processed, titles, metric = metric, limits = c(.48, .6, .03))

res <- gridExtra::grid.arrange(
  plotList[[1]] +
    theme(
      plot.title = element_text(size = 12),
      axis.title = element_blank(),
      legend.direction = "horizontal",
      legend.title = element_text(size = 8.5),
      legend.text = element_text(size = 7.5),
      legend.position = c(.395, .922),
      panel.grid.minor = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_text(size = 9)
    ),
  plotList[[2]] +
    theme(
      plot.title = element_text(size = 12),
      axis.title = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      legend.position = "none",
      panel.grid.minor = element_blank()
    ),
  plotList[[3]] +
    theme(
      plot.title = element_text(size = 12),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 9),
      axis.text.y = element_text(size = 9),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    ),
  plotList[[4]] +
    theme(
      plot.title = element_text(size = 12),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 9),
      axis.text.y = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    ),
  heights = c(1, 1.05),
  nrow = 2,
  ncol = 2,
  left = "C-statistic for benefit"
)

fileName <- paste0(
  paste(
    metric,
    args_base,
    args_value,
    sep = "_"
  ),
  ".png"
)
  ggplot2::ggsave(
    file.path("figures", fileName), 
    plot = res,
    dpi = 1200,
    width = 10, 
    height = 7
  )
