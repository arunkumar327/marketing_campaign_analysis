-- 3. Platform Comparison
--
-- Question:
-- “Can you show how each advertising platform is performing overall?
-- We want to compare spend, clicks, CTR, CPC and CPM across platforms.”
--
-- Thinking:
-- The required grain is platform level, so I need to aggregate the
-- performance data for each platform first.
--
-- Spend, clicks and impressions can be summed at platform level.
-- CTR should be calculated using total clicks / total impressions,
-- CPC using total spend / total clicks, and CPM using total spend /
-- total impressions multiplied by 1000.
--
-- I considered calculating these metrics from the CTR, CPC and CPM
-- columns already stored in ad_performance, but I think it is better
-- to calculate them from the underlying impressions, clicks and cost.
-- That way the platform-level metrics are based on the actual totals
-- instead of averaging already calculated values.
--
-- Since platform_id is directly available in ad_performance, I can
-- use that relationship to compare the platforms without going
-- through campaigns.
--
-- The result should show the overall performance of each platform,
-- so I will keep the analysis at platform level rather than breaking
-- it down by campaign or ad.

WITH platform_performance AS (
    SELECT
        p.platform_id,
        p.platform_name,
        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,
        SUM(ap.cost) AS total_spend

    FROM ad_performance ap

    JOIN ads a
        ON ap.ad_id = a.ad_id

    LEFT JOIN platforms p
        ON ap.platform_id = p.platform_id

    GROUP BY
        p.platform_id,
        p.platform_name
)

SELECT
    platform_id,
    platform_name,
    total_impressions,
    total_clicks,
    total_spend,

    total_clicks * 1.0 /
        NULLIF(total_impressions, 0) AS ctr,

    total_spend * 1.0 /
        NULLIF(total_clicks, 0) AS cpc,

    total_spend * 1000.0 /
        NULLIF(total_impressions, 0) AS cpm

FROM platform_performance

ORDER BY
    total_spend DESC;
    
-- My Observation:
-- Google Ads is contributing the largest share of clicks at about
-- 50.24%, but it is also consuming the largest amount of spend.
-- Meta Ads is more cost-efficient for clicks, with a CPC of about
-- $1.49 compared with Google's $2.19, while still contributing
-- 21.23% of total clicks.
--
-- TikTok has a much higher CPC of about $6.49, so it is expensive
-- when the outcome we are measuring is clicks. X Ads is the opposite:
-- its CPC is very low, but its CTR is also very low. So low CPC alone
-- does not mean the platform is performing better.
--
-- This makes me think that I should not recommend shifting budget
-- simply toward the platform with the lowest CPC. Each platform is
-- showing a different trade-off between scale, engagement and cost.
--
-- The current metrics are useful for understanding traffic-level
-- performance, but they are still not enough to decide which platform
-- is most valuable to the business. I would want conversion rate,
-- revenue, profit, ROAS and CAC before making a major budget
-- allocation decision.
--
-- If customer data is available, I would also want to go further and
-- compare the quality and long-term value of customers coming from
-- each platform. A platform bringing fewer clicks at a higher CPC
-- could still be better if those customers generate much higher
-- revenue or lifetime value.
