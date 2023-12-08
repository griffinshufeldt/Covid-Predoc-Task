### This is the start of the creation of the baseline survey ###

#Necessary library
library(dplyr)

#Seed for reproduction
set.seed(245)

#assignment is the treatment categorical variable
assignment <- sample(c("reason","emotion", "control"), 5000, replace = TRUE, prob = c(1/3, 1/3, 1/3))

baseline_survey <- data.frame(ID = 1:5000, assignment = assignment)

# Defining age ranges and the probability that a facebook user will fall into each range, sourced from Statista facebook user data
age_ranges <- c(13, 17, 18, 24, 25, 34, 35, 44, 45, 54, 55, 64, 65, 100)
age_probabilities <- c(0.034, 0.181, 0.236, 0.184, 0.139, 0.112, 0.114)

selected_indices <- sample(length(age_ranges)/2, 5000, replace = TRUE, prob = age_probabilities)

# Function to generate a specific age within a given range
generate_age_within_range <- function(index) {
  start_index <- 2 * index - 1
  end_index <- 2 * index
  sample(seq(age_ranges[start_index], age_ranges[end_index]), 1)
}

# Generate random ages based on the specified age ranges and probabilities
ages <- sapply(selected_indices, generate_age_within_range)

baseline_survey <- data.frame(ID = 1:5000, assignment = assignment, age = ages)

gender_by_age_probabilities <- c(0.024, 0.027, .089, .126)

#Facebook users gender varies by age, using data again from Statista, creating probabilities for gender in each age range
generate_gender <- function(age) {
  if (age >= 13 & age <= 17) {
    # Relative probabilities for of gender for each age range 
    gender_probabilities <- c(0.021 / (0.021 + 0.027), 0.027 / (0.021 + 0.027))
  } else if (age >= 18 & age <= 24) {
    gender_probabilities <- c(0.089 / (0.089 + 0.126), 0.126 / (0.089 + 0.126))
  } else if (age >= 25 & age <= 34) {
    gender_probabilities <- c(0.123 / (0.123 + 0.176), 0.176 / (0.123 + 0.176))
  } else if (age >= 35 & age <= 44) {
    gender_probabilities <- c(0.085 / (0.085 + 0.109), 0.109 / (0.085 + 0.109))
  }  else if (age >= 45 & age <= 54) {
    gender_probabilities <- c(0.055 / (0.055 + 0.061), 0.061 / (0.055 + 0.061))
  } else if (age >= 55 & age <= 64) {
    gender_probabilities <- c(0.038 / (0.038 + 0.035), 0.035 / (0.038 + 0.035))
  }  else if (age >= 64 & age <= 100) {
    gender_probabilities <- c(0.03 / (0.03 + 0.026), 0.026 / (0.03 + 0.026))
  }
  sample(c("Female", "Male"), 1, prob = gender_probabilities)
}

#Applying the generate gender function
genders <- sapply(ages, generate_gender)

baseline_survey <- data.frame(ID = 1:5000, assignment = assignment, age = ages, gender = genders)

state_names <- c("California", "Texas", "Florida", "New York", "Pennsylvania", "Illinois", "Ohio", "Georgia", "North Carolina",
                 "Michigan", "New Jersey", "Virginia", "Washington", "Arizona", "Tennessee", "Massachusetts", "Indiana",
                 "Missouri", "Maryland", "Wisconsin", "Colorado", "Minnesota", "South Carolina", "Alabama", "Louisiana",
                 "Kentucky", "Oregon", "Oklahoma", "Connecticut", "Utah", "Puerto Rico", "Iowa", "Nevada", "Arkansas",
                 "Mississippi", "Kansas", "New Mexico", "Nebraska", "Idaho", "West Virginia", "Hawaii", "New Hampshire",
                 "Maine", "Montana", "Rhode Island", "Delaware", "South Dakota", "North Dakota", "Alaska",
                 "District of Columbia", "Vermont", "Wyoming")

#Populations from July 1st 2022 US Census estimates
population_per_state <- c(39029342, 30029572, 22244823, 19677151, 12972008, 12582032, 11756058, 10912876, 10698973, 10034113,
                          9261699, 8683619, 7785786, 7359197, 7051339, 6981974, 6833037, 6177957, 6164660, 5892539, 5839926,
                          5717184, 5282634, 5074296, 4590241, 4512310, 4240137, 4019800, 3626205, 3380800, 3221789, 3200517,
                          3177772, 3045637, 2940057, 2937150, 2113344, 1967923, 1939033, 1775156, 1440196, 1395231, 1385340,
                          1122867, 1093734, 1018396, 909824, 779261, 733583, 671803, 647064, 581381)

#State assingment to observation will have a probability based on population of the state
total_pop = sum(population_per_state)
probability_per_state <- population_per_state/total_pop

states <- sample(state_names, 5000, replace = TRUE, prob = probability_per_state)

baseline_survey <- data.frame(ID = 1:5000, assignment = assignment, age = ages, state = states)

#Racial identification data, from 2020 census
racial_makeup_data <- read.csv("~/CovidAdRCT/racial_makeup_data.csv")

racial_makeup_matrix <- as.matrix(racial_makeup_data[, c("white", "black", "native_american", "asian", "pacific_islander", "mixed_race")])
rownames(racial_makeup_matrix) <- racial_makeup_data$state

baseline_survey$race <- sapply(baseline_survey$state, function(state) {
  probabilities <- racial_makeup_matrix[state, , drop = FALSE]
  race_categories <- colnames(racial_makeup_matrix)
  sampled_race <- sample(race_categories, 1, replace = TRUE, prob = probabilities)
  return(sampled_race)
})

#Reading data on Hispanic populations by state from US Census to create an indicator variable for if someone is Hispanic
hispanic_data <- read.csv("~/CovidAdRCT/hispanic_state_data.csv")
baseline_survey <- merge(baseline_survey, hispanic_data, by='state')

#Generating a random number between 0 and 1 and comparing to Hispanic population in each state, 1 if rand num > hispanic, otherwise 0
generate_hispanic_indicator <- function(row) {
  random_number <- runif(1)
  if (random_number <= row['hispanic']) {
    return(1)
  } else {
    return(0)
  }
}

#Applying function, dropping old Hispanic variable
baseline_survey$Hispanic <- apply(baseline_survey, 1, generate_hispanic_indicator)
baseline_survey$hispanic <- NULL

#Merging party affiliation by state, NA values for those living in PR, data from Pew Research Center
affiliation_data <- read.csv("~/CovidAdRCT/affiliation_data.csv")
baseline_survey <- merge(baseline_survey, affiliation_data, by = 'state', all.x = TRUE)

#Generating party affiliation indicator
generate_party_affiliation_indicator <- function(row) {
  random_number <- runif(1)
  if (row["state"] == "Puerto Rico") {
    return(NA)
  } else if (!is.na(row["republican"]) && random_number <= as.numeric(row["republican"])) {
    return("Republican")
  } else if (!is.na(row["no_lean"]) && random_number <= (as.numeric(row["republican"]) + as.numeric(row["no_lean"]))) {
    return("No Lean")
  } else {
    return("Democrat")
  }
}

#Applying function and dropping obsolete variables
baseline_survey$affiliation <- apply(baseline_survey, 1, generate_party_affiliation_indicator)
baseline_survey[c("republican","democrat","no_lean")] <- NULL

education_data <- read.csv("~/CovidAdRCT/education.csv")
baseline_survey <- merge(baseline_survey, education_data, by = 'state', all.x = TRUE)

#Generating education indicator, data from US Census
generate_education_indicator <- function(row) {
  random_number <- runif(1)
   if (random_number <= as.numeric(row["graduate"])) {
    return("graduate")
  } else if (random_number <= (as.numeric(row["bachelor"]))) {
    return("bachelor")
  } else if (random_number <= (as.numeric(row["high_school"]))){
    return("high school")
  } else {
      return("No high school")
    }
  }

baseline_survey$education <- apply(baseline_survey, 1, generate_education_indicator)
baseline_survey[c("graduate","bachelor","high_school")] <- NULL

#Vaccination_status_pre-treatment, data from the CDC's breakdown of vaccination status by demographics
baseline_survey <- baseline_survey %>%
  mutate(
    vaccinated_pre = ifelse(
        affiliation == "Democrat" & runif(n()) <= 0.72 |
        affiliation == "Republican" & runif(n()) <= 0.54 |
        affiliation == "No Lean" & runif(n()) <= 0.67, 1, 0
    )
  )

baseline_survey <- baseline_survey %>%
  mutate(
    booster_pre = ifelse(
      vaccinated_pre == 1 & runif(n()) <= 0.61,
      1, 0
    )
  )

#Adding NA's for each response, different chances respondents will decline to state a demographic indicator
baseline_survey <- baseline_survey %>%
  mutate(
    vaccinated_pre = ifelse(runif(n()) <= 0.1, NA, vaccinated_pre),
    booster_pre = ifelse(!is.na(vaccinated_pre), booster_pre, NA),
    age = ifelse(runif(n()) <= 0.025, NA, age),
    Hispanic = ifelse(runif(n()) <= 0.025, NA, Hispanic),
    race = ifelse(runif(n()) <= 0.05, NA, race),
    affiliation = ifelse(runif(n()) <= 0.1, NA, affiliation),
    education = ifelse(runif(n()) <= 0.05, NA, education)
  )

#Saving survey data to directory
write.csv(baseline_survey, "~/CovidAdRCT/baseline_survey.csv", row.names = FALSE)

### This is the end of the baseline survey ###