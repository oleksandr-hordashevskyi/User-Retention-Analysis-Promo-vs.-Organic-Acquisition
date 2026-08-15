WITH cleaned_users AS (
SELECT 
 user_id,
 promo_signup_flag,
CASE 
WHEN signup_datetime IS NOT NULL THEN 
CASE 
WHEN LENGTH(SPLIT_PART(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), '-', 3)) = 4 
THEN TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')
ELSE TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')
END
ELSE NULL 
END AS signup_date
FROM project.cohort_users_raw
),
cleaned_events AS (
SELECT 
 user_id,
 event_type,
CASE 
WHEN event_datetime IS NOT NULL THEN 
CASE 
WHEN LENGTH(SPLIT_PART(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), '-', 3)) = 4 
THEN TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')
ELSE TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')
END
ELSE NULL 
END AS event_date
FROM project.cohort_events_raw
)
SELECT 
 u.promo_signup_flag,
 DATE_TRUNC('month', u.signup_date)::DATE AS cohort_month,
 ((EXTRACT(YEAR FROM e.event_date) - EXTRACT(YEAR FROM u.signup_date)) * 12 +
 (EXTRACT(MONTH FROM e.event_date) - EXTRACT(MONTH FROM u.signup_date)))::INT AS month_offset,
 COUNT(DISTINCT u.user_id) AS users_total
FROM (
SELECT 
 user_id,
 promo_signup_flag,
CASE 
WHEN signup_datetime IS NOT NULL THEN 
CASE 
WHEN LENGTH(SPLIT_PART(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), '-', 3)) = 4 
THEN TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')
ELSE TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')
END
ELSE NULL 
END AS signup_date
FROM project.cohort_users_raw
) u
JOIN (
SELECT 
 user_id,
 event_type,
CASE 
WHEN event_datetime IS NOT NULL THEN 
CASE 
WHEN LENGTH(SPLIT_PART(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), '-', 3)) = 4 
THEN TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')
ELSE TO_DATE(REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')
END
ELSE NULL 
END AS event_date
FROM project.cohort_events_raw
) e ON u.user_id = e.user_id
WHERE 
 u.signup_date IS NOT NULL          
 AND e.event_date IS NOT NULL       
 AND e.event_type IS NOT NULL       
 AND e.event_type != 'test_event'
 AND DATE_TRUNC('month', e.event_date)::DATE BETWEEN '2025-01-01' AND '2025-06-01'
GROUP BY 
 u.promo_signup_flag,
 DATE_TRUNC('month', u.signup_date)::DATE,
 ((EXTRACT(YEAR FROM e.event_date) - EXTRACT(YEAR FROM u.signup_date)) * 12 +
 (EXTRACT(MONTH FROM e.event_date) - EXTRACT(MONTH FROM u.signup_date)))::INT
ORDER BY 
 u.promo_signup_flag ASC,
 cohort_month ASC,
 month_offset ASC;
