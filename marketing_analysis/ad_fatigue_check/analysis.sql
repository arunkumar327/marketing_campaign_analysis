-- 6. Ad Fatigue Check
--
-- Question:
-- “We suspect some creatives are burning out. Can you identify ads
-- where CTR has been dropping consistently for several days?”
--
-- Thinking:
-- The required grain is ad and date, so I need to calculate the
-- daily CTR for each ad first.
--
-- The main thing I am looking for is a consistent decline rather
-- than a single bad day. An ad can have a lower CTR on one day for
-- many reasons, so one decrease alone is not enough to call it
-- fatigue.
--
-- I decided to use 4 consecutive declining days as the condition
-- for identifying possible ad fatigue. This gives me a stronger
-- signal than flagging an ad because of just one or two decreases.
--
-- I will use LAG() to compare each day's CTR with the previous
-- day's CTR. Since the data is collected continuously, I can treat
-- the previous rows as consecutive days without separately checking
-- for missing dates.
--
-- I am only identifying a consistent CTR decline here. A declining
-- CTR does not by itself prove that the creative is actually
-- burning out. Other factors such as impressions, audience changes,
-- spend or conversions could be checked later to understand why
-- the CTR is dropping.

WITH daily_ad_ctr AS (
    SELECT
        a.ad_id,
        a.ad_name,
        ap.date,

        SUM(ap.impressions) AS impressions,
        SUM(ap.clicks) AS clicks,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS ctr

    FROM ads a

    JOIN ad_performance ap
        ON a.ad_id = ap.ad_id

    GROUP BY
        a.ad_id,
        a.ad_name,
        ap.date
),

ctr_with_previous AS (
    SELECT
        ad_id,
        ad_name,
        date,
        impressions,
        clicks,
        ctr,

        LAG(ctr) OVER (
            PARTITION BY ad_id
            ORDER BY date
        ) AS previous_ctr

    FROM daily_ad_ctr
),

declining_days AS (
    SELECT
        ad_id,
        ad_name,
        date,
        ctr,
        previous_ctr,

        CASE
            WHEN ctr < previous_ctr THEN 1
            ELSE 0
        END AS is_declining

    FROM ctr_with_previous
),

fatigue_ads AS (
    SELECT
        ad_id,
        ad_name,

        COUNT(*) AS declining_days

    FROM declining_days

    WHERE is_declining = 1

    GROUP BY
        ad_id,
        ad_name

    HAVING COUNT(*) >= 4
)

SELECT
    ad_id,
    ad_name,
    declining_days

FROM fatigue_ads

ORDER BY
    declining_days DESC;
    
-- My Observation:
-- The ads identified here have a high number of declining CTR days,
-- which makes them worth investigating for possible creative fatigue.
-- But I don't want to conclude that the creative is definitely
-- burning out only from this result.
--
-- A consistent CTR decline is a useful warning signal because it can
-- mean that the audience is becoming less responsive to the same
-- creative. But there can also be other reasons, such as changes in
-- audience, competition, budget or campaign conditions.
--
-- I would first compare these ads with their impressions, spend,
-- CPC and conversion performance to see whether the CTR decline is
-- also affecting the actual business outcome.
--
-- I would especially look at whether the decline continues after
-- four days and whether the ad is performing worse than other
-- creatives targeting the same audience. If that is the case, I
-- would suggest testing a new creative rather than immediately
-- stopping the existing one.
--
-- I would also keep the result as a warning rather than a final
-- decision. The purpose of this analysis is to identify ads that
-- deserve attention and further investigation.
