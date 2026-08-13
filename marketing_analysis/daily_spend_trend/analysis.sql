-- 5. Daily Spend Trend
--
-- Question:
-- “Can we see how spend and clicks are trending day by day?
-- Marketing wants to check if budget pacing looks normal.”
--
-- Thinking:
-- The required grain is daily, so I need to aggregate the
-- performance data by date first.
--
-- I only need total spend and total clicks here because those are
-- the two measures requested. I don't want to add extra metrics
-- just for the sake of making the query more detailed.
--
-- The purpose is to see how spend and clicks are moving day by day
-- so that marketing can check whether the budget pacing looks normal.
--
-- I am not defining a specific "normal" spend range in the query
-- because the question does not give a threshold for what should be
-- considered abnormal. This query gives the daily trend, which can
-- then be used for that assessment.
--
-- I will sort the result by date so the trend can be read
-- chronologically.

SELECT
    ap.date,
    SUM(ap.cost) AS total_spend,
    SUM(ap.clicks) AS total_clicks

FROM ad_performance ap

GROUP BY
    ap.date

ORDER BY
    ap.date;
    
-- My Observation:
-- The daily trend shows that spend and clicks are generally moving
-- together, which is what I would expect when more budget is being
-- spent to generate more traffic.
--
-- I would still look for days where spend increases much more than
-- clicks. Those days could indicate that the additional budget is not
-- producing clicks at the same efficiency as the normal days.
--
-- I don't see this query alone as enough to say whether the budget
-- pacing is actually good or bad. A daily spend trend needs to be
-- compared with the planned budget, campaign duration and expected
-- pacing.
--
-- I would also compare daily CPC along with spend and clicks. If
-- spend is increasing while clicks are not increasing at the same
-- rate, the CPC is getting worse and that would be more useful for
-- identifying a potential budget efficiency problem.
--
-- If the business wants automated pacing alerts later, I would define
-- a normal spending range and flag days that move significantly
-- outside that range instead of relying only on visual inspection of
-- the trend.
