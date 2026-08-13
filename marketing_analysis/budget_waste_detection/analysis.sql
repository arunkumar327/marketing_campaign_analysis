-- 9. Budget Waste Detection
--
-- Question:
-- “Find ads that are getting a lot of impressions but performing
-- worse than the average CTR for their campaign.”
--
-- Thinking:
-- The required grain is ad level, but I also need the campaign-level
-- CTR so I can compare each ad with the other ads in the same
-- campaign.
--
-- "A lot of impressions" is not given as a fixed number in the
-- question, so I need to define what that means. I decided to use
-- the average impressions of the ads within each campaign as the
-- reference. This makes the condition relative to the campaign
-- instead of using one fixed number for every campaign.
--
-- I will first calculate the total impressions, clicks and CTR for
-- each ad. Then I will calculate the average CTR and average
-- impressions for each campaign.
--
-- An ad will be flagged when it has more impressions than the
-- campaign average but its CTR is below the campaign average. This
-- helps identify ads that are getting a reasonable amount of
-- exposure but are not performing as well as the other ads in the
-- same campaign.
--
-- I am using CTR calculated from total clicks / total impressions
-- rather than averaging the CTR values from individual performance
-- records.
--
-- The "average" here is based on the ads within each campaign, not
-- the overall average across all ads. I think this gives a more
-- meaningful comparison because the ad is being compared with the
-- other creatives competing within its own campaign.

WITH ad_metrics AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        a.ad_id,
        a.ad_name,

        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,

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
        c.campaign_name,
        a.ad_id,
        a.ad_name
),

campaign_metrics AS (
    SELECT
        campaign_id,
        AVG(ctr) AS campaign_average_ctr,
        AVG(total_impressions) AS campaign_average_impressions

    FROM ad_metrics

    GROUP BY
        campaign_id
)

SELECT
    am.campaign_id,
    am.campaign_name,
    am.ad_id,
    am.ad_name,
    am.total_impressions,
    am.total_clicks,
    am.ctr,
    cm.campaign_average_impressions,
    cm.campaign_average_ctr

FROM ad_metrics am

JOIN campaign_metrics cm
    ON am.campaign_id = cm.campaign_id

WHERE am.total_impressions > cm.campaign_average_impressions
  AND am.ctr < cm.campaign_average_ctr

ORDER BY
    am.campaign_id,
    am.total_impressions DESC,
    am.ctr ASC;
    
-- My Observation:
-- The ads identified here are getting more impressions than the
-- average ads in their own campaigns, but their CTR is below the
-- campaign average. So these are not ads that are simply being
-- ignored because they have very little exposure. They are getting
-- enough visibility but are not converting that exposure into clicks
-- as well as the other ads in the same campaign.
--
-- This makes them more interesting to investigate than an ad with
-- both low impressions and low CTR. The campaign-level comparison
-- also makes the result more useful because I am comparing each ad
-- against the other creatives competing in the same campaign.
--
-- I would first look at the creative, headline, CTA and audience
-- targeting of these ads and compare them with the better-performing
-- ads in the same campaign. This could help identify whether the
-- problem is with the creative itself or with the audience being
-- targeted.
--
-- I would not immediately stop these ads based only on this result.
-- The analysis is based on impressions and CTR, so I would also check
-- CPC, conversions and revenue before making a budget or campaign
-- decision.
--
-- If an ad continues to receive high exposure while remaining below
-- the campaign CTR average and also performs poorly on conversions,
-- then reducing its budget or replacing the creative would be a more
-- reasonable action.
