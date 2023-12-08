### This is the start of the creation of the end line survey data ### 

#Necessary libraries
#install.packages("dplyr")
library(dplyr)

#Seed for reproduction
set.seed(503)

baseline_survey = read.csv("~/CovidAdRCT/baseline_survey.csv")

#Defining dropout probabilities by the assignment of their treatment, making the assumption that those in the control group have higher propensity to drop out of the survey
calculate_dropout_prob <- function(assignment) {
  if (assignment == "reason") {
    return(0.05)
  } else if (assignment == "emotion") {
    return(0.05)
  } else if (assignment == "control") {
    return(0.1)
  } else {
    return(0)
  }
}

#Placeholder probabilities
baseline_survey <- baseline_survey %>%
  mutate(dropout_probability = sapply(assignment, calculate_dropout_prob))

#Applying function, sampling 4500 obs
endline_survey <- baseline_survey[sample(nrow(baseline_survey), 4500, prob = 1 - baseline_survey$dropout_probability), ]

#Dropping obsolete probabilities
endline_survey$dropout_probability <- NULL

#Effectiveness of the different treatments on those un-vaccinated
endline_survey <- endline_survey %>%
  mutate(
    vaccinated_post = ifelse(
      vaccinated_pre == 1 |
        (vaccinated_pre == 0 & assignment == "emotion" & runif(n()) <= 0.30) |
        (vaccinated_pre == 0 & assignment == "reason" & runif(n()) <= 0.10) |
        (vaccinated_pre == 0 & assignment == "control" & runif(n()) <= 0.05),
      1, 0
    )
  )

#Effectiveness of different treatments on vaccinated people on their uptake of the most recent booster shot
endline_survey <- endline_survey %>%
  mutate(
    booster_post = ifelse(
      booster_pre == 1 |
        (vaccinated_pre == 1 & assignment == "emotion" & runif(n()) <= 0.20) |
        (vaccinated_pre == 1 & assignment == "reason" & runif(n()) <= 0.50) |
        (vaccinated_pre == 1 & assignment == "control" & runif(n()) <= 0.15),
      1, 0
    )
  )

write.csv(endline_survey, "~/CovidAdRCT/endline_survey.csv", row.names = FALSE)

### End of the creation of the end line survey data ###
