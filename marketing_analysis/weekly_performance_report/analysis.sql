-- 14. Weekly Performance Report
--
-- Question:
-- “We need a weekly breakdown of impressions, clicks, spend and CTR
-- by platform.”
--
-- Thinking:
-- The required grain is platform and week, so I need to aggregate
-- the performance data by platform and week.
--
-- I will calculate total impressions, clicks and spend for each
-- platform for each week.
--
-- CTR should be calculated using total clicks / total impressions
-- for that platform and week rather than averaging the CTR values
-- from individual performance records.
--
-- I am using the platform_id directly available in
-- ad_performance because the question is asking for performance by
-- platform and that relationship is already available in the
-- performance table.
--
-- I will use the week from the performance date so that the result
-- gives a weekly breakdown instead of treating each date separately.
--
-- Finally, I will sort the result by week and then platform so the
-- performance can be read and compared week by week.

SELECT
    p.platform_id,
    p.platform_name,
    YEARWEEK(ap.date, 1) AS year_week,

    SUM(ap.impressions) AS total_impressions,
    SUM(ap.clicks) AS total_clicks,
    SUM(ap.cost) AS total_spend,

    SUM(ap.clicks) * 1.0 /
        NULLIF(SUM(ap.impressions), 0) AS ctr

FROM ad_performance ap

JOIN platforms p
    ON ap.platform_id = p.platform_id

GROUP BY
    p.platform_id,
    p.platform_name,
    YEARWEEK(ap.date, 1)

ORDER BY
    year_week,
    p.platform_name;
    
-- My Observation:
-- The weekly report makes it easier to see whether the platform
-- performance is consistent or whether a platform is being carried
-- by only a few strong weeks.
--
-- Google Ads continues to contribute a large amount of clicks across
-- the weeks, but its CTR and CPC should be looked at together rather
-- than judging the platform only by its click volume.
--
-- Meta Ads generally shows a lower CPC than Google, while some of the
-- other platforms have much higher CPCs. This makes the weekly view
-- useful for checking whether those differences are persistent or
-- only happening during a particular week.
--
-- I would also look for weeks where spend increases without a similar
-- increase in clicks. That would indicate that the platform is
-- becoming less efficient during that period and would be worth
-- investigating.
--
-- I would not recommend changing the budget based only on one week's
-- movement. If the same pattern continues across multiple weeks,
-- then I would look deeper into the campaign, audience and creative
-- level to understand what is causing it.
--
-- The weekly report is therefore useful for monitoring performance
-- over time and identifying periods that need further investigation,
-- while the actual budget decision would need conversion, revenue and
-- profit data as well.
