# Open a connection to a log file
log_file <- "analysis_log_file.md"
sink(log_file, append = FALSE)

### This script is for the analysis of the advertisement RCT on vaccine uptake ###

#Necessary libraries
#install.packages("dplyr")
#install.packages("stargazer")
#install.packages("gtsummary")
#install.packages("ggplot2")
library(dplyr)
library(stargazer)
library(ggplot2)
library(gtsummary)

set.seed(3001)

baseline_survey <- read.csv("~/CovidAdRCT/baseline_survey.csv")
endline_survey <- read.csv("~/CovidAdRCT/endline_survey.csv")

#Merging pre and post data
combined_data <- merge(baseline_survey, endline_survey, by = "ID", suffixes = c(".1", ".2"), all.x = T)

#Observing if RCT still random by end line after attrition
tbl_summary(endline_survey, by = assignment)

#factorizing variables
endline_survey$assignment <- factor(endline_survey$assignment)
endline_survey$vaccinated_post <- factor(endline_survey$vaccinated_post)
endline_survey$vaccinated_pre <- factor(endline_survey$vaccinated_pre)
baseline_survey$assignment <- factor(baseline_survey$assignment)
baseline_survey$vaccinated_pre <- factor(baseline_survey$vaccinated_pre)

#Bar plot of outcomes for each treatment group
ggplot(baseline_survey, aes(x = assignment, fill = vaccinated_pre)) +
  geom_bar(position = "fill", stat = "count") +
  theme_minimal()

#Bar plot of outcomes for each treatment group
ggplot(endline_survey, aes(x = assignment, fill = vaccinated_post)) +
  geom_bar(position = "fill", stat = "count") +
  theme_minimal()

#Histogram of outcomes by group in baseline
ggplot(baseline_survey, aes(x = vaccinated_pre, fill = assignment)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.5, stat="count") +
  theme_minimal()

#Histogram of outcomes by group in endline
ggplot(endline_survey, aes(x = vaccinated_post, fill = assignment)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.5, stat="count") +
  theme_minimal()

write.csv(combined_data, "~/CovidAdRCT/combined_data.csv", row.names = FALSE)

## Univariate regressions ##

reg_adverts <- lm(vaccinated_post ~ assignment.1, data = combined_data)
stargazer(reg_adverts, title = "Emotional vs reason Adverts on Vaccine Uptake", type = "text")

#Data set of those who were already vaccinated
already_vaccinated <- combined_data %>%
  filter(vaccinated_pre.1 == 1)

reg_adverts_on_vaccinated <- lm(booster_post ~ assignment.1, data = already_vaccinated)
stargazer(reg_adverts_on_vaccinated, title = "Adverts on Vaccine Uptake (boosters) Among Already Vaccinated", type = "text")

#Data set of those who were not vaccinated before
not_vaccinated <- combined_data %>%
  filter(vaccinated_pre.1 == 0)

reg_adverts_on_unvaccinated <- lm(vaccinated_post ~ assignment.1, data = not_vaccinated)
stargazer(reg_adverts_on_unvaccinated, title = "Adverts on Vaccine Uptake Among Unvaccinated in Pre-period", type = "text")

####

## Regressions controlling for demographics ##

reg_adverts_controls <- lm(vaccinated_post ~ assignment.1 + state.1 + age.1 + race.1 + Hispanic.1 + affiliation.1 + education.1, data = combined_data)
stargazer(reg_adverts_controls, title = "Emotional vs reason Adverts on Vaccine Uptake", type = "text")

reg_adverts_on_vaccinated_controls <- lm(booster_post ~ assignment.1 + state.1 + age.1 + race.1 + Hispanic.1 + affiliation.1 + education.1, data = already_vaccinated)
stargazer(reg_adverts_on_vaccinated_controls, title = "Adverts on Vaccine Uptake (boosters) Among Already Vaccinated", type = "text")

reg_adverts_on_unvaccinated_controls <- lm(vaccinated_post ~ assignment.1 + state.1 + age.1 + race.1 + Hispanic.1 + affiliation.1 + education.1, data = not_vaccinated)
stargazer(reg_adverts_on_unvaccinated_controls, title = "Adverts on Vaccine Uptake Among Unvaccinated in Pre-period", type = "text")

####

sink()

cat("Log file created: ", log_file, "\n")