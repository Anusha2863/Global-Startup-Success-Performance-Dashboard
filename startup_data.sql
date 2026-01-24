select * from globals limit 20

SELECT *
FROM globals
LIMIT 5;

ALTER TABLE globals
RENAME COLUMN "Country" TO country;

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'globals'
  AND table_name = 'startup_data';

 SELECT column_name
FROM information_schema.columns
WHERE table_name = 'globals';

##Total funding by country
SELECT
    country,
    SUM("Total Funding ($M)") AS total_funding_m
FROM globals
GROUP BY country
ORDER BY total_funding_m DESC;

##Startups that raised more than average funding
SELECT *
FROM globals
WHERE "Total Funding ($M)" >
      (SELECT AVG("Total Funding ($M)") FROM globals);
	  
##Top 5 industries by average success score
SELECT
    "Industry",
    AVG("Success Score") AS avg_success
FROM globals
GROUP BY "Industry"
ORDER BY avg_success DESC
LIMIT 5;

##Average funding by funding stage
SELECT
    "Funding Stage",
    AVG("Total Funding ($M)") AS avg_funding
FROM globals
GROUP BY "Funding Stage";

##Valuation comparison: IPO vs Acquired vs Neither
SELECT
    CASE
        WHEN "IPO?" = 'Yes' THEN 'IPO'
        WHEN "Acquired?" = 'Yes' THEN 'Acquired'
        ELSE 'Neither'
    END AS exit_type,
    AVG("Valuation ($B)") AS avg_valuation
FROM globals
GROUP BY exit_type;

##Top 5 countries by average success score
SELECT
    country,
    AVG("Success Score") AS avg_success
FROM globals
GROUP BY country
ORDER BY avg_success DESC
LIMIT 5;

##Startup age segmentation
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - "Founded Year" <= 3 THEN 'New'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - "Founded Year" BETWEEN 4 AND 7 THEN 'Growing'
        ELSE 'Mature'
    END AS startup_stage,
    COUNT(*) AS startup_count
FROM globals
GROUP BY startup_stage;

##Top 3 industries per country by funding
SELECT country, "Industry", total_funding
FROM (
    SELECT
        country,
        "Industry",
        SUM("Total Funding ($M)") AS total_funding,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY SUM("Total Funding ($M)") DESC
        ) AS rn
    FROM globals
    GROUP BY country, "Industry"
) sub
WHERE rn <= 3;


##Are high-revenue startups more likely to IPO?
SELECT
    "IPO?",
    COUNT(*) AS startup_count
FROM globals
WHERE "Annual Revenue ($M)" >
      (SELECT AVG("Annual Revenue ($M)") FROM globals)
GROUP BY "IPO?";
##Revenue contribution by startup age group
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - "Founded Year" < 5 THEN 'Under 5 years'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - "Founded Year" BETWEEN 5 AND 10 THEN '5–10 years'
        ELSE '10+ years'
    END AS age_group,
    SUM("Annual Revenue ($M)") AS total_revenue
FROM globals
GROUP BY age_group
ORDER BY total_revenue DESC;

##Which industries have the highest average success score?
SELECT 
    "Industry",
    ROUND(AVG("Success Score"), 2) AS avg_success_score
FROM globals
GROUP BY "Industry"
ORDER BY avg_success_score DESC;

##Is there a relationship between total funding and valuation?
SELECT 
    "Startup Name",
    "Total Funding ($M)",
    "Valuation ($B)"
FROM globals
WHERE "Total Funding ($M)" IS NOT NULL
  AND "Valuation ($B)" IS NOT NULL;

##Which countries have the highest number of successful startups?
SELECT 
    "country",
    COUNT(*) AS successful_startups
FROM globals
WHERE "Success Score" >= 70
GROUP BY "country"
ORDER BY successful_startups DESC;

##Do startups with higher social media followers have higher revenue?
SELECT 
    "Startup Name",
    "Social Media Followers",
    "Annual Revenue ($M)"
FROM globals
WHERE "Social Media Followers" IS NOT NULL
  AND "Annual Revenue ($M)" IS NOT NULL;


