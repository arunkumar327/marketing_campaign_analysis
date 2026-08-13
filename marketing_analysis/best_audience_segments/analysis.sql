-- 7. Best Audience Segments
--
-- Question:
-- “Which audiences are actually engaging with our ads? Rank audiences
-- based on engagement — clicks, likes, shares, comments.”
--
-- Thinking:
-- The required grain is audience level, so I need to aggregate the
-- performance data for each audience first.
--
-- The audience is connected to ad performance through ad_groups and
-- ads, so I need to join those tables before aggregating the data.
--
-- I don't want to rank audiences by raw clicks because an audience
-- with more impressions can naturally get more clicks. I think CTR
-- is a better way to compare the click response of different
-- audiences.
--
-- CTR can still be misleading when an audience has very low
-- impressions. So I decided to use a medium-impression criterion
-- before ranking the audiences. I am using the median impressions
-- as the reference rather than a fixed number because the suitable
-- impression level depends on the size of the data.
--
-- I am using CTR as the main ranking measure and then using shares,
-- comments and likes as additional engagement measures. This lets
-- me consider the other forms of engagement without deciding
-- arbitrary weights for them.
--
-- I considered using a weighted engagement score, which may give a
-- better overall measure of engagement. But the weights for clicks,
-- likes, shares and comments should reflect what the client
-- considers valuable, so I would suggest that to the client rather
-- than deciding the weights myself.
--
-- So the current query gives me a practical first version of
-- audience ranking, while keeping the weighted engagement approach
-- as a possible improvement after client approval.

WITH audience_metrics AS (
    SELECT
        au.audience_id,
        au.audience_name,

        SUM(ap.impressions) AS total_impressions,
        SUM(ap.clicks) AS total_clicks,
        SUM(ap.likes) AS total_likes,
        SUM(ap.shares) AS total_shares,
        SUM(ap.comments) AS total_comments,

        SUM(ap.clicks) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS ctr,

        SUM(ap.shares) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS shares_per_view,

        SUM(ap.comments) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS comments_per_view,

        SUM(ap.likes) * 1.0 /
            NULLIF(SUM(ap.impressions), 0) AS likes_per_view

    FROM ad_performance ap

    JOIN ads
        ON ap.ad_id = ads.ad_id

    JOIN ad_groups ag
        ON ads.ad_group_id = ag.ad_group_id

    JOIN audiences au
        ON ag.audience_id = au.audience_id

    GROUP BY
        au.audience_id,
        au.audience_name
),

ordered_impressions AS (
    SELECT
        audience_id,
        audience_name,
        total_impressions,

        ROW_NUMBER() OVER (
            ORDER BY total_impressions
        ) AS rn,

        COUNT(*) OVER () AS total_rows

    FROM audience_metrics
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

ranked_audiences AS (
    SELECT
        am.audience_id,
        am.audience_name,
        am.total_impressions,
        am.total_clicks,
        am.total_likes,
        am.total_shares,
        am.total_comments,
        am.ctr,
        am.shares_per_view,
        am.comments_per_view,
        am.likes_per_view,

        DENSE_RANK() OVER (
            ORDER BY
                am.ctr DESC,
                am.shares_per_view DESC,
                am.comments_per_view DESC,
                am.likes_per_view DESC
        ) AS audience_rank

    FROM audience_metrics am

    CROSS JOIN median_impressions mi

    WHERE am.total_impressions >=
          0.20 * mi.median_impressions
)

SELECT
    audience_id,
    audience_name,
    total_impressions,
    total_clicks,
    total_likes,
    total_shares,
    total_comments,
    ctr,
    shares_per_view,
    comments_per_view,
    likes_per_view,
    audience_rank

FROM ranked_audiences

ORDER BY
    audience_rank;
    
-- My Observation:
-- Frequent Travelers has the highest CTR at about 2.86%, while
-- Gamers has the lowest at about 1.42%. This suggests that the
-- audiences are responding quite differently to the advertising.
--
-- But I don't want to rank the audiences only by CTR and immediately
-- say that Frequent Travelers is the best audience. CTR tells me how
-- well the audience is responding to the ads, but not how valuable
-- those clicks are to the business.
--
-- Online Deal Hunters has much more exposure than Frequent Travelers,
-- so there is also a difference between engagement quality and
-- available scale. An audience with a higher CTR but much smaller
-- reach may not necessarily be the better audience for increasing
-- overall results.
--
-- I would check conversion rate, revenue, profit and CAC for these
-- audiences before deciding where to increase budget. It would also
-- be useful to compare the performance of the same audience across
-- different campaigns and creatives.
--
-- I considered using a weighted engagement score combining clicks,
-- likes, shares and comments. I think that could give a broader
-- picture of engagement, but the weights should be decided with the
-- client because a share, comment and click don't necessarily have
-- the same business value. I would keep that as a suggested
-- improvement rather than deciding the weights myself.
