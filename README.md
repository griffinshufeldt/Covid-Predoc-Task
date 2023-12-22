# Covid Data Simulation Exercise
Repository for the data simulation exercise. Assigning those in treatment groups with different types of ads (emotional, logic, or none) to see impact on covid vaccination. 

# Instructions For Reproduction

## Baseline Survey Data
The first script that should be run is the baseline_data.R file. This script creates the baseline survey data. The only library that this script uses is dplyr

The assignment variable's value was randomized across 5000 observations, each value: emotion, reason, and control with the same chance of being assigned to an observation. The ID variable is essential for later analysis as it is used to merge baseline and endline survey data. 

The age ranges and probabilities are sourced from Statistia, which has information on Facebook user's age. Similiarly for gender, Statistia has data on gender by age range. There is an appropriate weight for each age range, once an age range has been randomly selected, an age within that age range is then randomly selected, with each age in the subset having an equal weight.

The state variable has probabilities depending on the population of the particular state, calculated by a state's population over the total population. 

The US Census has data on race and ethnicity by state, using this, the Race variable has weights dependent on the individual's state that they, at this point, have already been assigned. Hispanic is defined in the same way, but as a seperate indicator variable. A random number is generated between 1 and 0, if it's greater than the percentage as a decimal of hispanic identifying people in a state, the observation is not hispanic, and vice versa. After this, we can drop the hispanic. The data I read in for Race and Hispanic identification can be found in this repository in the "Demographics" folder. 

Party affiliation varies by state, from Pew Research Center I used data to assign party affiliation by an observations state. This dataset can also be found in this repository "affiliation.csv" in the Demographics folder. Education is defined the same way, same folder.

I assigned vaccination status by party affiliation, with probabilities from the CDC's analysis on demographics: "Demographic Differences in Compliance with COVID-19 Vaccination Timing and Completion Guidelines in the United States". Among those who are vaccinated, they had their own probability of getting a booster shot.

After the assignment of these demographic variables, I dropped certain percentages of each variable, larger percentages are assigned to those that I imagine to be more personal or sensitive, and thus would be more likely to be left blank on a survey. 

The final line is writing and saving the data set created. Change path to desired directory. 


## Endline Survey Data

Next, the endline survey can be replicated by reading in the previously constructed Baseline Survey. I make the assumpton that those in the control group are more likely to drop out of the survey, as they are not exposed to the treatment. 

I apply these probabilities to each observation and sample 4500 observations based on them, as requested.

The next pipes are for randomly assigning chances in vaccination status among those already vaccinated, but don't yet have the booster, and those who aren't vaccinated at all. I am assigning probabilities such that those who are not vaccinated are going to be more likely to be conviced by emotional advertisements, because much of the discourse at this point has been filled with more arguments that employ reason in the public sphere, if they still aren't vaccinated it seems unlikely that a facebook ad would have more of a way over their decision than one that is more emotionally appealing. I make the opposite assumption for those who are vaccinated, as, if they are already vaccinated they may value this type of reasoning, as it's likely the reason they got vaccinated in the first place. 

The final line is for saving this data set. 

## Analysis
This is the final script that should be executed. The libraries are dplyr, stargazer, ggplot2, and gtsummary, for data manipulation, regression analysis, data visualization, and summary statistics respectively. As mentioned before, the data is combined by ID. Then, I facotrize the categorical variables so that we can observe visually trends. I create Boxplots and Histograms, comparing pre and post vaccination outcomes. 

The regression analysis first is univariate, if we assume this is a successful RCT this is mainly what we're interested in, as people regressed to the mean in an RCT will be the same except for their treatment status. The multivariate scripts later on show small and statistically insignificant differences in point estiamtes compared to no controls. This script is logged, the file of which is included in this directory. 
