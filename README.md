# sql-etl-netflix-pipeline
End-to-end ETL pipeline for Netflix titles dataset built in SQL Server using T-SQL

# Netflix Titles ETL Pipeline — SQL Server

## Project Overview
An end-to-end ETL pipeline built in Microsoft SQL Server using T-SQL,
designed to ingest, investigate, clean, and model a real-world dataset
of 8,807 Netflix titles into a structured, analytics-ready data warehouse.

## Business Context
Raw Netflix titles data arrives as a CSV file with multiple data quality issues
including nulls, duplicates, mixed formats, and multi-valued columns.
This pipeline transforms the raw data into a clean, reliable reporting layer
with dimension tables and analytics views ready to feed a BI tool like Power BI.

## Pipeline Architecture
netflix_titles.csv → Python pre-processing → netflix_raw (staging)
↓
netflix_clean (production table)
↓
dim_ratings + dim_country + netflix_countries (dimension & bridge tables)
↓
5 Analytics Views (reporting layer)
↓
CTE-based business intelligence queries

## Data Quality Issues Identified & Resolved
| Issue | Column | Rows Affected | Resolution |
|---|---|---|---|
| NULL values | director | 2,633 | Replaced with 'Unknown' |
| NULL values | cast | 825 | Replaced with 'Not Specified' |
| NULL values | country | 831 | Replaced with 'Unknown' |
| NULL values | rating | 11 | Replaced with 'Not Rated' |
| NULL values | duration | 4 | Replaced with 'Not Specified' |
| NULL values | date_added | 3 | Replaced with NULL — TRY_CONVERT |
| Duplicate records | title, type, release_year | 6 | Kept first occurrence |
| Mixed date formats | date_added | All rows | Converted using TRY_CONVERT |
| Invalid release_year | release_year | 2 rows | Excluded using ISNUMERIC filter |
| Multi-valued column | country | 733 rows | Split using STRING_SPLIT into bridge table |
| Referential integrity | dim_ratings | 4 missing ratings | Added missing values to dimension table |
| Wrong column data | rating | 3 rows | Updated using UPDATE WHERE LIKE |

## Technical Skills Demonstrated
- CSV ingestion using Python and SQL Server BULK INSERT
- Staging table pattern — raw data preserved before transformation
- Full root cause analysis — investigation before any fix is applied
- T-SQL transformations — ISNULL, NULLIF, TRIM, TRY_CAST, TRY_CONVERT
- Duplicate removal using MIN and GROUP BY subquery
- Date conversion using TRY_CONVERT with format code 107
- Dimension table design and referential integrity checking
- Multi-valued column normalisation using STRING_SPLIT and CROSS APPLY
- Bridge table design for many-to-many relationships
- INNER JOIN and LEFT JOIN across multiple tables
- LEFT JOIN pattern for finding referential integrity gaps
- Conditional aggregation using SUM(CASE WHEN)
- Common Table Expressions — single and chained CTEs
- Window functions — SUM() OVER() for running totals
- Analytics is viewed as a reusable reporting layer

## Database Objects Created
| Object | Type | Description |
|---|---|---|
| netflix_raw | Table | Staging table — raw CSV data |
| netflix_clean | Table | Cleaned production table — 8,799 rows |
| dim_ratings | Table | Rating descriptions and audience classifications |
| dim_country | Table | Country region and continent reference data |
| netflix_countries | Table | Bridge table — one row per title per country |
| vw_content_overview | View | Full content view with ratings and country enrichment |
| vw_country_performance | View | Content volume by country and continent |
| vw_rating_summary | View | Content breakdown by rating and audience |
| vw_yearly_trend | View | Content growth by release year |
| vw_director_performance | View | Director output and career span analysis |

## Business Questions Answered
- How many movies vs. TV shows are on Netflix?
- Which countries produce the most content?
- What is the most common content rating?
- How has Netflix content grown year over year?
- Which directors have the longest active careers on Netflix?
- What percentage of content comes from each continent?
- Running total of titles added over time

## Tools Used
- Microsoft SQL Server Developer Edition
- SQL Server Management Studio (SSMS)
- Python — CSV pre-processing
- Git Bash — version control
- T-SQL

## Key Learnings
- Real-world data is always messier than expected — investigate before fixing
- Dimension tables require the same validation as fact tables
- Multi-valued columns must be normalised before JOINs work correctly
- Bridge tables solve many-to-many relationships cleanly
- CTEs make complex multi-step queries readable and maintainable
- Window functions enable time-series analysis without collapsing rows
