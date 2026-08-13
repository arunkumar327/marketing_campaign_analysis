-- 12. Campaign Leaderboard
--
-- Question:
-- “Create a leaderboard of campaigns ranked by total clicks.
-- If two campaigns are close, the one with lower CPC should rank higher.”
--
-- Thinking:
-- The required grain is campaign level, so I need to calculate the
-- total clicks and CPC for each campaign first.
--
-- Total clicks can be summed for each campaign. CPC should be
-- calculated using total spend / total clicks rather than averaging
-- the CPC values from individual performance records.
--
-- The main ranking is based on total clicks, with the campaigns
-- having more clicks ranked higher.
--
-- The question says "if two campaigns are close", but it does not
-- define what "close" means. I don't want to create an arbitrary
-- difference or percentage just to make the condition more specific.
-- So I will use CPC as the secondary ranking criterion for all
-- campaigns. When campaigns have the same total clicks, the one with
-- lower CPC will rank higher.
--
-- I am using DENSE_RANK so campaigns with the same ranking values
-- can receive the same rank instead of being separated unnecessarily.

WITH campaign_board AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        SUM(ap.clicks) AS total_clicks,

        SUM(ap.cost) * 1.0 /
            NULLIF(SUM(ap.clicks), 0) AS total_cpc

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
)

SELECT
    campaign_id,
    campaign_name,
    total_clicks,
    total_cpc,

    DENSE_RANK() OVER (
        ORDER BY
            total_clicks DESC,
            total_cpc ASC
    ) AS campaign_rank

FROM campaign_board

ORDER BY
    total_clicks DESC,
    total_cpc ASC;
    
-- My Observation:
-- The campaigns at the top of the leaderboard are generating the
-- highest number of clicks, but the difference in CPC helps me see
-- which campaigns are getting those clicks more efficiently when
-- their click volumes are similar.
--
-- I would not treat the leaderboard as a direct budget allocation
-- list. A high number of clicks means the campaign is generating
-- traffic, but it does not tell me whether that traffic is converting
-- or producing revenue.
--
-- For campaigns with similar click volumes, I would pay attention to
-- the CPC difference because a lower CPC means the campaign is
-- generating those clicks with less spend. But I would still check
-- conversion rate and revenue before deciding that the lower-CPC
-- campaign is actually more valuable.
--
-- This leaderboard is therefore useful as a first-level way to
-- identify campaigns that are generating scale and to compare their
-- click efficiency. The next step would be to connect this with
-- conversion and financial metrics to understand which campaigns are
-- actually contributing to business results.
