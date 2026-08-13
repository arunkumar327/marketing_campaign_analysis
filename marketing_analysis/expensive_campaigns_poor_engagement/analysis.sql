-- Question:
-- “Find campaigns where we’re spending a lot but engagement is weak.
-- Maybe anything above $50k spend where CTR is below the average.”
--
-- Thinking:
-- The required grain is campaign level, so I need to calculate the
-- total spend, clicks and impressions for each campaign first.
--
-- The question gives $50k spend as an example threshold, so I will
-- use that as the high-spend condition.
--
-- For weak engagement, I will compare each campaign's CTR with the
-- average CTR across campaigns. I think this is more useful than
-- using a fixed CTR threshold because the campaigns can have
-- different levels of performance.
--
-- I also considered adding a minimum impressions condition because
-- CTR can be misleading when a campaign has very low impressions.
-- But that is not part of the current request, so I am not adding it
-- as a required condition here. It can be suggested if the client
-- wants a more reliable comparison.
--
-- I will calculate CTR from total clicks / total impressions instead
-- of averaging the CTR values from individual performance records.
--
-- This analysis identifies campaigns that have both high spending
-- and relatively weak CTR. It does not tell us whether the spend is
-- actually producing valuable conversions, so conversion or revenue
-- data would be useful for a stronger business-level assessment.

WITH campaign_metrics AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,
        SUM(ap.cost) AS total_spend,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS ctr

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
),

campaign_average AS (
    SELECT
        AVG(ctr) AS average_ctr

    FROM campaign_metrics
)

SELECT
    cm.campaign_id,
    cm.campaign_name,
    cm.total_impressions,
    cm.total_clicks,
    cm.total_spend,
    cm.ctr,
    ca.average_ctr

FROM campaign_metrics cm

CROSS JOIN campaign_average ca

WHERE cm.total_spend > 50000
  AND cm.ctr < ca.average_ctr

ORDER BY
    cm.total_spend DESC,
    cm.ctr ASC;

-- My Observation:
-- All of these campaigns are spending above $50k, but their CTR is
-- below the overall campaign average of about 2.10%. The difference
-- is not the same for every campaign. New Fitness App Launch is very
-- close to the average at 2.09%, while Laptop Back to College is much
-- lower at 1.77%.
--
-- Crypto Trading Platform Ads and Smartphone Launch Ads are the most
-- concerning to me from a spend perspective because both are spending
-- close to $600k while still remaining below the average CTR.
--
-- I would not immediately call these campaigns wasteful because low
-- CTR does not necessarily mean low business performance. A campaign
-- could have a lower CTR but still generate valuable conversions or
-- higher profit.
--
-- I would first check conversion rate, revenue, profit and CAC for
-- these campaigns. If those metrics are also weak, then the high
-- spend with below-average CTR becomes a stronger reason to review
-- the campaign, its creative, audience and targeting.
--
-- I would also pay more attention to campaigns that are both far
-- below the average CTR and spending heavily, rather than treating
-- every campaign below the average in the same way.
