
library(tidyverse)
install.packages("tidytuesdayR")
library(here)
library(tidyverse)

# tests if a directory named "data" exists locally
if (!dir.exists(here("data"))) {
  dir.create(here("data"))
}

# saves data only once (not each time you knit a R Markdown)
if (!file.exists(here("data", "chocolate.RDS"))) {
  url_csv <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-18/chocolate.csv"
  chocolate <- readr::read_csv(url_csv)

  # save the file to RDS objects
  saveRDS(chocolate, file = here("data", "chocolate.RDS"))
}



#1.Make a histogram of the rating scores to visualize the overall distribution of scores. Change the number of bins from the default to 10, 15, 20, and 25. Pick on the one that you think looks the best. Explain what the difference is when you change the number of bins and explain why you picked the one you did.
chocolate <- readRDS(here("data", "chocolate.RDS"))
as_tibble(chocolate)
library(tidyverse)
ggplot(data=chocolate, aes(rating))+
  geom_histogram()+
  stat_bin(bins = 25)
#The fewer bins we use, the wider each bin will be. I choose 25, because this can help the bars not overlap with each other

# 2.Consider the countries where the beans originated from. How many reviews come from each country of bean origin?
library(dplyr)
chocolate2<-chocolate%>%gather(country_of_bean_origin)
library(ggplot2)
ggplot(data=chocolate, aes(country_of_bean_origin))+
  geom_bar()

#3.What is average rating scores from reviews of chocolate bars that have Ecuador as country_of_bean_origin in this dataset? For this same set of reviews, also calculate (1) the total number of reviews and (2) the standard deviation of the rating scores. Your answer should be a new data frame with these three summary statistics in three columns. Label the name of these columns mean, sd, and total.

ecuador_rating <- chocolate %>%
  filter(country_of_bean_origin == "Ecuador") %>%
  summarise(mean = mean(rating), total = sum(rating), sd= sd(rating))
print(ecuador_rating)

# A tibble: 1 × 3
mean total    sd
<dbl> <dbl> <dbl>
  1  3.16   693 0.512

#4.Which company makes the best chocolate (or has the highest ratings on average) with beans from Ecuador?
library(dplyr)

max_mean_value <- chocolate %>%
  filter(country_of_bean_origin == "Ecuador")%>%
  group_by(company_manufacturer) %>%
  summarise(mean_rating = mean(rating)) %>%
  arrange(desc(mean_rating))
View(max_mean_value)
#Amano,Benoit Nihant,Beschle (Felchlin),Durci,Smooth Chocolator, The

#5.Calculate the average rating across all country of origins for beans. Which top 3 countries have the highest ratings on average?
average_value <- chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(mean_rating = mean(rating)) %>%
  arrange(desc(mean_rating)) %>%
  slice(3)
third_highest_country <- average_value$country_of_bean_origin
print(third_highest_country)
#Sao, Tome and principe

#6.Following up on the previous problem, now remove any countries of bean origins that have less than 10 chocolate bar reviews. Now, which top 3 countries have the highest ratings on average?
library(dplyr)
review_counts <- chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(review_count = n())

filtered_reviews <- review_counts %>%
  filter(review_count >= 10)


filtered_chocolate <- chocolate %>%
  semi_join(filtered_reviews, by = "country_of_bean_origin")

average_ratings <- filtered_chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(mean_rating = mean(rating)) %>%
  arrange(desc(mean_rating))

top_3_countries <- head(average_ratings, 3)


library(dplyr)

review_counts <- chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(review_count = n())

filtered_reviews <- review_counts %>%
  filter(review_count >= 10)

filtered_chocolate <- chocolate %>%
  semi_join(filtered_reviews, by = "country_of_bean_origin")

average_ratings <- filtered_chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(mean_rating = mean(rating)) %>%
  arrange(desc(mean_rating))

top_3_countries <- head(average_ratings, 3)
print(top_3_countries)
#country_of_bean_origin mean_rating
<chr>                        <dbl>
  1 Solomon Islands               3.45
2 Congo                         3.32
3 Cuba                          3.29

#7.For this last part, let’s explore the relationship between percent chocolate and ratings.
##Identify the countries of bean origin with at least 50 reviews. Remove reviews from countries are not in this list.
review_counts <- chocolate %>%
  group_by(country_of_bean_origin) %>%
  summarise(review_count = n())

filtered_reviews <- review_counts %>%
  filter(review_count >= 50)

filtered_chocolate <- chocolate %>%
  semi_join(filtered_reviews, by = "country_of_bean_origin")

print(filtered_chocolate)
##Using the variable describing the chocolate percentage for each review, create a new column that groups chocolate percentages into one of four groups: (i) <60%, (ii) >=60 to <70%, (iii) >=70 to <90%, and (iii) >=90% (Hint check out the substr() function in base R and the case_when() function from dplyr – see example below).
chocolate_cocoa_percent <- filtered_chocolate %>%
  mutate(chocolate_group = case_when(
    cocoa_percent < 60 ~ "<60%",
    cocoa_percent >= 60 & cocoa_percent < 70 ~ ">=60 to <70%",
    cocoa_percent >= 70 & cocoa_percent < 90 ~ ">=70 to <90%",
    cocoa_percent >= 90 ~ ">=90"))
##Using the new column described in #2, re-order the factor levels (if needed) to be starting with the smallest percentage group and increasing to the largest percentage group (Hint check out the fct_relevel() function from forcats).
chocolate_cocoa_percent$cocoa_percent <- factor(
  chocolate_cocoa_percent$cocoa_percent,
  levels = c("<60%", ">=60 to <70%", ">=70 to <90%", ">=90%")
)
chocolate_cocoa_percent_reordered <- fct_relevel(chocolate_cocoa_percent$cocoa_percent, "<60%", ">=60 to <70%", ">=70 to <90%", ">=90%")
View(chocolate_cocoa_percent)
##For each country, make a set of four side-by-side boxplots plotting the groups on the x-axis and the ratings on the y-axis. These plots should be faceted by country.
ggplot(chocolate_cocoa_percent, aes(x = chocolate_group, y = rating)) +
  geom_boxplot() +
  facet_wrap(~ country_of_bean_origin, scales = "free_x", ncol = 4) +
  labs(x = "Chocolate Percentage Group", y = "Ratings")
##On average, which category of chocolate percentage is most highly rated? Do these countries mostly agree or are there disagreements?
chocolate_rate <- chocolate_cocoa_percent %>%
  group_by(chocolate_group) %>%
  summarise(mean_rating = mean(rating))

first_mean_rating <- head(chocolate_rate$mean_rating, 1)

print(first_mean_rating)

first_chocolate_group <- chocolate_rate %>%
  filter(mean_rating == first_mean_rating) %>%
  pull(chocolate_group)

print(first_chocolate_group)
#Overall, higher chocolate percentage have higher rating. So agree.

#part 2
#1.Use this dataset it to create a new column called continent in our chocolate dataset that contains the continent name for each review where the country of bean origin is.
install.packages("gapminder")
library(gapminder)
library(dplyr)
gapminder2 <- gapminder %>%
  select(country, continent)%>%
rename(country_of_bean_origin=country)
continent <- left_join(chocolate, gapminder2, by = "country_of_bean_origin")


#2.Only keep reviews that have reviews from countries of bean origin with at least 10 reviews
library(dplyr)

review_counts <- continent %>%
  group_by(country_of_bean_origin) %>%
  summarise(num_reviews = n())


continent2 <- continent %>%
  inner_join(review_counts, by = "country_of_bean_origin")


continent3 <- continent2 %>%
  group_by(country_of_bean_origin) %>%
  filter(num_reviews >= 10) %>%
  ungroup()

continent4 <- continent3 %>%
  group_by(country_of_bean_origin) %>%
  filter()


# 3.Filter out rows where 'country_of_bean_origin' is equal to "Blend"
library(dplyr)
continent_filtered <- continent4 %>%
  filter(country_of_bean_origin != "Blend")


#Make a set of violin plots with ratings on the y-axis and continents on the x-axis
library(ggplot2)

na_count <- sum(is.na(continent_filtered))
print(na_count)
rename(continent_filtered,na=continent)

ggplot(continent_filtered, aes(x = continent, y = rating)) +
  geom_violin() +
  labs(
    title = "Violin Plot of Ratings by Continent",
    x = "Continent",
    y = "Rating"
  )


#part3:Convert wide data into long data
##1.Create a new set of columns titled beans, sugar, cocoa_butter, vanilla, letchin, and salt that contain a 1 or 0 representing whether or not that review for the chocolate bar contained that ingredient (1) or not (0).

library(dplyr)

# Assuming you have a dataset named 'continent_filtered' (or replace with your dataset)
new_column_ingredients <- mutate(chocolate,
                                 beans = ifelse(grepl("beans", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 sugar = ifelse(grepl("sugar", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 cocoa_butter = ifelse(grepl("cocoa|butter", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 vanilla = ifelse(grepl("vanilla", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 lecithin = ifelse(grepl("lecithin", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 salt = ifelse(grepl("salt", most_memorable_characteristics, ignore.case = TRUE), 1, 0)
)
View(new_column_ingredients)
#2.Create a new set of columns titled char_cocoa, char_sweet, char_nutty, char_creamy, char_roasty, char_earthy that contain a 1 or 0 representing whether or not that the most memorable characteristic for the chocolate bar had that word (1) or not (0). For example, if the word “sweet” appears in the most_memorable_characteristics, then record a 1, otherwise a 0 for that review in the char_sweet column (Hint: check out str_detect() from the stringr package).
new_column_ingredients2 <- mutate(new_column_ingredients,
                                 char_cocoa = ifelse(grepl("cocoa", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 char_sweet = ifelse(grepl("sweet", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 char_nutty = ifelse(grepl("nutty", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 char_creamy = ifelse(grepl("creamy", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 char_roasty = ifelse(grepl("roasty", most_memorable_characteristics, ignore.case = TRUE), 1, 0),
                                 char_earthy = ifelse(grepl("earthy", most_memorable_characteristics, ignore.case = TRUE), 1, 0)
)
View(new_column_ingredients2)

#3.For each year (i.e. review_date), calculate the mean value in each new column you created across all reviews for that year.

review_mean_value <- new_column_ingredients2 %>%
  group_by(review_date) %>%
  summarise(
    mean_beans = mean(beans),
    mean_sugar = mean(sugar),
    mean_cocoa_butter = mean(cocoa_butter),
    mean_vanilla = mean(vanilla),
    mean_lecithin = mean(lecithin),
    mean_salt = mean(salt),
    mean_char_cocoa = mean(char_cocoa),
    mean_char_sweet = mean(char_sweet),
    mean_char_nutty = mean(char_nutty),
    mean_char_creamy = mean(char_creamy),
    mean_char_roasty = mean(char_roasty),
    mean_char_earthy = mean(char_earthy)
  )
View(review_mean_value)
glimpse(review_mean_value)

#Convert this wide dataset into a long dataset with a new feature and mean_score column
library(tidyr)

# Convert from wide to long format
long_dataset <- review_mean_value %>%
  pivot_longer(
    cols = starts_with("mean_"),
    names_to = "feature",
    values_to = "mean_score"
  )

# View the resulting long dataset
View(long_dataset)

library(ggplot2)

ggplot(long_dataset, aes(x = review_date, y = mean_score, col = feature)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  labs(
    title = "Time Trend for Mean Scores",
    subtitle = "Since 2015, more and more cocoa and cocoa_butter are put in the chocolate",
    x = "time",
    y = "Mean Score",
    caption = "Xinyu Liu"
  )

#Part 5: Make the worst plot you can!

library(ggplot2)

ggplot(long_dataset, aes(x = review_date, y = mean_score))+
  geom_col()

#Make my plot a better plot
##separate different features
library(ggplot2)

ggplot(long_dataset, aes(x = review_date, y = mean_score, col=feature))+
  geom_col()

##separate bars to make them not stack together
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col() +
  facet_wrap(~ feature, scales = "free_y")

##adjust width of bars to make them well separated
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col(width=0.7) +
  facet_wrap(~ feature, scales = "free_y")

##add title to this picture
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col(width=0.7) +
  facet_wrap(~ feature, scales = "free_y")+
labs(title = "Time Trend for Mean Scores")

##edit names of X-axis and Y-axis
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col(width=0.7) +
  facet_wrap(~ feature, scales = "free_y")+
labs(
  title = "Time Trend for Mean Scores",
  x = "time",
  y = "Mean Score")
##change the column transparency
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col(width=0.7,alpha = 0.7) +
  facet_wrap(~ feature, scales = "free_y")+
labs(
  title = "Time Trend for Mean Scores",
  x = "time",
  y = "Mean Score")
##add a theme
ggplot(long_dataset, aes(x = review_date, y = mean_score, fill = feature)) +
  geom_col(width=0.7,alpha = 0.7) +
  facet_wrap(~ feature, scales = "free_y")+
  labs(
    title = "Time Trend for Mean Scores",
    x = "time",
    y = "Mean Score")+
  theme_minimal()


