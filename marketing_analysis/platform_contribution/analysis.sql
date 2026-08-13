-- 10. Platform Contribution
--
-- Question:
-- “What percentage of our total clicks comes from each platform?”
--
-- Thinking:
-- The required grain is platform level, so I need to calculate the
-- total clicks for each platform first.
--
-- Then I need the total clicks across all platforms so I can find
-- what percentage of the overall clicks each platform contributes.
--
-- I will calculate the percentage using platform clicks / total
-- clicks and multiply it by 100.
--
-- Since platform_id is directly available in ad_performance, I can
-- use that relationship instead of going through campaigns, which
-- keeps the query simpler and uses the actual platform associated
-- with the performance record.
--
-- I am not calculating the percentage separately for campaigns,
-- ads or dates because the question is asking for each platform's
-- contribution to the overall clicks.
--
-- The result will be sorted by contribution percentage in
-- descending order so I can immediately see which platforms are
-- contributing the most clicks.

WITH platform_clicks AS (
    SELECT
        p.platform_id,
        p.platform_name,
        SUM(ap.clicks) AS total_clicks

    FROM ad_performance ap

    JOIN platforms p
        ON ap.platform_id = p.platform_id

    GROUP BY
        p.platform_id,
        p.platform_name
),

total_clicks AS (
    SELECT
        SUM(total_clicks) AS all_platform_clicks

    FROM platform_clicks
)

SELECT
    pc.platform_id,
    pc.platform_name,
    pc.total_clicks,

    pc.total_clicks * 100.0 /
        NULLIF(tc.all_platform_clicks, 0) AS click_contribution_percent

FROM platform_clicks pc

CROSS JOIN total_clicks tc

ORDER BY
    click_contribution_percent DESC;
    
-- My Observation:
-- Google Ads contributes the largest share of total clicks at about
-- 50.24%, so it is clearly the main source of traffic in this data.
-- Meta Ads is the next largest contributor at about 21.23%.
--
-- This tells me where the clicks are coming from, but I don't think
-- click contribution alone is enough to decide which platform is
-- performing best. Google having the largest share is partly because
-- it also has a much larger spend.
--
-- I would compare this result with the platform CPC, CTR and spend
-- from Query 3. A platform contributing fewer clicks could still be
-- more efficient, while a platform contributing many clicks could be
-- consuming a disproportionate amount of the budget.
--
-- I would also want to check conversions and revenue before using
-- click contribution for budget allocation. The platform bringing
-- the most clicks is not necessarily the platform creating the most
-- business value.
--
-- So I would use this result mainly to understand the contribution
-- and dependency on each platform. If one platform is responsible for
-- a very large share of clicks, I would also consider whether the
-- business is becoming too dependent on that platform and whether
-- the other platforms have enough scale to diversify the traffic
-- source.
