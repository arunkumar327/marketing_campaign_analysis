-- 1. Campaign Performance Snapshot
--
-- Question:
-- “We need a quick overview of how each campaign is performing.
-- Can you pull impressions, clicks, spend, CTR and CPC for every campaign?
-- Sort it so we see the highest spending campaigns first.”
--
-- Thinking:
-- The required grain is campaign level, so I need to aggregate the
-- performance data for each campaign first.
--
-- Impressions, clicks and cost can be summed at campaign level.
-- CTR should be calculated using total clicks / total impressions,
-- and CPC should be calculated using total cost / total clicks.
--
-- I should calculate CTR and CPC after aggregation instead of
-- averaging the values from individual performance records. This
-- gives the campaign-level metrics based on the actual total
-- performance.
--
-- The final result should be sorted by total spend in descending
-- order because the request is to see the highest spending campaigns
-- first.

SELECT
    c.campaign_id,
    c.campaign_name,
    SUM(ap.impressions) AS total_impressions,
    SUM(ap.clicks) AS total_clicks,
    SUM(ap.cost) AS total_spend,

    SUM(ap.clicks) * 1.0 /
        NULLIF(SUM(ap.impressions), 0) AS ctr,

    SUM(ap.cost) * 1.0 /
        NULLIF(SUM(ap.clicks), 0) AS cpc

FROM campaigns c

JOIN ad_groups ag
    ON c.campaign_id = ag.campaign_id

JOIN ads a
    ON ag.ad_group_id = a.ad_group_id

JOIN ad_performance ap
    ON a.ad_id = ap.ad_id

GROUP BY
    c.campaign_id,
    c.campaign_name

ORDER BY
    total_spend DESC;
    
-- My Observation:
-- The campaigns with the highest spend are not necessarily the
-- campaigns with the highest clicks. For example, Google Ads
-- contributes a large share of the total clicks, but the campaign
-- level results show that some campaigns are spending heavily
-- without being among the strongest click generators.
--
-- I would not recommend increasing or reducing a campaign's budget
-- based only on this snapshot. Spend and clicks tell us how much
-- traffic we are buying and at what level, but they don't tell us
-- whether that traffic is actually producing conversions, revenue
-- or profit.
--
-- I would use this result as a first-level performance check and
-- then drill down into CTR, CPC, conversions and financial outcomes
-- for the campaigns that need attention. If a high-spending campaign
-- is also showing weak CTR or high CPC, it would be worth investigating
-- its audience, creative and targeting before continuing to allocate
-- a large budget to it.
