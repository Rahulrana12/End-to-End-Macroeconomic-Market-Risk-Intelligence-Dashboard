-- Cumulative Average Tariff Rates
SELECT date, country, tariff_rate_pct,
AVG(tariff_rate_pct)OVER(PARTITION BY country ORDER BY date) AS running_cumulative_average_tariff_rate
FROM tariff_rates;


-- MArket Volatility & Rolling Risk
WITH daily_return AS (
SELECT date, sp500,
((sp500 - LAG(sp500,1) OVER (ORDER BY date)) / NULLIF(LAG(sp500,1) OVER (ORDER BY date),0)*100):: numeric AS daily_percentage_return
FROM market_reaction
),
clean_return AS (
SELECT date, sp500, daily_return,
ROUND(daily_percentage_return,4) AS daily_return_pct
FROM daily_return
WHERE daily_return IS NOT NULL
)
SELECT date, sp500, daily_return_pct,
ROUND(
STDDEV(daily_return_pct) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)::numeric,4)
AS rolling_7d_volatility
FROM clean_return
ORDER BY date;

-- Trade Event Coorelation Study
WITH tariff_date AS (
SELECT DISTINCT date::date AS event_date , headline, country
FROM tariff_rates
)
SELECT t.event_date, t.headline, t.country, mr.sp500, mr.shanghai_composite, mr.usd_cny
FROM tariff_date t
JOIN market_reaction mr 
ON t.event_date = mr.date::date
ORDER BY t.event_date DESC;

-- 7 Days Abnormal Return Impact Analysis 
WITH market_future AS (
SELECT date::date AS market_date, sp500 AS day_0,
LEAD(sp500,7)OVER(ORDER BY date) AS day_7
FROM market_reaction
),
announcements AS (
SELECT date::date AS event_date, tariff_rate_pct
FROM tariff_rates
)
SELECT a.event_date, a.tariff_rate_pct, mf.day_0, mf.day_7,
ROUND((
(mf.day_7 - mf.day_0) / NULLIF(mf.day_0,0)*100)::numeric,2) AS post_7d_return_pct
FROM announcements a
JOIN market_future mf
ON a.event_date = mf.market_date
ORDER BY a.event_date;

--Sentiment vs Financial Market Impact
WITH sentiments AS (
SELECT date::date AS news_date, 
CASE
WHEN LOWER(sentiment) = 'positive' THEN 1.0
WHEN LOWER(sentiment) = 'neutral' THEN 0.0
WHEN LOWER(sentiment) = 'negative' THEN -1.0
ELSE 0.0
END AS numeric_sentiment
FROM news_headlines
),
daily_sentiment AS (
SELECT news_date, 
COUNT(*) AS total_headlines,
ROUND(
AVG(numeric_sentiment)::numeric,2
) 
AS avg_sentiment
FROM sentiments
GROUP BY news_date
)
SELECT ds.news_date, ds.total_headlines, ds.avg_sentiment, mr.sp500, mr.usd_cny
FROM daily_sentiment ds
JOIN market_reaction mr
On ds.news_date = mr.date::date
ORDER BY news_Date DESC;

--US Trade Deficit Variance Tracking
SELECT date, us_trade_balance_bn,
LAG(us_trade_balance_bn,1)OVER(ORDER BY date) AS previous_month_balance,
us_trade_balance_bn - LAG(us_trade_balance_bn,1)OVER(ORDER BY date) AS mom_change,
us_trade_balance_bn - LAG(us_trade_balance_bn,12)OVER(ORDER BY date) AS yoy_change
FROM trade_balance
ORDER BY date DESC;

--Tariff Escalation Severity Bucketing 
SELECT CASE
WHEN tariff_rate_pct >= 25 THEN 'HIGH'
WHEN tariff_rate_pct BETWEEN 10 AND 24.9 THEN 'MODERATE'
ELSE'LOW'
END AS severity_levels,
COUNT(*) AS total_events,
ROUND(AVG(usd_cny)::numeric,4) AS avg_exchange_rate
FROM tariff_rates t
JOIN market_reaction mr
ON t.date::date = mr.date::date
GROUP BY 1 
ORDER BY avg_exchange_rate DESC;

--Negative Sentiment Shocks vs Stock Indicies
WITH sentiments AS (
SELECT date::date AS news_date,
DATE_TRUNC('month',date::date) AS month,
CASE
WHEN LOWER(sentiment) = 'positive' THEN 1.00
WHEN LOWER(sentiment) = 'neutral' THEN 0.00
WHEN LOWER(sentiment) = 'negative' THEN -1.00
ELSE 0.00
END AS sentiment_score
FROM news_headlines
)
SELECT s.month,
COUNT(CASE WHEN sentiment_score < -0.2 THEN 1 END) AS negative_news_count,
ROUND(AVG(sp500)::numeric,2) AS avg_monthly_sp500
FROM sentiments s
JOIN market_reaction m
ON m.date::date = s.news_date
GROUP BY s.month
ORDER BY s.month DESC;

--Commodity Exposure on Policy Announcement Dates
SELECT t.date, m.crude_oil_wti, m.usd_cny, m.steel_futures, m.aluminum_futures
FROM market_reaction m
INNER JOIN tariff_rates t
ON t.date::date = m.date::date
ORDER BY m.date DESC;

--Executive Summary KPI Block
WITH sentiments AS (
SELECT date::date AS news_date,
CASE 
WHEN LOWER(sentiment) = 'positive' THEN 1.00
WHEN LOWER(sentiment) = 'neutral' THEN 0.00
WHEN LOWER(sentiment) = 'negative' THEN -1.00
ELSE 0.00
END AS sentiment_score
FROM news_headlines
)
SELECT
(SELECT MAX(tariff_rate_pct) FROM tariff_rates) AS max_tariff_rate_pct,
(SELECT MIN(us_trade_balance_bn) FROM trade_balance) AS worst_trade_deficit,
(SELECT MAX(usd_cny) FROM market_reaction) AS peak_exchange_rate,
(SELECT AVG(sentiment_score) FROM sentiments) AS overall_trade_war_sentiment;