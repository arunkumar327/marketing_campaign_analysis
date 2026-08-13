-- 11. CTR Stability
--
-- Question:
-- “Can you calculate a rolling CTR average so we can see whether
-- performance is stable over time?”
--
-- Thinking:
-- The required grain is campaign and date, so I need to calculate
-- the CTR for each campaign day by day first.
--
-- I want to see how the current CTR compares with the campaign's
-- recent performance, so I decided to use a rolling CTR average.
--
-- I chose a 7-day rolling window because it gives a recent enough
-- period to see changes in performance without making the comparison
-- too sensitive to just one or two days.
--
-- I will calculate daily CTR using total clicks / total impressions
-- and then calculate the average of the daily CTR values over the
-- current day and the previous 6 days.
--
-- I am using the average of the daily CTR values rather than
-- calculating rolling clicks / rolling impressions because the
-- purpose here is to see the average daily CTR and how the current
-- day's performance is moving around that recent average.
--
-- I am not defining a specific threshold for what should be called
-- "unstable" because the question only asks for a rolling CTR average.
-- The daily CTR and rolling average can show where performance is
-- moving away from its recent level, and a stability threshold can
-- be decided later if needed.
--
-- Since the data is collected continuously, I can use the previous
-- rows as consecutive days without separately checking for missing
-- dates.

WITH daily_campaign_ctr AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        ap.date,

        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS daily_ctr

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
        ap.date
),

rolling_ctr AS (
    SELECT
        campaign_id,
        campaign_name,
        date,
        total_impressions,
        total_clicks,
        daily_ctr,

        AVG(daily_ctr) OVER (
            PARTITION BY campaign_id
            ORDER BY date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS rolling_7_day_ctr

    FROM daily_campaign_ctr
)

SELECT
    campaign_id,
    campaign_name,
    date,
    total_impressions,
    total_clicks,

    daily_ctr,

    rolling_7_day_ctr,

    daily_ctr - rolling_7_day_ctr AS ctr_difference

FROM rolling_ctr

ORDER BY
    campaign_id,
    date;
    
-- My Observation:
-- The rolling CTR helps me see the recent direction of campaign
-- performance instead of looking at each day's CTR separately.
--
-- I would pay attention to campaigns where the daily CTR keeps
-- moving below its recent rolling average. That would suggest that
-- the campaign is losing some of its recent click performance and
-- deserves further investigation.
--
-- I don't want to treat every movement away from the rolling average
-- as a problem. CTR can naturally move from day to day, so the rolling
-- average is more useful as a reference point than as an automatic
-- alert threshold.
--
-- I would also compare the CTR movement with impressions, spend and
-- CPC. If CTR is falling while CPC is increasing, that would be a
-- stronger indication that the campaign's click efficiency is getting
-- worse.
--
-- If the pattern continues, I would then look at the creatives,
-- audiences and campaign changes during that period to understand
-- what may be causing the change. I would not conclude that the
-- creative is fatigued from the rolling CTR alone.
