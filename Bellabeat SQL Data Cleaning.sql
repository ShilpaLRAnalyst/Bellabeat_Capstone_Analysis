BellaBeat Capstone Project

Cleaning:

Pre-Feature engineering 

#Code for daily_activity_clean

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean` AS
SELECT
  -- 1. Id to STRING
  CAST(Id AS STRING) AS user_id,
  
  -- 2. CRITICAL DATE FIX (ActivityDate is already DATE)
  ActivityDate AS activity_date,

  -- 3. Standardize and Select Core Metrics
  TotalSteps AS total_steps,
  TotalDistance AS total_distance,
  Calories AS total_calories,
  SedentaryMinutes AS sedentary_minutes,
  LightlyActiveMinutes AS lightly_active_minutes,
  FairlyActiveMinutes AS fairly_active_minutes,
  VeryActiveMinutes AS very_active_minutes,
  
  -- 4. Derived Column
  (LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes) AS total_active_minutes
FROM
  `bellabeat-capstone-478805.bellabeat_data.dailyActivity_raw`
-- GROUP BY 1..10 is correct to enforce uniqueness on all selected columns
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;


#Checking if the daily_activity_clean table is clean

SELECT
  COUNT(DISTINCT user_id) AS total_users,
  MIN(activity_date) AS first_date,
  MAX(activity_date) AS last_date
FROM
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean`;


This should show you 33 unique users and the date range for your data, confirming the cleaning and saving were successful.


#Code for sleep_data_clean(Pre-feature cleaning engineering)

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.sleep_data_clean` AS
SELECT
  CAST(Id AS STRING) AS user_id,
  PARSE_DATE('%m/%d/%Y', SPLIT(SleepDay, ' ')[OFFSET(0)]) AS sleep_date,

  -- CRITICAL NUMERIC FIX: CAST STRING to INT64
  CAST(TotalSleepRecords AS INT64) AS total_sleep_records,
  CAST(TotalMinutesAsleep AS INT64) AS minutes_asleep,
  CAST(TotalTimeInBed AS INT64) AS minutes_in_bed
FROM
  `bellabeat-capstone-478805.bellabeat_data.sleepDay_raw`
GROUP BY 1, 2, 3, 4, 5
HAVING COUNT(*) = 1;

FEATURE Engineering CLEANING 

There are 5 feature engineering steps and 1 merging table step. So in order to have Optimized Feature engineering plan,
we have 4 queries we execute:-

#1. QUERY 1:user segmentation (Daily Activity )

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.user_segments` AS
SELECT
  user_id,
  
  -- Calculate Average Daily Metrics
  AVG(total_steps) AS avg_daily_steps,
  AVG(total_calories) AS avg_daily_calories,
  COUNT(activity_date) AS total_logged_days,
  
  -- Create the Activity Segment 
  CASE
    WHEN AVG(total_steps) < 5000 THEN 'Sedentary'
    WHEN AVG(total_steps) >= 5000 AND AVG(total_steps) < 7500 THEN 'Lightly Active'
    WHEN AVG(total_steps) >= 7500 AND AVG(total_steps) < 10000 THEN 'Fairly Active'
    ELSE 'Very Active'
  END AS activity_segment
FROM
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean`
GROUP BY
  user_id;


#2.Feature Engineering: Query 2 (Daily Activity Enrichment)

This query updates the existing daily_activity_clean table, adding two key features that help analyze when and how well users are active.
Features Added:
Day of Week (Step 2): Allows analysis of weekday vs. weekend habits.
Active/Sedentary Ratio (Step 3): Measures engagement quality (how much activity vs. sitting).

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean` AS
SELECT
  *, -- Select all existing clean columns
  
  -- Feature 2: Day of Week Name (e.g., 'Monday', 'Sunday')
  FORMAT_DATE('%A', activity_date) AS day_of_week,

  -- Feature 3: Active/Sedentary Ratio (Measures engagement quality)
  -- Use SAFE_DIVIDE to prevent division by zero errors
  SAFE_DIVIDE(total_active_minutes, sedentary_minutes) AS active_sedentary_ratio
FROM
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean`;

#3.Feature Engineering: Query 3 (Sleep Enrichment)
This query updates the existing sleep_data_clean table, adding two key features that measure the quality and readability of sleep metrics.
Features Added:
1.Sleep Efficiency (Step 4): Measures sleep quality (Minutes Asleep\Minutes In Bed)
2.Time in Bed (Hours) (Step 5): Converts minutes to a human-readable format.

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.sleep_data_clean` AS
SELECT
  *, -- Select all existing clean columns
  
  -- Feature 4: Sleep Efficiency (Quality of sleep)
  SAFE_DIVIDE(minutes_asleep, minutes_in_bed) * 100 AS sleep_efficiency,
  
  -- Feature 5: Time in Bed (Hours) for easier visualization
  SAFE_DIVIDE(minutes_in_bed, 60) AS time_in_bed_hr
FROM
  `bellabeat-capstone-478805.bellabeat_data.sleep_data_clean`;


#4. Query 4: Final Master Merge (Step 6)
This is the final, most crucial query. It combines all your enriched tables (daily_activity_clean, sleep_data_clean, and user_segments) into one comprehensive table ready
 for analysis and visualization in Tableau.

#Code
CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.master_daily_analysis` AS
SELECT
  t1.*, -- Daily Activity features (steps, calories, day_of_week, ratio, etc.)
  
  -- Select Sleep Features
  t2.sleep_date,
  t2.total_sleep_records,
  t2.minutes_asleep,
  t2.minutes_in_bed,
  t2.sleep_efficiency, 
  t2.time_in_bed_hr, 

  -- Select Segmentation Features
  t3.avg_daily_steps,
  t3.total_logged_days AS overall_consistency_days, -- Rename for clarity
  t3.activity_segment
FROM
  `bellabeat-capstone-478805.bellabeat_data.daily_activity_clean` AS t1
LEFT JOIN
  `bellabeat-capstone-478805.bellabeat_data.sleep_data_clean` AS t2
  -- Join on both User ID and the Date (only works where both tables have data)
  ON t1.user_id = t2.user_id AND t1.activity_date = t2.sleep_date
LEFT JOIN
  `bellabeat-capstone-478805.bellabeat_data.user_segments` AS t3
  -- Join on only User ID (segmentation applies to every user day)
  ON t1.user_id = t3.user_id;


#Data Filtering (Last phase of data cleaning)

CREATE OR REPLACE TABLE
  `bellabeat-capstone-478805.bellabeat_data.master_daily_analysis_final` AS
SELECT
  * -- Select all columns from the master merged table
FROM
  `bellabeat-capstone-478805.bellabeat_data.master_daily_analysis`
WHERE
  -- Filter 1: Ensure enough steps were tracked (device was worn)
  total_steps >= 500
  AND
  -- Filter 2: Ensure the device was worn for a substantial part of the day
  sedentary_minutes >= 1000;
  
-- *** The sleep filter (minutes_in_bed >= 180) is removed to retain data! ***

Analysis continued in Tableau Public























































































