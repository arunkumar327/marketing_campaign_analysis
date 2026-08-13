-- 2. Top Performing Ads
--
-- Question:
-- “Which ads are actually getting the best click-through rate?
-- Pull the top 10 ads by CTR, but ignore anything with really low
-- impressions so the numbers aren't misleading.”
--
-- Thinking:
-- The required grain is ad level, so I need to aggregate the
-- performance data for each ad first.
--
-- The main issue with ranking ads by CTR is that an ad with very
-- low impressions can get an unusually high CTR from only a few
-- clicks. So I don't want those ads to dominate the ranking.
--
-- I considered using a fixed minimum impression value, but that
-- would depend too much on the size of the dataset. I decided to
-- use the median impressions as the reference and keep ads that
-- have at least 20% of the median impressions. This gives me a
-- relative way to remove ads with very low exposure.
--
-- After filtering those ads, I can calculate CTR and rank them
-- based on CTR in descending order.
--
-- I am using DENSE_RANK so ads with the same CTR can have the same
-- rank instead of arbitrarily separating them.
--
-- The 10 ads here are therefore the top 10 based on CTR after
-- applying the impression criterion, rather than simply the 10
-- highest CTR values from the entire dataset.

WITH ad_impressions AS (
    SELECT
        a.ad_id,
        a.ad_name,
        SUM(ap.impressions) AS total_impressions

    FROM ads a

    JOIN ad_performance ap
        ON a.ad_id = ap.ad_id

    GROUP BY
        a.ad_id,
        a.ad_name
),

ordered_impressions AS (
    SELECT
        ad_id,
        ad_name,
        total_impressions,

        ROW_NUMBER() OVER (
            ORDER BY total_impressions
        ) AS rn,

        COUNT(*) OVER () AS total_rows

    FROM ad_impressions
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

ad_metrics AS (
    SELECT
        a.ad_id,
        a.ad_name,
        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS ctr

    FROM ads a

    JOIN ad_performance ap
        ON a.ad_id = ap.ad_id

    GROUP BY
        a.ad_id,
        a.ad_name
),

ranked_ads AS (
    SELECT
        am.ad_id,
        am.ad_name,
        am.total_impressions,
        am.total_clicks,
        am.ctr,

        DENSE_RANK() OVER (
            ORDER BY am.ctr DESC
        ) AS ctr_rank

    FROM ad_metrics am

    CROSS JOIN median_impressions mi

    WHERE am.total_impressions >=
          0.20 * mi.median_impressions
)

SELECT
    ad_id,
    ad_name,
    total_impressions,
    total_clicks,
    ctr,
    ctr_rank

FROM ranked_ads

WHERE ctr_rank <= 10

ORDER BY
    ctr DESC,
    total_impressions DESC;
    
-- My Observation:
-- The top 10 ads have CTRs between roughly 4.58% and 4.95%, and all
-- of them have more than 1.1 million impressions. So the high CTRs
-- are not coming from ads with only a few impressions, which gives
-- me more confidence that these are genuinely strong click
-- performers.
--
-- Startup HR Video is currently the highest with a 4.95% CTR,
-- followed by Gym Fitness Ad at 4.89%. The difference between the
-- top ads is not very large, so I wouldn't say that Startup HR Video
-- is dramatically better than the others just because it ranks
-- first.
--
-- I would use these ads as candidates for further investigation and
-- possible scaling, but I would not make a budget decision from CTR
-- alone. I would want to check CPC, conversion rate, revenue and
-- profit to know whether the higher click-through rate is actually
-- producing better business results.
--
-- It would also be useful to compare these ads with their campaign
-- and audience performance to understand whether the creative itself
-- is responsible for the stronger CTR or whether the audience and
-- targeting are contributing to it.
