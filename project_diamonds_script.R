# nolint start”

# Diamonds dataset - Statistical Analysis

# 1) Explore dataset and examine what variables affect the price of diamonds
# 1.1) Importing libraries

library(tidyverse)
library(ggplot2)
library(skimr)
library(corrplot)
library(lmtest)
library(car)

# 1.2) Importing dataset

diamonds <- read_csv("~/Downloads/diamonds.csv")
head(diamonds)
View(diamonds)

# 1.3) Explore dataset and preprocessing
## Create a copy
my_diamonds <- diamonds

skim_without_charts(my_diamonds)
## COMMENTS: The minimum values for Length or Width or Height are 0, but it doesn't make much sense

subset(my_diamonds, x == 0 | y == 0 | z == 0)
## COMMENTS: This 20 values are going to be drop, since they have of the dimensions 0

my_diamonds <- my_diamonds[!(my_diamonds$x == 0 | my_diamonds$y == 0 | my_diamonds$z == 0), ]


## Remove index
my_diamonds <- my_diamonds[, -1]
View(my_diamonds)


## Categorical variables
categorical_variables <- c("cut", "color", "clarity")

categorical_my_diamonds <- my_diamonds[, categorical_variables]

## Numeric variables
numeric_variables <- setdiff(names(my_diamonds), categorical_variables) # Extracting from all variables the ones that are not in categorical_variables

numeric_my_diamonds <- my_diamonds[, numeric_variables]

## Variables distribution
### Categorical variables
ggplot(my_diamonds, aes(x=color)) +
  geom_bar(fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x=cut)) + 
  geom_bar(fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x=clarity)) + 
  geom_bar(fill = "#5D666D") +
  theme_minimal()
## COMMENTS: * color: most diamonds have a color E, F, and G, that means that they are colorless or near colorless.
##           * cut: most diamonds have an ideal, premium or very good cut.
##           * clarity: most diamonds have SI1 and VS2, so small imperfections.


### Numeric variables
#### Distributions
ggplot(my_diamonds, aes(x = carat)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = log(carat))) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = depth)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = table)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = log(table))) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = price)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = x)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = log(y))) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = z)) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()

ggplot(my_diamonds, aes(x = log(z))) + 
  geom_histogram(binwidth = 0.1, fill = "#5D666D") +
  theme_minimal()
## COMMENTS: when the distribution is skewed, in order to solve this the logarithm was applied, to helps to stabilize variance and make the distribution more symmetric.

## COMMENTS: 



## Correlation between numeric variables
### Calculate the correlation matrix
corr_matrix <- cor(numeric_my_diamonds)

corrplot(corr_matrix, method = "square", type = "upper", tl.cex = 0.7, tl.col = "black", cex.lab = 0.8)
## COMMENTS: * There are high correlations between price and carat, and also it's dimensions.
##           * The dimensions are highly correlated with each other.
##           * The depth and price are inversely related.


## Correlation between categorical variables and target
### Cut
fairDiamonds <- filter(my_diamonds, my_diamonds$cut == 'Fair')
premiumDiamonds <- filter(my_diamonds, my_diamonds$cut == 'Premium')
idealDiamonds <- filter(my_diamonds, my_diamonds$cut == 'Ideal')
goodDiamonds <- filter(my_diamonds, my_diamonds$cut == 'Good')
par(mfrow = c(2,2))
hist(fairDiamonds$price)
hist(premiumDiamonds$price)
hist(idealDiamonds$price)
hist(goodDiamonds$price)

### Clarity
ggplot(my_diamonds) + 
  geom_point(aes(x=price, y= carat)) + 
  facet_wrap(~ clarity, nrow = 2)

### Color
ggplot(my_diamonds) + 
  geom_point(aes(x=price, y= carat)) + 
  facet_wrap(~ color, nrow = 2)

my_diamonds %>% 
  ggplot(aes(x=log(carat), y=log(price))) + 
  geom_point(alpha=0.5) + 
  geom_smooth(method=lm, se = FALSE, color="#BDD631") +
  theme_minimal()

my_diamonds %>% 
  ggplot(aes(x=log(x), y=log(price))) + 
  geom_point(alpha=0.5) + 
  geom_smooth(method=lm, se = FALSE, color="#BDD631") +
  theme_minimal()

# Pairwise scatterplot
pairs(numeric_my_diamonds, col = "#5D666D")

view(my_diamonds)
# 2) Build the model
# 2.1) Level-Level Estimation
regressor_level <- lm(price ~ carat + depth + table + x + y + z + color + cut + clarity, data = my_diamonds)
regressor_level
summary(regressor_level)
# r2 = 0.9201
## COMMENTS: 


# 2.2) Level-log Estimation
regressor_level_log <- lm(price ~ log(carat) + log(depth) + log(table) + log(x) + log(y) + log(z) + color + cut + clarity, data = my_diamonds)
summary(regressor_level_log)

# 2.3) Log-level Estimation
regressor_log_level <- lm(log(price) ~ carat + depth + table + x + y + z +  color + cut + clarity, data = my_diamonds)
summary(regressor_log_level)

# 2.4) Mixed forms estimation
regressor_mixed <- lm(log(price) ~ log(carat) + depth + table + log(x) + y + z + color + cut + clarity, data = my_diamonds)
summary(regressor_mixed)

#After examining the p-values of all functional form specifications, it is possible to say that all of them
#present similar low p-values for the majority of the variables. Having low p-values is desirable given that
#these values mirror the individual statistical significance of the predictors: the lower the p-value,
#the more important the predictor is to the model. However, after careful examination,
#the one that presents the general smaller p-values is the the specification with the logarithmic
#transformations only on *live* and *acous*, and this is the model that will be used on the rest of the analysis.

# 3) Variable selection
# 3.1) Remove highly correlated predictors
#check the code for the problem
#cor(songs[,c('popularity', 'bpm', 'nrgy', 'dnce', 'dB', 'live', 'val', 'dur', 'acous', 'spch')])

# Now that some models have been tested it is time to further analyze highly correlated predictors.
#The variable *dB* is highly correlated with *nrgy* and it is the one with highest p-value,
#therefore it is the least important. Let's estimate the model again without this variable.


# It is possible to confirm that the standard error of *nrgy* has decreased, as well as its p-value,
#therefore becoming now significant to the model.
#Furthermore, the majority of the other variables p-values has also decreased a little.
#Although removing highly correlated variables from the model may result in biased estimates because of
#the violation of the OLS zero conditional mean assumption,
#the decision to remove or keep these variables is always a trade off.
#In this case the overall estimates become more significant, as well as the R-squared,
#therefore the decision taken is to not process with the inclusion of *dB* in the model.

# 3.2) Removal of not significant variables
#The dummy variable *solo* estimate presents a fairly high p-value,
#meaning that the variable is not statistically significant in explaining the outcome of the model.
#There is a high probability that the relationship between the variable and the target is due to chance.
#In this case, it is not be worth keeping the variable in the model as it does not provide any meaningful information.

# 4) Heteroskedasticity test
final_reg <- regressor_mixed

# 4.1) Breusch-Pagan test
bptest(final_reg)

# 4.2) White-Special
bptest(final_reg, ~I(fitted(final_reg)) + I(fitted(final_reg)^2))

# p-value = < 2.2e-16 -> we do not reject the null hypothesis at a 5% significance level

## COMMENTS:
# Both tests indicate the evidence of heteroskedasticity.
# This means that the variance of the residuals is not constant, 
# leading to incorrect statistical inferences and hypothesis testing.

#To account for heteroskedasticity, it is necessary to use a robust OLS estimator.

# 4.3) Robust estimator
coeftest(final_reg, vcov = hccm)

# The robust estimates show higher p-values for variables y and z, consequently becoming less significant.
# We can create and evaluate another model without these variables to comparison:

model_without_yz <- lm(log(price) ~ log(carat) + depth + table + log(x) + color + cut + clarity, data = my_diamonds)
coeftest(model_without_yz, vcov = hccm)

# 5) Misspecifications test
resettest(final_reg, vcov = hccm)

# The RESET test is used to check if if non-linear functions of the independent variables are
# significant when added to the model.
# The null hypothesis states that the coefficient of all non-linear functions of the independent variables equals zero.
# As the RESET test return a low p-value, which indicates that there is misspecification in our model.
# We've tried to add non-linearity (squared and cube terms) to the model in order to account for it but without success.

# nolint end”