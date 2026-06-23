Samajh gaya, simple plain version dobara deta hoon — bilkul wahi jo pehle diya tha, clean copy-paste ke liye:

Food Delivery Analytics Project
An end-to-end data analytics project covering data cleaning, relational database design, SQL analysis, and interactive dashboarding — built on a simulated food delivery business dataset.
Problem Statement
A food delivery company wants to understand cancellation patterns, restaurant and delivery partner performance, and customer behavior to improve operational efficiency and customer retention.
Tools Used
ToolPurposeExcelData cleaning, validation, formula-driven summary dashboardSQL (MySQL)Relational schema design, data cleaning at scale, business analysis queriesPower BIInteractive 3-page dashboard with DAX measures and slicers
Project Structure
├── Food_Delivery_Excel_Analysis.xlsx     # Raw + cleaned sheets, formula-driven summary

├── 01_schema.sql                          # Database schema (5 tables, foreign keys, indexes)

├── 02_data_cleaning.sql                   # Duplicate removal, anomaly handling, standardization

├── 03_analysis_queries.sql                # 10 business queries (joins, CTEs, window functions)

├── customers_clean.csv

├── restaurants_clean.csv

├── delivery_partners_clean.csv

├── orders_clean.csv

├── payments_clean.csv

└── Food_Delivery_Power_BI_Dashboard.pbix  # 3-page interactive dashboard
Data Model
A star-schema-style relational model with Orders as the central fact table, connected to three dimension tables and one closely linked transaction table:

Customers → Orders (One-to-Many)
Restaurants → Orders (One-to-Many)
Delivery_Partners → Orders (One-to-Many)
Orders → Payments (One-to-One)

Data Cleaning
The raw dataset was deliberately generated with realistic data quality issues to demonstrate cleaning workflow:

Inconsistent city name casing/spacing (e.g., "Bhopal", " BHOPAL")
Duplicate Order IDs
Negative/zero order values (data entry errors)
Missing delivery times and customer ratings (mostly tied to cancelled orders)
Inconsistent payment mode text ("upi", "UPI", blank values)

Excel: TRIM, PROPER, COUNTIF (duplicate flagging), VLOOKUP (cross-table lookups), COUNTIFS/SUMIFS/AVERAGEIFS (formula-driven summary dashboard).
SQL: Self-join based duplicate removal, NULL-based anomaly handling (rather than fabricating replacement values), CASE-based text standardization.
SQL Analysis Highlights
03_analysis_queries.sql includes 10 business questions, covering:

City-wise revenue and cancellation rate (JOIN + GROUP BY)
Top restaurants per city (window function: RANK() OVER PARTITION BY)
Month-over-month order growth (LAG())
Churn-risk customers — 3+ cancellations (CTE + HAVING)
Restaurants below their city's average rating (correlated subquery)
Customer Lifetime Value segmentation (CTE + CASE)
Running revenue totals (window function)
New vs. repeat customer trends

Power BI Dashboard
Page 1 — Overview: Total Revenue, Total Orders, Cancellation Rate (KPI cards); Revenue and cancellation rate by city; Top 10 restaurants by revenue; Payment mode distribution.
Page 2 — Operations: Order status breakdown; Delivery partner performance; Average delivery time by vehicle type and city.
Page 3 — Customer Analysis: Customer distribution by city; Gender split; Average rating by city; Top 10 customers by order volume.
Includes a City slicer for interactive, self-serve filtering across all visuals.
Key Insights

Certain cities (e.g., Bhopal) showed a noticeably higher cancellation rate than others, suggesting potential delivery partner capacity issues worth investigating.
A small set of top-performing restaurants accounted for a disproportionate share of revenue.
Digital payment methods (UPI, Credit Card) together accounted for roughly half of all transactions.
Average delivery time remained fairly consistent across cities and vehicle types, indicating balanced operational performance.

Limitations

Data is synthetically generated for practice purposes, not real production data.
Payment failure reasons are not captured in the dataset.
No customer review/feedback text is available for sentiment analysis.

Author
Built as a self-driven analytics practice project to demonstrate an end-to-end Excel → SQL → Power BI workflow.
