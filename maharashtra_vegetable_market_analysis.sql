USE maharashtra_vegetable_market_analysis;
select * from mandi_data_cleaned;
select* from production_data_2026;
-- ============================================================
--  SECTION 1 — PRICE INSIGHTS
-- ============================================================
 
-- 1.1  Average, Min, Max price per commodity (all months)
SELECT
    commodity,
    ROUND(AVG(kg_price), 2)  AS avg_price_per_kg,
    ROUND(MIN(kg_price), 2)  AS min_price_per_kg,
    ROUND(MAX(kg_price), 2)  AS max_price_per_kg,
    ROUND(MAX(kg_price) - MIN(kg_price), 2) AS price_range
FROM mandi_data_cleaned
GROUP BY commodity
ORDER BY avg_price_per_kg DESC;
 
 
-- 1.2  Monthly price trend per commodity
--      (shows how price moves month to month)
SELECT
    DATE_FORMAT(date, '%Y-%m')   AS month,
    commodity,
    ROUND(AVG(kg_price), 2)      AS avg_kg_price
FROM mandi_data_cleaned
GROUP BY month, commodity
ORDER BY commodity, month;
 
 
-- 1.3  Month-over-month price change (% growth)
WITH monthly AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m') AS month,
        commodity,
        ROUND(AVG(kg_price), 2)    AS avg_price
    FROM mandi_data_cleaned
    GROUP BY month, commodity
)
SELECT
    curr.month,
    curr.commodity,
    curr.avg_price                                         AS current_price,
    prev.avg_price                                         AS prev_price,
    ROUND((curr.avg_price - prev.avg_price)
          / prev.avg_price * 100, 2)                       AS pct_change
FROM monthly curr
JOIN monthly prev
  ON curr.commodity = prev.commodity
 AND curr.month     = DATE_FORMAT(
       DATE_ADD(STR_TO_DATE(CONCAT(prev.month,'-01'),'%Y-%m-%d'),
       INTERVAL 1 MONTH), '%Y-%m')
ORDER BY curr.commodity, curr.month;
 
 
-- 1.4  Top 5 highest priced commodities this month (April 2026)
SELECT
    commodity,
    district,
    ROUND(AVG(kg_price), 2) AS avg_kg_price
FROM mandi_data_cleaned
WHERE DATE_FORMAT(date, '%Y-%m') = '2026-04'
GROUP BY commodity, district
ORDER BY avg_kg_price DESC
LIMIT 5;
 
 
-- 1.5  Most price-volatile commodities (high risk)
SELECT
    commodity,
    ROUND(AVG(price_volatility), 2)  AS avg_volatility,
    ROUND(STDDEV(kg_price), 2)       AS price_std_dev,
    ROUND(MIN(kg_price), 2)          AS min_price,
    ROUND(MAX(kg_price), 2)          AS max_price
FROM mandi_data_cleaned
GROUP BY commodity
ORDER BY avg_volatility DESC;
 
 
-- ============================================================
--  SECTION 2 — DISTRICT INSIGHTS
-- ============================================================
 
-- 2.1  Best district per commodity by average price
--      (where to sell for highest return)
SELECT
    commodity,
    district,
    ROUND(AVG(kg_price), 2) AS avg_kg_price
FROM mandi_data_cleaned
GROUP BY commodity, district
ORDER BY commodity, avg_kg_price DESC;
 
 
-- 2.2  Top 10 district-commodity combinations by profit score
SELECT
    district,
    commodity,
    ROUND(AVG(profit_score), 0) AS avg_profit_score,
    ROUND(AVG(kg_price), 2)     AS avg_kg_price,
    ROUND(AVG(arrival_quantity), 0) AS avg_arrivals
FROM mandi_data_cleaned
GROUP BY district, commodity
ORDER BY avg_profit_score DESC
LIMIT 10;
 
 
-- 2.3  Districts with the highest supply gap score
--      (unmet demand — opportunity to grow and sell there)
SELECT
    district,
    ROUND(AVG(supply_gap_score), 4) AS avg_supply_gap,
    ROUND(AVG(kg_price), 2)         AS avg_kg_price,
    ROUND(AVG(arrival_quantity), 0) AS avg_arrivals
FROM mandi_data_cleaned
GROUP BY district
ORDER BY avg_supply_gap DESC
LIMIT 10;
 
 
-- 2.4  District ranking by total arrival quantity
--      (high arrival = high market activity)
SELECT
    district,
    ROUND(SUM(arrival_quantity), 0)  AS total_arrivals,
    ROUND(AVG(kg_price), 2)          AS avg_kg_price,
    COUNT(DISTINCT commodity)        AS commodities_traded
FROM mandi_data_cleaned
GROUP BY district
ORDER BY total_arrivals DESC;
 
 
-- 2.5  Underperforming districts (low price + low arrivals)
SELECT
    district,
    ROUND(AVG(kg_price), 2)         AS avg_kg_price,
    ROUND(AVG(arrival_quantity), 0) AS avg_arrivals,
    ROUND(AVG(supply_gap_score), 4) AS supply_gap
FROM mandi_data_cleaned
GROUP BY district
HAVING avg_kg_price < (SELECT AVG(kg_price) FROM mandi_data)
   AND avg_arrivals < (SELECT AVG(arrival_quantity) FROM mandi_data)
ORDER BY avg_kg_price ASC;
 
 
-- ============================================================
--  SECTION 3 — PRODUCTION INSIGHTS
-- ============================================================
 
-- 3.1  Total production per commodity (all months)
SELECT
    commodity,
    category,
    ROUND(SUM(production_tonnes), 2)  AS total_production_tonnes,
    ROUND(AVG(production_tonnes), 2)  AS avg_monthly_production
FROM production_data_2026
GROUP BY commodity, category
ORDER BY total_production_tonnes DESC;
 
 
-- 3.2  Production by category (which crop type dominates)
SELECT
    category,
    ROUND(SUM(production_tonnes), 2) AS total_tonnes,
    ROUND(AVG(production_tonnes), 2) AS avg_monthly_tonnes,
    COUNT(DISTINCT commodity)        AS num_crops,
    COUNT(DISTINCT district)         AS num_districts
FROM production_data_2026
GROUP BY category
ORDER BY total_tonnes DESC;
 
 
-- 3.3  Monthly production trend (is production increasing?)
SELECT
    month,
    ROUND(SUM(production_tonnes), 2)    AS total_tonnes,
    COUNT(DISTINCT commodity)           AS commodities_grown,
    COUNT(DISTINCT district)            AS districts_active
FROM production_data_2026
GROUP BY month
ORDER BY month;
 
 
-- 3.4  Top 10 producing districts per commodity
SELECT
    commodity,
    district,
    ROUND(SUM(production_tonnes), 2) AS total_tonnes
FROM production_data_2026
GROUP BY commodity, district
ORDER BY commodity, total_tonnes DESC
LIMIT 10;
 
 
-- 3.5  Which district grows the most overall?
SELECT
    district,
    ROUND(SUM(production_tonnes), 2)  AS total_production,
    COUNT(DISTINCT commodity)         AS varieties_grown
FROM production_data_2026
GROUP BY district
ORDER BY total_production DESC
LIMIT 10;
 
 
-- ============================================================
--  SECTION 4 — COMBINED INSIGHTS (mandi + production JOIN)
-- ============================================================
 
-- 4.1  Price vs Production comparison per commodity
--      High production + high price = ideal crop to grow
SELECT
    p.commodity,
    ROUND(SUM(p.production_tonnes), 0)   AS total_production_tonnes,
    ROUND(AVG(m.kg_price), 2)            AS avg_mandi_price,
    ROUND(AVG(m.profit_score), 0)        AS avg_profit_score,
    ROUND(AVG(m.supply_gap_score), 4)    AS avg_supply_gap
FROM production_data_2026 p
JOIN mandi_data_cleaned m ON p.commodity = m.commodity
               AND p.district   = m.district
GROUP BY p.commodity
ORDER BY avg_mandi_price DESC, total_production_tonnes DESC;
 
 
-- 4.2  Best crop recommendation per district
--      (highest profit score + manageable supply gap)
SELECT
    m.district,
    m.commodity,
    ROUND(AVG(m.kg_price), 2)         AS avg_price,
    ROUND(AVG(m.profit_score), 0)     AS avg_profit,
    ROUND(SUM(p.production_tonnes), 0) AS production_tonnes,
    ROUND(AVG(m.supply_gap_score), 4) AS supply_gap
FROM mandi_data_cleaned m
JOIN production_data_2026 p ON m.commodity = p.commodity
                       AND m.district  = p.district
GROUP BY m.district, m.commodity
ORDER BY m.district, avg_profit DESC;
 
 
-- 4.3  Low production + high price = GROW MORE of these crops!
--      Golden opportunity crops
SELECT
    p.commodity,
    ROUND(SUM(p.production_tonnes), 0) AS total_production,
    ROUND(AVG(m.kg_price), 2)          AS avg_price,
    ROUND(AVG(m.supply_gap_score), 4)  AS supply_gap,
    ROUND(AVG(m.profit_score), 0)      AS profit_score
FROM production_data_2026 p
JOIN mandi_data_cleaned m ON p.commodity = m.commodity
               AND p.district   = m.district
GROUP BY p.commodity
HAVING total_production < (
    SELECT AVG(sub.tot)
    FROM (SELECT SUM(production_tonnes) AS tot
          FROM production_data GROUP BY commodity) sub
)
AND avg_price > (SELECT AVG(kg_price) FROM mandi_data)
ORDER BY avg_price DESC;
 
 
-- 4.4  District-level supply gap vs price
--      High supply gap + high price = urgent opportunity
SELECT
    m.district,
    ROUND(AVG(m.supply_gap_score), 4)  AS avg_supply_gap,
    ROUND(AVG(m.kg_price), 2)          AS avg_price,
    ROUND(SUM(p.production_tonnes), 0) AS total_production,
    ROUND(AVG(m.profit_score), 0)      AS avg_profit
FROM mandi_data_cleaned m
JOIN production_data_2026 p ON m.district  = p.district
                       AND m.commodity = p.commodity
GROUP BY m.district
ORDER BY avg_supply_gap DESC, avg_price DESC
LIMIT 10;
 
 
-- 4.5  Season-wise price hike detection
--      Which month fetches best prices per crop?
SELECT
    DATE_FORMAT(date, '%Y-%m')   AS month,
    commodity,
    ROUND(AVG(kg_price), 2)      AS avg_price,
    RANK() OVER (
        PARTITION BY commodity
        ORDER BY AVG(kg_price) DESC
    )                            AS price_rank
FROM mandi_data_cleaned
GROUP BY month, commodity
ORDER BY commodity, price_rank;
 
 
-- ============================================================
--  SECTION 5 — FARMER DECISION QUERIES
-- ============================================================
 
-- 5.1  Which crop should I grow? (ranked by profit potential)
SELECT
    p.commodity,
    p.category,
    ROUND(AVG(m.kg_price), 2)           AS avg_selling_price,
    ROUND(AVG(m.profit_score), 0)       AS avg_profit_score,
    ROUND(AVG(m.price_volatility), 2)   AS price_risk,
    ROUND(AVG(m.supply_gap_score), 4)   AS market_demand_gap,
    ROUND(SUM(p.production_tonnes), 0)  AS state_production,
    CASE
        WHEN AVG(m.kg_price) > 40
         AND AVG(m.supply_gap_score) > 0.3 THEN 'HIGHLY RECOMMENDED'
        WHEN AVG(m.kg_price) > 20
         AND AVG(m.supply_gap_score) > 0.2 THEN 'RECOMMENDED'
        WHEN AVG(m.kg_price) > 10         THEN 'MODERATE'
        ELSE 'LOW PRIORITY'
    END AS recommendation
FROM production_data_2026 p
JOIN mandi_data_cleaned m ON p.commodity = m.commodity
               AND p.district   = m.district
GROUP BY p.commodity, p.category
ORDER BY avg_profit_score DESC;
 
 
-- 5.2  Best market (mandi) to sell a specific crop
--      Replace 'Tomato' with any crop name
SELECT
    district,
    market,
    ROUND(AVG(kg_price), 2)         AS avg_kg_price,
    ROUND(MAX(kg_price), 2)         AS peak_price,
    ROUND(AVG(arrival_quantity), 0) AS avg_daily_arrivals,
    ROUND(AVG(profit_score), 0)     AS avg_profit_score
FROM mandi_data_cleaned
WHERE commodity = 'Tomato'
GROUP BY district, market
ORDER BY avg_kg_price DESC
LIMIT 10;
 
 
-- 5.3  Price calendar — best month to sell each crop
SELECT
    commodity,
    DATE_FORMAT(date, '%B') AS best_month,
    ROUND(AVG(kg_price), 2) AS avg_price
FROM mandi_data_cleaned
GROUP BY commodity, best_month
ORDER BY commodity, avg_price DESC;
 
 
-- 5.4  Arrival vs Price correlation
--      Low arrival + high price = sell when supply is short
SELECT
    commodity,
    DATE_FORMAT(date, '%Y-%m')      AS month,
    ROUND(AVG(arrival_quantity), 0) AS avg_arrivals,
    ROUND(AVG(kg_price), 2)         AS avg_price,
    CASE
        WHEN AVG(arrival_quantity) < 200
         AND AVG(kg_price) > 30 THEN 'SELL NOW — Low supply, High price'
        WHEN AVG(arrival_quantity) > 400
         AND AVG(kg_price) < 15 THEN 'WAIT — Oversupply, Low price'
        ELSE 'NORMAL MARKET'
    END AS market_signal
FROM mandi_data_cleaned
GROUP BY commodity, month
ORDER BY commodity, month;
 
 
-- 5.5  District profit leaderboard — where to sell for max profit
SELECT
    district,
    commodity,
    ROUND(AVG(kg_price), 2)     AS avg_price,
    ROUND(MAX(kg_price), 2)     AS peak_price,
    ROUND(AVG(profit_score), 0) AS profit_score,
    DENSE_RANK() OVER (
        PARTITION BY commodity
        ORDER BY AVG(profit_score) DESC
    ) AS district_rank
FROM mandi_data_cleaned
GROUP BY district, commodity
ORDER BY commodity, district_rank
LIMIT 50;