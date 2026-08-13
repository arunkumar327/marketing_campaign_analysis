-- 13. Ads Driving Most Spend
--
-- Question:
-- “Which ads are consuming most of the budget? Give us the top 5
-- by total spend along with their performance.”
--
-- Thinking:
-- The required grain is ad level, so I need to calculate the total
-- spend and the other performance metrics for each ad first.
--
-- The main purpose here is to identify which ads are consuming the
-- most budget, so total spend should be the metric that determines
-- the top 5.
--
-- I don't want CTR, CPC or any other performance metric to influence
-- which ads are selected because that would change the question.
-- Those metrics are only included after selecting the top 5 so we
-- can see how the high-spending ads are performing.
--
-- I will calculate CTR using total clicks / total impressions, CPC
-- using total spend / total clicks, and CPM using total spend /
-- total impressions multiplied by 1000.
--
-- I am calculating these metrics from the underlying performance
-- data instead of using the already stored CTR, CPC and CPM values.
-- This keeps the calculation consistent with the other queries.
--
-- Finally, I will rank the ads by total spend in descending order
-- and return only the top 5.

WITH ad_metrics AS (
    SELECT
        a.ad_id,
        a.ad_name,

        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,
        SUM(ap.cost) AS total_spend,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS ctr,

        SUM(ap.cost) * 1.0 /
            NULLIF(SUM(ap.clicks), 0) AS cpc,

        SUM(ap.cost) * 1000.0 /
            NULLIF(SUM(ap.impressions), 0) AS cpm

    FROM ads a

    JOIN ad_performance ap
        ON a.ad_id = ap.ad_id

    GROUP BY
        a.ad_id,
        a.ad_name
),

ranked_ads AS (
    SELECT
        ad_id,
        ad_name,
        total_impressions,
        total_clicks,
        total_spend,
        ctr,
        cpc,
        cpm,

        ROW_NUMBER() OVER (
            ORDER BY total_spend DESC
        ) AS spend_rank

    FROM ad_metrics
)

SELECT
    ad_id,
    ad_name,
    total_impressions,
    total_clicks,
    total_spend,
    ctr,
    cpc,
    cpm,
    spend_rank

FROM ranked_ads

WHERE spend_rank <= 5

ORDER BY
    total_spend DESC;
    
-- My Observation:
-- The top 5 ads are consuming a very similar amount of spend, with
-- each one using roughly $124k-$127k. So there isn't one single ad
-- dominating the budget by a very large margin.
--
-- But their performance is not the same. Gym Fitness Ad has a CTR of
-- about 4.89% and CPC of about $2.20, while Crypto Investment Promo
-- has a lower CTR of about 4.32% and a higher CPC of about $2.50.
-- This means that similar levels of spending are producing different
-- levels of click efficiency.
--
-- I would not recommend reducing the budget of an ad simply because
-- it appears in the top-spend list. High spend can be intentional if
-- the ad is producing good results. Instead, I would use this result
-- to identify where most of the budget is concentrated and then
-- compare the performance of those ads.
--
-- Gym Fitness Ad looks more efficient than some of the other
-- high-spending ads based on CTR and CPC, so it would be worth
-- investigating what is working in that creative, audience and
-- campaign combination.
--
-- At the same time, I would want conversion, revenue and profit data
-- before making a budget decision. An ad with a slightly higher CPC
-- can still be more valuable if its clicks convert better.
--
-- So the main use of this analysis is to identify high-budget
-- creatives that deserve closer performance review, rather than
-- treating high spend itself as a problem.
