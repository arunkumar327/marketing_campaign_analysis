-- 15. Abnormal Spend Days
--
-- Question:
-- “Can you flag days where a campaign spent way more than usual?
-- Maybe something like double the normal daily spend.”
--
-- Thinking:
-- The required grain is campaign and date, so I first need to
-- calculate the total spend for each campaign for each day.
--
-- The question suggests using the normal or average daily spend as
-- the baseline. I considered using the average, but an unusually
-- high spending day can itself increase the average and make the
-- abnormal day look less abnormal. So I decided to use the median
-- daily spend as the normal baseline.
--
-- After finding the median daily spend for each campaign, I will
-- compare every day's spend with that campaign's median.
--
-- I will flag a day when the campaign spent more than twice its
-- median daily spend. I am using twice the baseline because the
-- question gives "double the normal daily spend" as the example
-- threshold.
--
-- I also calculate a spike ratio so I can see how many times higher
-- the day's spend was compared with the campaign's normal level.
--
-- I am not calling every unusual day an abnormal day based only on
-- a statistical deviation. The 2x threshold is a simple business
-- rule based on the request, while the median is my choice for a
-- more stable baseline.

WITH cmp_spnd_day AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        ap.date,
        SUM(ap.cost) AS spent

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

ordered_spend AS (
    SELECT
        campaign_id,
        campaign_name,
        spent,

        ROW_NUMBER() OVER (
            PARTITION BY campaign_id
            ORDER BY spent
        ) AS rn,

        COUNT(*) OVER (
            PARTITION BY campaign_id
        ) AS total_rows

    FROM cmp_spnd_day
),

campaign_baseline AS (
    SELECT
        campaign_id,
        campaign_name,

        AVG(spent) AS median_spend

    FROM ordered_spend

    WHERE rn IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )

    GROUP BY
        campaign_id,
        campaign_name
)

SELECT
    d.campaign_id,
    d.campaign_name,
    d.date,
    d.spent,
    b.median_spend,

    d.spent /
        NULLIF(b.median_spend, 0) AS spike_ratio

FROM cmp_spnd_day d

JOIN campaign_baseline b
    ON d.campaign_id = b.campaign_id

WHERE d.spent > 2 * b.median_spend

ORDER BY
    spike_ratio DESC;
    
-- My Observation:
-- The query did not identify any campaign-day where the spend was
-- more than twice the campaign's median daily spend. So based on the
-- rule I defined, there is no clear abnormal spending day in this
-- dataset.
--
-- I don't want to interpret this as saying that the spending pattern
-- is definitely normal. It only tells me that no day crossed the
-- 2x-median threshold. A smaller but still meaningful spending
-- increase would not be captured by this rule.
--
-- I think this is still useful because it gives us a simple warning
-- mechanism for unusually large spending changes. If the business
-- wants tighter monitoring, I could reduce the threshold or use a
-- more statistical approach after understanding what level of
-- variation is normally acceptable.
--
-- I would also compare these spending spikes with clicks, CPC and
-- campaign activity. If a day had unusually high spend but did not
-- generate a similar increase in clicks, that would be more
-- concerning than a high-spend day that produced proportionally more
-- traffic.
--
-- Since there are no flagged days here, I would not recommend any
-- corrective action from this analysis. I would keep the query as a
-- monitoring check and investigate any future campaign-day that
-- crosses the defined threshold.
