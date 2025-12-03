📊 Bellabeat Growth Strategy: Data-Driven Recommendations for User Engagement

This project performs a case study analysis on daily activity data from the Bellabeat smart device to uncover key insights into how customers use the product. The goal is to provide data-driven recommendations that will inform Bellabeat's marketing strategy and drive growth by focusing on user engagement and habit creation.

Visualization and Key Findings:

The complete interactive dashboard presenting the findings is available on Tableau Public:
Tableau Public Dashboard Link

💡 Executive Summary

The analysis reveals that the majority of users (56%) fall into the "Lightly Active" and "Sedentary" tiers. Furthermore, a significant drop in activity is observed every Friday, suggesting a clear intervention point. The core recommendation is to shift the marketing focus from high-volume goals (e.g., 10,000 steps) to consistency and lower-friction habit creation tailored to these lower-activity segments.

Key Recommendations:

Prioritize Consistency (7-Day Metric): De-emphasize high-volume goals and prioritize the "7-Day Streaks" or consistency days, as the data shows overall consistency is a better predictor of high daily steps than focusing purely on active minutes.

Own the "Friday Slump": Implement specific, low-effort "Weekend Warmup" content or push notifications every Friday at 4 PM to trigger unstructured activity before the drop-off.

Dual-Track Content Strategy:

Track A (Gentle Wellness): Target the 56% low-activity majority with gentle yoga, meditation, and guided sleep (low-friction habit creation).

Track B (Performance & Power): Reserve advanced HIIT challenges and high-intensity workouts for the minority of "Very Active" users.

🛠️ Methodology and Tools

This capstone followed the standard data analysis process (Ask, Prepare, Process, Analyze, Share, Act).

1. Data Source

Dataset: FitBit Fitness Tracker Data (CC0 Public Domain).

Time Period: 04/12/2016 – 05/12/2016 (31 days).

Scope: The analysis was limited to the dailyActivity_merged.csv file, focusing on daily steps, activity minutes, and consistency patterns.

2. Processing and Cleaning (BigQuery and SQL)

The raw data required cleaning to ensure validity and structure before analysis.

Tool: Google BigQuery

Action: Created a new table (master_daily_analysis_final) by joining the relevant daily activity tables.

Cleaning Criteria: Filtered out records where total_steps were less than 500 to exclude days where the device was likely not worn (ensuring data integrity).

3. Analysis and Visualization (Tableau)

Four key questions were answered to drive the strategic recommendations:

Question

Visualization Type

Key Finding

User Segmentation?

Bar Chart (Activity Segment)

56% of users are "Lightly Active" or "Sedentary".

When is Activity Lowest?

Line Chart (Day of Week)

Average total steps drop significantly every Friday.

What Drives High Steps?

Scatter Plot (Consistency vs. Steps)

A strong positive correlation between "Overall Consistency Days" and "Average Daily Steps."

Who are the Performance Users?

Scatter Plot (Intensity Profile)

Users who are "Very Active" also tend to have high "Lightly Active" minutes, suggesting dual-track content is needed.

📂 Repository Contents

This repository contains the necessary files to replicate the analysis:

Bellabeat_SQL_Data_Cleaning.sql: Contains the BigQuery SQL query used to clean and create the final analysis table.

Cleaned_data_Bellabeat.csv: The final cleaned dataset exported from BigQuery, used as the source for Tableau visualization.

Bellabeat_Marketing_Strategy_Insights_from_Activity_Data.pdf: A brief PDF summarizing the final presentation and recommendations (optional deliverable).

Project Completed by Shilpa LR Analyst
