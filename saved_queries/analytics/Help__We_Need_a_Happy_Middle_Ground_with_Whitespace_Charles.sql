SELECT *
FROM static.single_country_and_currency
WHERE LOWER(country_name) LIKE '%united%'
ORDER BY country_name;