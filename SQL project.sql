
------------------------------------Domestic Visitors Analysis----------------------------------------------------

-- Analysis 1: Total Visitors per District
-- Identify districts with the highest and lowest domestic visitor numbers.
SELECT district, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY total_visitors DESC

-- Analysis 2: Total Visitors per Year
-- Understand overall domestic tourism trends across Telangana over the years.
SELECT year, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY year
ORDER BY year

-- Analysis 3: Total Visitors per Month Across All Years
-- Identify seasonal patterns in domestic tourism.
SELECT month, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY month
ORDER BY total_visitors DESC

-- Analysis 4: Average Visitors per District
-- Determine the average monthly visitor count for each district.
SELECT district, AVG(visitors) AS average_visitors
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY average_visitors DESC

-- Analysis 5: Average Visitors per Year
-- Analyze average monthly visitor trends across years.
SELECT year, AVG(visitors) AS average_visitors
FROM domestic_visitors_final_data
GROUP BY year
ORDER BY year

-- Analysis 6: Average Visitors per Month
-- Understand typical visitor numbers for each month across all years.
SELECT month, AVG(visitors) AS average_visitors
FROM domestic_visitors_final_data
GROUP BY month
ORDER BY average_visitors DESC

-- Analysis 7: Top 5 Districts with the Highest Total Visitors
-- Highlight the top-performing districts in terms of visitor numbers.
SELECT Top 5 district, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY total_visitors DESC


-- Analysis 8: Bottom 5 Districts with the Lowest Total Visitors
-- Identify districts with the least visitor activity.
SELECT Top 5 district, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY total_visitors ASC


-- Analysis 9: Year-over-Year Growth Rate for Total Visitors
-- Assess the overall growth of domestic tourism across Telangana.

WITH yearly_totals AS (
    SELECT year, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY year
)
SELECT 
    yt1.year,
    yt1.total_visitors AS current_year,
    yt2.total_visitors AS previous_year,
    CASE 
        WHEN yt2.total_visitors IS NOT NULL AND yt2.total_visitors > 0 
        THEN 
            CAST(yt1.total_visitors - yt2.total_visitors AS FLOAT) 
            / yt2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM yearly_totals yt1
LEFT JOIN yearly_totals yt2 ON yt2.year = yt1.year - 1
ORDER BY yt1.year


-- Analysis 10: Month-over-Month Growth Rate (Year-over-Year for Each Month)
-- Analyze growth trends for each month across consecutive years.
WITH monthly_totals AS (
    SELECT year, month, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY year, month
)
SELECT 
    mt1.year,
    mt1.month,
    mt1.total_visitors AS current_month,
    mt2.total_visitors AS previous_year_same_month,
    CASE 
        WHEN mt2.total_visitors IS NOT NULL AND mt2.total_visitors > 0 
        THEN 
            CAST(mt1.total_visitors - mt2.total_visitors AS FLOAT) 
            / mt2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM monthly_totals mt1
LEFT JOIN monthly_totals mt2 
    ON mt2.year = mt1.year - 1 AND mt1.month = mt2.month
ORDER BY mt1.month, mt1.year


-- Analysis 11: Districts with the Highest Growth Rate from 2016 to 2019
-- Identify districts with the most significant increase in visitors.

WITH district_yearly AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district, year
)
SELECT 
    dy1.district,
    dy1.total_visitors AS visitors_2019,
    dy2.total_visitors AS visitors_2016,
    CASE 
        WHEN dy2.total_visitors IS NOT NULL AND dy2.total_visitors > 0 
        THEN 
            CAST(dy1.total_visitors - dy2.total_visitors AS FLOAT) 
            / dy2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM district_yearly dy1
LEFT JOIN district_yearly dy2 
    ON dy1.district = dy2.district AND dy2.year = 2016
WHERE dy1.year = 2019
ORDER BY growth_rate DESC

-- Analysis 12: Districts with the Lowest Growth Rate from 2016 to 2019
-- Identify districts with declining or stagnant visitor numbers.

WITH district_yearly AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district, year
)
SELECT 
    dy1.district,
    dy1.total_visitors AS visitors_2019,
    dy2.total_visitors AS visitors_2016,
    CASE 
        WHEN dy2.total_visitors IS NOT NULL AND dy2.total_visitors > 0 
        THEN 
            CAST(dy1.total_visitors - dy2.total_visitors AS FLOAT) 
            / dy2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM district_yearly dy1
LEFT JOIN district_yearly dy2 
    ON dy1.district = dy2.district AND dy2.year = 2016
WHERE dy1.year = 2019
ORDER BY growth_rate ASC

-- Analysis 13: Seasonal Trends: Months with the Highest Visitor Numbers
-- Confirm seasonal patterns in tourism.

SELECT month, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY month
ORDER BY total_visitors DESC

-- Analysis 14: Districts with Zero Visitors in Any Month
-- Identify data gaps or districts with no tourism activity.

SELECT district, date, month, year
FROM domestic_visitors_final_data
WHERE visitors = 0


-- Analysis 15: Percentage of Total Visitors Each District Contributes
-- Understand the relative contribution of each district to overall tourism.

WITH district_totals AS (
    SELECT district, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district
),
grand_total AS (
    SELECT SUM(total_visitors) AS grand_total
    FROM district_totals
)
SELECT 
    dt.district, 
    dt.total_visitors, 
    CAST(dt.total_visitors AS FLOAT) / gt.grand_total * 100 AS percentage
FROM district_totals dt
CROSS JOIN grand_total gt
ORDER BY percentage DESC



-- Analysis 16: Month with the Highest Visitors for Each District
-- Identify peak tourism months for individual districts.

WITH monthly_district_totals AS (
    SELECT district, month, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district, month
),
ranked AS (
    SELECT district, month, total_visitors,
           RANK() OVER (PARTITION BY district ORDER BY total_visitors DESC) AS rnk
    FROM monthly_district_totals
)
SELECT district, month, total_visitors
FROM ranked
WHERE rnk = 1


-- Analysis 17: Year with the Highest Visitors for Each District
-- Identify when each district peaked in visitor numbers.

WITH yearly_district_totals AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district, year
),
ranked AS (
    SELECT district, year, total_visitors,
           RANK() OVER (PARTITION BY district ORDER BY total_visitors DESC) AS rnk
    FROM yearly_district_totals
)
SELECT district, year, total_visitors
FROM ranked
WHERE rnk = 1


-- Analysis 18: Total Visitors for Each District in Each Year
-- Provide a detailed breakdown of visitor numbers by district and year.

SELECT district, year, SUM(visitors) AS total_visitors
FROM domestic_visitors_final_data
GROUP BY district, year
ORDER BY district, year

-- Analysis 19: Year-over-Year Growth Rate for Each District
--- Analyze growth trends for each district annually.

WITH district_yearly AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM domestic_visitors_final_data
    GROUP BY district, year
)
SELECT 
    dy1.district,
    dy1.year,
    dy1.total_visitors AS current_year,
    dy2.total_visitors AS previous_year,
    CASE 
        WHEN dy2.total_visitors IS NOT NULL AND dy2.total_visitors > 0 
        THEN 
            CAST(dy1.total_visitors - dy2.total_visitors AS FLOAT) 
            / dy2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM district_yearly dy1
LEFT JOIN district_yearly dy2 
    ON dy1.district = dy2.district AND dy2.year = dy1.year - 1
WHERE dy1.year > (SELECT MIN(year) FROM district_yearly)
ORDER BY dy1.district, dy1.year



-- Analysis 20: Districts with the Most Consistent Visitor Numbers
-- Identify districts with the least variation in visitor numbers.


SELECT district, STDEV(CAST(visitors AS FLOAT)) AS stddev_visitors
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY stddev_visitors ASC

-- 21 Highest Visitor Density per District (Visitors/Days Reported)

SELECT district,
       SUM(visitors) AS total_visitors,
       COUNT(DISTINCT date) AS days_reported,
       CAST(SUM(visitors) AS FLOAT) / COUNT(DISTINCT date) AS visitor_density
FROM domestic_visitors_final_data
GROUP BY district
ORDER BY visitor_density DESC


------------------------------------------------------------------------------------------------------------------

----------------------------------------------- Foreign Visitors Analysis--------------------------------------------------------------



-- Analysis 1: Total Visitors per District
SELECT district, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY total_visitors DESC

-- Analysis 2: Total Visitors per Year
SELECT year, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY year
ORDER BY year

-- Analysis 3: Total Visitors per Month Across All Years
SELECT month, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY month
ORDER BY total_visitors DESC

-- Analysis 4: Average Visitors per District
SELECT district, AVG(visitors) AS average_visitors
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY average_visitors DESC

-- Analysis 5: Average Visitors per Year
SELECT year, AVG(visitors) AS average_visitors
FROM foreign_visitors_final_data
GROUP BY year
ORDER BY year

-- Analysis 6: Average Visitors per Month
SELECT month, AVG(visitors) AS average_visitors
FROM foreign_visitors_final_data
GROUP BY month
ORDER BY average_visitors DESC

-- Analysis 7: Top 5 Districts with the Highest Total Visitors
SELECT TOP 5 district, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY total_visitors DESC

-- Analysis 8: Bottom 5 Districts with the Lowest Total Visitors
SELECT TOP 20 district, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY total_visitors ASC

-- Analysis 9: Year-over-Year Growth Rate for Total Visitors
WITH yearly_totals AS (
    SELECT year, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY year
)
SELECT 
    yt1.year,
    yt1.total_visitors AS current_year,
    yt2.total_visitors AS previous_year,
    CASE 
        WHEN yt2.total_visitors IS NOT NULL AND yt2.total_visitors > 0 
        THEN 
            CAST(yt1.total_visitors - yt2.total_visitors AS FLOAT) 
            / yt2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM yearly_totals yt1
LEFT JOIN yearly_totals yt2 ON yt2.year = yt1.year - 1
ORDER BY yt1.year

-- Analysis 10: Month-over-Month Growth Rate (Year-over-Year for Each Month)
WITH monthly_totals AS (
    SELECT year, month, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY year, month
)
SELECT 
    mt1.year,
    mt1.month,
    mt1.total_visitors AS current_month,
    mt2.total_visitors AS previous_year_same_month,
    CASE 
        WHEN mt2.total_visitors IS NOT NULL AND mt2.total_visitors > 0 
        THEN 
            CAST(mt1.total_visitors - mt2.total_visitors AS FLOAT) 
            / mt2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM monthly_totals mt1
LEFT JOIN monthly_totals mt2 
    ON mt2.year = mt1.year - 1 AND mt1.month = mt2.month
ORDER BY mt1.month, mt1.year

-- Analysis 11: Districts with the Highest Growth Rate from 2016 to 2019
WITH district_yearly AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY district, year
)
SELECT 
    dy1.district,
    dy1.total_visitors AS visitors_2019,
    dy2.total_visitors AS visitors_2016,
    CASE 
        WHEN dy2.total_visitors IS NOT NULL AND dy2.total_visitors > 0 
        THEN 
            CAST(dy1.total_visitors - dy2.total_visitors AS FLOAT) 
            / dy2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM district_yearly dy1
LEFT JOIN district_yearly dy2 
    ON dy1.district = dy2.district AND dy2.year = 2016
WHERE dy1.year = 2019
ORDER BY growth_rate DESC

-- Analysis 12: Districts with the Lowest Growth Rate from 2016 to 2019
WITH yearly_data AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    WHERE year IN (2016, 2019)
    GROUP BY district, year
),
pivoted AS (
    SELECT 
        district,
        MAX(CASE WHEN year = 2016 THEN total_visitors END) AS visitors_2016,
        MAX(CASE WHEN year = 2019 THEN total_visitors END) AS visitors_2019
    FROM yearly_data
    GROUP BY district
),
growth_calc AS (
    SELECT 
        district,
        visitors_2016,
        visitors_2019,
        CASE 
            WHEN visitors_2016 IS NOT NULL AND visitors_2016 > 0 THEN 
                ROUND(((visitors_2019 - visitors_2016) * 100.0) / visitors_2016, 2)
            ELSE NULL
        END AS growth_rate
    FROM pivoted
)
SELECT *
FROM growth_calc
ORDER BY growth_rate ASC


-- Analysis 13: Seasonal Trends: Months with the Highest Visitor Numbers
SELECT month, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY month
ORDER BY total_visitors DESC

-- Analysis 14: Districts with Zero Visitors in Any Month
SELECT district, date, month, year
FROM foreign_visitors_final_data
WHERE visitors = 0

-- Analysis 15: Percentage of Total Visitors Each District Contributes
WITH district_totals AS (
    SELECT district, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY district
),
grand_total AS (
    SELECT SUM(total_visitors) AS grand_total
    FROM district_totals
)
SELECT 
    dt.district, 
    dt.total_visitors, 
    CAST(dt.total_visitors AS FLOAT) / gt.grand_total * 100 AS percentage
FROM district_totals dt
CROSS JOIN grand_total gt
ORDER BY percentage DESC

-- Analysis 16: Month with the Highest Visitors for Each District
WITH monthly_district_totals AS (
    SELECT district, month, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY district, month
),
ranked AS (
    SELECT district, month, total_visitors,
           RANK() OVER (PARTITION BY district ORDER BY total_visitors DESC) AS rnk
    FROM monthly_district_totals
)
SELECT district, month, total_visitors
FROM ranked
WHERE rnk = 1

-- Analysis 17: Year with the Highest Visitors for Each District
WITH yearly_district_totals AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY district, year
),
ranked AS (
    SELECT district, year, total_visitors,
           RANK() OVER (PARTITION BY district ORDER BY total_visitors DESC) AS rnk
    FROM yearly_district_totals
)
SELECT district, year, total_visitors
FROM ranked
WHERE rnk = 1

-- Analysis 18: Total Visitors for Each District in Each Year
SELECT district, year, SUM(visitors) AS total_visitors
FROM foreign_visitors_final_data
GROUP BY district, year
ORDER BY district, year

-- Analysis 19: Year-over-Year Growth Rate for Each District
WITH district_yearly AS (
    SELECT district, year, SUM(visitors) AS total_visitors
    FROM foreign_visitors_final_data
    GROUP BY district, year
)
SELECT 
    dy1.district,
    dy1.year,
    dy1.total_visitors AS current_year,
    dy2.total_visitors AS previous_year,
    CASE 
        WHEN dy2.total_visitors IS NOT NULL AND dy2.total_visitors > 0 
        THEN 
            CAST(dy1.total_visitors - dy2.total_visitors AS FLOAT) 
            / dy2.total_visitors * 100 
        ELSE NULL 
    END AS growth_rate
FROM district_yearly dy1
LEFT JOIN district_yearly dy2 
    ON dy1.district = dy2.district AND dy2.year = dy1.year - 1
WHERE dy1.year > (SELECT MIN(year) FROM district_yearly)
ORDER BY dy1.district, dy1.year

-- Analysis 20: Districts with the Most Consistent Visitor Numbers
SELECT district, STDEV(CAST(visitors AS FLOAT)) AS stddev_visitors
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY stddev_visitors ASC

-- Analysis 21: Highest Visitor Density per District (Visitors/Days Reported)
SELECT district,
       SUM(visitors) AS total_visitors,
       COUNT(DISTINCT date) AS days_reported,
       CAST(SUM(visitors) AS FLOAT) / COUNT(DISTINCT date) AS visitor_density
FROM foreign_visitors_final_data
GROUP BY district
ORDER BY visitor_density DESC