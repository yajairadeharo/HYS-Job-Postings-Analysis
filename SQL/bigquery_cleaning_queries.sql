-- Query 1: Initial Data Extraction and Categorical Standardization
CREATE OR REPLACE TABLE `ai_job_market.cleaned_jobs` AS SELECT
  -- 1. Standardize job titles into main categories
  CASE
    WHEN LOWER(`Job Title`) LIKE '%data scientist%' OR LOWER(`Job Title`) LIKE '%data science%' THEN 'Data Scientist'
    WHEN LOWER(`Job Title`) LIKE '%analyst%' THEN 'Data Analyst'
    WHEN LOWER(`Job Title`) LIKE '%data engineer%' THEN 'Data Engineer'
    WHEN LOWER(`Job Title`) LIKE '%machine learning%' OR LOWER(`Job Title`) LIKE '%ml%' OR LOWER(`Job Title`) LIKE '%ai%' THEN 'ML/AI Engineer'
    ELSE 'Other Tech Role'
  END AS standardized_title,

  -- 2. Clean up location and specifically tag California postings
  `Job Location` AS location,
  CASE
    WHEN LOWER(`Job Location`) LIKE '%ca%' OR LOWER(`Job Location`) LIKE '%california%' THEN 'California'
    ELSE 'Other US'
  END AS state_group,

  -- 3. Grab the raw Salary Range column to parse in Python later
  `Salary Range` AS salary_range,
  `Experience Level` AS experience_level,

  -- 4. Cleans up the column name that caused the earlier error
  `Remote _ Hybrid _ On-site` AS remote_status,

  -- 5. Grab the skills string
  `Required Skills` AS skills,
  `Programming Languages Required` AS programming_languages

FROM
  `ai_job_market.raw_jobs`
WHERE
  -- Keep US-only postings to make salary predictions accurate (in USD)
  (LOWER(Country) LIKE '%united states%'
    OR LOWER(Country) LIKE '%us%'
    OR LOWER(`Job Location`) LIKE '%ca%'
    OR LOWER(`Job Location`) LIKE '%california%')
    -- Filter out nulls / completely blank salary ranges
    AND `Salary Range` IS NOT NULL;





-- Query 2: Regional Segmentation (California vs. Other US)
SELECT
  state_group,
  COUNT(*) as job_count,
  -- retrieving a few sample salary ranges to make sure they look right
  ARRAY_AGG(salary_range LIMIT 3) as sample_salaries

FROM `ai_job_market.cleaned_jobs`
GROUP BY state_group;