-- 8. Cost Efficiency Within Campaigns
--
-- Question:
-- “For each campaign, rank the ads based on CPC. We want to know
-- which creatives are the most cost-efficient.”
--
-- Thinking:
-- The required grain is ad within campaign, so I need to calculate
-- the performance of each ad while keeping its campaign information.
--
-- The main metric here is CPC because the question is asking which
-- creatives are the most cost-efficient. I will calculate CPC using
-- total spend / total clicks instead of averaging the CPC values from
-- individual performance records.
--
-- I also considered that very low-impression ads can produce unstable
-- CPC values. So I decided to use an impression criterion to avoid
-- giving too much importance to ads with very little data.
--
-- I am using the median impressions as the reference and keeping ads
-- that have at least 20% of the median impressions. I prefer this
-- over a fixed impression number because the suitable level can
-- depend on the size of the dataset.
--
-- I will rank the ads separately within each campaign, with the
-- lowest CPC getting the highest rank.
--
-- CPC tells me how efficiently the ad generates clicks, but it does
-- not necessarily tell me which ad is producing the best business
-- result. Conversion or revenue data would give a stronger measure
-- of actual efficiency, but CPC is the metric requested here.

WITH ad_metrics AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        a.ad_id,
        a.ad_name,

        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,
        SUM(ap.cost) AS total_spend,

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
        c.campaign_name,
        a.ad_id,
        a.ad_name
),

ordered_impressions AS (
    SELECT
        ad_id,
        total_impressions,

        ROW_NUMBER() OVER (
            ORDER BY total_impressions
        ) AS rn,

        COUNT(*) OVER () AS total_rows

    FROM ad_metrics
),

median_impressions AS (
    SELECT
        AVG(total_impressions) AS median_impressions

    FROM ordered_impressions

    WHERE rn IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
),

ranked_ads AS (
    SELECT
        am.campaign_id,
        am.campaign_name,
        am.ad_id,
        am.ad_name,
        am.total_impressions,
        am.total_clicks,
        am.total_spend,
        am.cpc,

        DENSE_RANK() OVER (
            PARTITION BY am.campaign_id
            ORDER BY am.cpc ASC
        ) AS cpc_rank

    FROM ad_metrics am

    CROSS JOIN median_impressions mi

    WHERE am.total_impressions >=
          0.20 * mi.median_impressions
)

SELECT
    campaign_id,
    campaign_name,
    ad_id,
    ad_name,
    total_impressions,
    total_clicks,
    total_spend,
    cpc,
    cpc_rank

FROM ranked_ads

ORDER BY
    campaign_id,
    cpc_rank;
    
-- My Observation:
-- The CPC differences within campaigns are quite large. For example,
-- in the Travel Booking Promotion campaign, Budget Travel Video has
-- a CPC of about $0.93 while Business Travel Deals is about $6.97.
-- So the same campaign can have creatives with very different levels
-- of click efficiency.
--
-- I also notice that the cheapest CPC ads are not necessarily the
-- ads with the highest number of clicks. This is important because
-- cost efficiency and scale are two different things. An ad can be
-- very cheap per click but generate relatively few clicks.
--
-- I would use these results to identify creatives worth investigating
-- and possibly testing further, but I would not automatically move
-- budget from high-CPC ads to low-CPC ads. I would first check their
-- conversion rate, revenue and profit because a more expensive click
-- can still be more valuable if it produces better customers.
--
-- I would also compare the low-CPC ads with their CTR and impression
-- volume. This helps make sure the CPC advantage is not coming from
-- a small amount of activity or a different level of exposure.
--
-- A useful next step would be to identify ads that combine good CPC
-- with good CTR and sufficient scale. Those would be stronger
-- candidates for further testing or budget allocation than simply
-- selecting the lowest CPC ads.
