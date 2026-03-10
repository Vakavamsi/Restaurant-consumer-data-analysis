DROP database if exists `Restaurant_Consumer_db`;
CREATE DATABASE `Restaurant_Consumer_db`;
USE `Restaurant_Consumer_db`;

# Create The Consumer Table

CREATE TABLE consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(10,7),
    Longitude DECIMAL(10,7),
    Smoker VARCHAR(10),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(50),
    Marital_Status VARCHAR(20),
    Children VARCHAR(50),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(20)
);
select * from consumers;


# Create Table Restaurants

CREATE TABLE restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Zip_Code VARCHAR(10),
    Latitude DECIMAL(10,8),
    Longitude DECIMAL(11,8),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(50),
    Price VARCHAR(20),
    Franchise VARCHAR(10),
    Area VARCHAR(20),
    Parking VARCHAR(50)
);
select * from restaurants;



# Create Restaurant_cuisines

CREATE TABLE restaurant_cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(255),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);
select * from restaurant_cuisines;



# Create consumer_preferences Table

CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(255),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID)
);
select * from consumer_preferences;



# Create Ratings Table

CREATE TABLE ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);

select * from ratings;





# Using the WHERE clause to filter data based on specific criteria.

# 1. List all details of consumers who live in the city of 'Cuernavaca'.
select * 
from consumers 
where city='Cuernavaca';

# Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select Consumer_ID,Age,Occupation 
from consumers 
where Occupation='Student' and Smoker='Yes';

# List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.

select Name,City,Alcohol_Service,Price
from restaurants 
where Alcohol_Service='Wine & Beer' And Price='Medium';


#Find the names and cities of all restaurants that are part of a 'Franchise'.
select Name,City
from restaurants 
where Franchise='Yes';

# Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).
select Consumer_ID,Restaurant_ID,Overall_Rating
from ratings
where Overall_Rating=2;

# JOINS
# Questions JOINs with Subqueries

# 1.List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.

select DISTINCT Name,City # which it removes duplicate name having multiple of 2
from restaurants re
join ratings ra
on re.restaurant_ID=ra.restaurant_ID
where ra.Overall_Rating=2;

# 2.Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.

SELECT DISTINCT c.Consumer_ID, c.Age
FROM consumers c
JOIN ratings ra 
    ON c.Consumer_ID = ra.Consumer_ID
JOIN restaurants re 
    ON ra.Restaurant_ID = re.Restaurant_ID 
WHERE re.City = 'San Luis Potosi';


# 3.List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select distinct r.Name 
from restaurants r
join restaurant_cuisines rc 
	on r.restaurant_ID=rc.restaurant_ID
join ratings ra 
	on r.restaurant_ID=ra.restaurant_ID
WHERE rc.Cuisine='Mexican' 
	AND ra.Consumer_id='U1001';


# 4.Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
SELECT *
FROM consumers c
JOIN consumer_preferences cp
	ON c.consumer_ID=cp.consumer_ID
WHERE Preferred_Cuisine='American' 
	AND Budget='Medium';

# 5.List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.

SELECT re.name,re.city 
from restaurants re
JOIN ratings ra
ON re.restaurant_ID=ra.restaurant_ID
where Food_rating<(
		select avg(food_rating)
        from ratings
        );
 
# 6.Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.

SELECT distinct c.Consumer_ID, c.Age, c.Occupation
FROM consumers c
JOIN ratings r
	ON c.consumer_ID=r.consumer_ID
WHERE c.consumer_ID NOT IN(
		SELECT r2.consumer_ID
        FROM ratings r2
        JOIN restaurant_cuisines rc
			ON r2.restaurant_id=rc.restaurant_ID
		WHERE rc.cuisine='Italian'
        );

# 7.List restaurants (Name) that have received ratings from consumers older than 30.

select distinct re.name 
from restaurants re
join ratings ra
on re.restaurant_id=ra.restaurant_ID
join consumers c
on ra.consumer_ID=c.consumer_ID
where c.age>30;

# 8.Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).

SELECT distinct c.Consumer_ID,c.Occupation
FROM consumers c
JOIN consumer_preferences cp
	ON c.consumer_id=cp.consumer_id
JOIN ratings r
	ON c.consumer_ID=r.consumer_ID
WHERE cp.Preferred_cuisine='Mexican' and r.Overall_Rating=0;

# 9.List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.

SELECT DISTINCT r.Name, r.City
FROM restaurants r
JOIN restaurant_cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Pizzeria'
  AND r.City IN (
        SELECT c.City
        FROM consumers c
        WHERE c.Occupation = 'Student'
    );

# 10.Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.

SELECT c.Consumer_ID,c. Age 
FROM consumers c
JOIN ratings r
	ON c.consumer_ID=r.consumer_ID
JOIN restaurants re
	ON r.restaurant_ID=re.restaurant_ID
WHERE c.Drink_level='Social Drinker' 
	AND re.Parking='None';



# Questions Emphasizing WHERE Clause and Order of Execution

# 1.List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'.Show only students who have rated more than 2 restaurants.

SELECT r.Consumer_ID, COUNT(DISTINCT r.Restaurant_ID) AS Total_Restaurants_Rated
FROM ratings r
JOIN consumers c
    ON r.Consumer_ID = c.Consumer_ID
WHERE c.Occupation = 'Student'
GROUP BY r.Consumer_ID
HAVING COUNT(DISTINCT r.Restaurant_ID) > 2;

    

# 2.We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division).List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation.

SELECT 
    Consumer_ID,
    Age,
    Age DIV 10 AS Engagement_Score
FROM consumers
WHERE (Age DIV 10) = 2
  AND Transportation_Method = 'Public';


# 3.For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.

SELECT 
    r.Name,
    r.City,
    AVG(ra.Overall_Rating) AS Average_Overall_Rating
FROM restaurants r
JOIN ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE r.City = 'Cuernavaca'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(ra.Overall_Rating) > 1.0;


# 4.Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.

SELECT 
    c.Consumer_ID,
    c.Age
FROM consumers c
JOIN ratings r
    ON c.Consumer_ID = r.Consumer_ID
WHERE c.Marital_Status = 'Married'
  AND r.Overall_Rating = 2
  AND r.Food_Rating = r.Service_Rating;

# 5.List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
SELECT 
    c.Consumer_ID,
    c.Age,
    r.Name AS Restaurant_Name
FROM consumers c
JOIN ratings ra 
    ON c.Consumer_ID = ra.Consumer_ID
JOIN restaurants r
    ON ra.Restaurant_ID = r.Restaurant_ID
WHERE c.Occupation = 'Employed'
  AND ra.Food_Rating = 0
  AND r.City = 'Ciudad Victoria';



# Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures

# 1.Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.

WITH slp_consumers AS (
  SELECT Consumer_ID, Age
  FROM consumers
  WHERE City = 'San Luis Potosi'
)
SELECT DISTINCT
  s.Consumer_ID,
  s.Age,
  r.Name AS Restaurant_Name
FROM slp_consumers s
JOIN ratings rt
  ON s.Consumer_ID = rt.Consumer_ID
  AND rt.Overall_Rating = 2
JOIN restaurants r
  ON rt.Restaurant_ID = r.Restaurant_ID
JOIN restaurant_cuisines rc
  ON r.Restaurant_ID = rc.Restaurant_ID
  AND rc.Cuisine = 'Mexican'
ORDER BY s.Consumer_ID, r.Name;


# 2.For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. (Use a derived table to get consumers who have rated).

SELECT 
    c.Occupation,
    AVG(c.Age) AS Average_Age
FROM consumers c
JOIN (
        SELECT DISTINCT Consumer_ID
        FROM ratings
     ) rated_consumers
     ON c.Consumer_ID = rated_consumers.Consumer_ID
GROUP BY c.Occupation;


# 3.Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first).Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.

WITH cuernavaca_ratings AS (
    SELECT
        r.Restaurant_ID,
        rt.Consumer_ID,
        rt.Overall_Rating
    FROM restaurants r
    JOIN ratings rt
        ON r.Restaurant_ID = rt.Restaurant_ID
    WHERE r.City = 'Cuernavaca'
),
consumer_avg AS (
    SELECT
        Consumer_ID,
        AVG(Overall_Rating) AS Avg_Consumer_Rating
    FROM ratings
    GROUP BY Consumer_ID
)
SELECT
    c.Restaurant_ID,
    c.Consumer_ID,
    c.Overall_Rating,
    RANK() OVER (PARTITION BY c.Restaurant_ID ORDER BY c.Overall_Rating DESC) AS RatingRank,
    ca.Avg_Consumer_Rating
FROM cuernavaca_ratings c
JOIN consumer_avg ca
    ON c.Consumer_ID = ca.Consumer_ID
ORDER BY c.Restaurant_ID, RatingRank;


# 4.For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.

SELECT 
    r.Consumer_ID,
    r.Restaurant_ID,
    r.Overall_Rating,
    AVG(r.Overall_Rating) OVER (PARTITION BY r.Consumer_ID) AS Avg_Overall_Rating_By_Consumer
FROM ratings r;


# 5.Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).

WITH low_budget_students AS (
    SELECT Consumer_ID
    FROM consumers
    WHERE Occupation = 'Student'
      AND Budget = 'Low'
),
ranked_preferences AS (
    SELECT 
        cp.Consumer_ID,
        cp.Preferred_Cuisine,
        ROW_NUMBER() OVER (
            PARTITION BY cp.Consumer_ID 
            ORDER BY cp.Consumer_ID, cp.Preferred_Cuisine
        ) AS rn
    FROM consumer_preferences cp
    INNER JOIN low_budget_students lbs
        ON cp.Consumer_ID = lbs.Consumer_ID
)
SELECT 
    Consumer_ID,
    Preferred_Cuisine
FROM ranked_preferences
WHERE rn <= 3
ORDER BY Consumer_ID, rn;

# 6.Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first.
SELECT
    t.Restaurant_ID,
    t.Overall_Rating,
    LEAD(t.Overall_Rating) OVER (ORDER BY t.Restaurant_ID) AS Next_Overall_Rating
FROM (
    SELECT 
        Restaurant_ID,
        Overall_Rating
    FROM ratings
    WHERE Consumer_ID = 'U1008'
) AS t
ORDER BY t.Restaurant_ID;


# 7.Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.

DROP VIEW IF EXISTS HighlyRatedMexicanRestaurants;

CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT 
    r.Restaurant_ID,
    r.Name,
    r.City
FROM restaurants r
JOIN restaurant_cuisines rc 
    ON r.Restaurant_ID = rc.Restaurant_ID
JOIN ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY 
    r.Restaurant_ID,
    r.Name,
    r.City
HAVING 
    AVG(ra.Overall_Rating) > 1.5;



# 8.First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.

WITH mexican_pref_consumers AS (
    SELECT DISTINCT Consumer_ID
    FROM consumer_preferences
    WHERE Preferred_Cuisine = 'Mexican'
),
consumers_who_rated_high_mex AS (
    SELECT DISTINCT r.Consumer_ID
    FROM ratings r
    JOIN HighlyRatedMexicanRestaurants h
        ON r.Restaurant_ID = h.Restaurant_ID
)
SELECT m.Consumer_ID
FROM mexican_pref_consumers m
LEFT JOIN consumers_who_rated_high_mex c
    ON m.Consumer_ID = c.Consumer_ID
WHERE c.Consumer_ID IS NULL;

# 9.Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.
DELIMITER $$
CREATE PROCEDURE GetRestaurantRatingsAboveThreshold(
    IN p_Restaurant_ID VARCHAR(10),
    IN p_MinRating DECIMAL(3,1)
)
BEGIN
    SELECT 
        Consumer_ID,
        Overall_Rating,
        Food_Rating,
        Service_Rating
    FROM ratings
    WHERE Restaurant_ID = p_Restaurant_ID
      AND Overall_Rating >= p_MinRating;
END $$
DELIMITER ;


# 10.Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.
WITH avg_ratings AS (
    SELECT 
        r.Restaurant_ID,
        r.Name AS Restaurant_Name,
        r.City,
        rc.Cuisine,
        AVG(rt.Overall_Rating) AS Avg_Rating
    FROM restaurants r
    JOIN restaurant_cuisines rc 
        ON r.Restaurant_ID = rc.Restaurant_ID
    JOIN ratings rt
        ON r.Restaurant_ID = rt.Restaurant_ID
    GROUP BY 
        r.Restaurant_ID, r.Name, r.City, rc.Cuisine
),
ranked_restaurants AS (
    SELECT 
        Cuisine,
        Restaurant_Name,
        City,
        Avg_Rating,
        DENSE_RANK() OVER (
            PARTITION BY Cuisine 
            ORDER BY Avg_Rating DESC
        ) AS rating_rank
    FROM avg_ratings
)
SELECT 
    Cuisine,
    Restaurant_Name,
    City,
    Avg_Rating AS Overall_Rating
FROM ranked_restaurants
WHERE rating_rank <= 2   -- top 2 rankings (ties included)
ORDER BY Cuisine, Overall_Rating DESC;


# 11.First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.
# Step 1: Create the View — ConsumerAverageRatings
CREATE OR REPLACE VIEW ConsumerAverageRatings AS
SELECT 
    Consumer_ID,
    AVG(Overall_Rating) AS Avg_Overall_Rating
FROM ratings
GROUP BY Consumer_ID;

# Step 2: Use a CTE to Get Top 5 Consumers + Count of Mexican Restaurants Rated
WITH top5_consumers AS (
    SELECT 
        Consumer_ID,
        Avg_Overall_Rating
    FROM ConsumerAverageRatings
    ORDER BY Avg_Overall_Rating DESC
    LIMIT 5
),
mexican_ratings AS (
    SELECT
        r.Consumer_ID,
        COUNT(*) AS Mexican_Rated_Count
    FROM ratings r
    JOIN restaurant_cuisines rc
        ON r.Restaurant_ID = rc.Restaurant_ID
    WHERE rc.Cuisine = 'Mexican'
    GROUP BY r.Consumer_ID
)
SELECT
    t.Consumer_ID,
    t.Avg_Overall_Rating,
    COALESCE(m.Mexican_Rated_Count, 0) AS Mexican_Rated_Count
FROM top5_consumers t
LEFT JOIN mexican_ratings m
    ON t.Consumer_ID = m.Consumer_ID
ORDER BY t.Avg_Overall_Rating DESC;


# 12.Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.

/* The procedure should:
1. Determine the consumer's "Spending Segment" based on their Budget:
'Low' -> 'Budget Conscious'
'Medium' -> 'Moderate Spender'
'High' -> 'Premium Spender'
NULL or other -> 'Unknown Budget'*/

DROP PROCEDURE IF EXISTS GetConsumerSegmentAndRestaurantPerformance;

DELIMITER $$

CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(
    IN p_Consumer_ID VARCHAR(20)
)
BEGIN
    DECLARE v_budget VARCHAR(20);
    DECLARE v_segment VARCHAR(50);

    -- Get the consumer's budget
    SELECT Budget INTO v_budget
    FROM consumers
    WHERE Consumer_ID = p_Consumer_ID;

    -- Determine Spending Segment
    IF v_budget = 'Low' THEN
        SET v_segment = 'Budget Conscious';
    ELSEIF v_budget = 'Medium' THEN
        SET v_segment = 'Moderate Spender';
    ELSEIF v_budget = 'High' THEN
        SET v_segment = 'Premium Spender';
    ELSE
        SET v_segment = 'Unknown Budget';
    END IF;

    -- Output
    SELECT 
        p_Consumer_ID AS Consumer_ID,
        v_budget AS Budget,
        v_segment AS Spending_Segment;

END $$

DELIMITER ;

/*2. For all restaurants rated by this consumer:
List the Restaurant_Name.
The Overall_Rating given by this consumer.
The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).*/
    -- Part 2: Restaurant Performance for this consumer
SELECT 
    cr.Restaurant_ID,
    rest.Name AS Restaurant_Name,
    cr.Overall_Rating AS Consumer_Rating,
    
    -- Average rating from ALL consumers
    (SELECT AVG(Overall_Rating)
     FROM ratings
     WHERE Restaurant_ID = cr.Restaurant_ID) AS Restaurant_Avg_Rating,
     
    -- Performance flag
    CASE
        WHEN cr.Overall_Rating >
             (SELECT AVG(Overall_Rating)
              FROM ratings
              WHERE Restaurant_ID = cr.Restaurant_ID)
        THEN 'Above Average'
        
        WHEN cr.Overall_Rating =
             (SELECT AVG(Overall_Rating)
              FROM ratings
              WHERE Restaurant_ID = cr.Restaurant_ID)
        THEN 'At Average'
        
        ELSE 'Below Average'
    END AS Performance_Flag,
    
    -- Ranking
    RANK() OVER (
        ORDER BY cr.Overall_Rating DESC
    ) AS Rating_Rank
    
FROM ratings cr
JOIN restaurants rest 
    ON cr.Restaurant_ID = rest.Restaurant_ID
WHERE cr.Consumer_ID = 'U1008';  -- Replace with any consumer ID



