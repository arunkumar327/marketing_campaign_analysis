# Marketing Campaign Analysis

## Project Overview

This project analyzes a fictional marketing campaign database using SQL to answer practical marketing performance questions across campaigns, ads, audiences and advertising platforms.

The project is built around a simple idea: a marketing report should not stop at producing metrics. The analysis should first answer the requested business question, make the assumptions behind the analysis clear, and then identify what the result can and cannot tell us before making a recommendation.

The project contains 15 analysis questions covering campaign performance, ad performance, audience engagement, platform performance, cost efficiency, performance trends and anomaly detection.

## Business Problem

Marketing teams generate large amounts of campaign and ad-performance data, but individual metrics can easily give an incomplete picture.

For example:

- High clicks do not necessarily mean high business value.
- Low CPC does not necessarily mean a platform or ad is better.
- High CTR can be misleading when an ad has very little exposure.
- High spend is not automatically wasteful if the resulting customers are valuable.
- A declining CTR can be a warning signal without necessarily proving creative fatigue.

The analysis therefore focuses on using the requested marketing metrics while also identifying where additional business data would be needed for a stronger decision.

## Objectives

The analysis aims to:

- Understand campaign-level performance and spending.
- Identify high-CTR ads without allowing very low exposure to dominate the ranking.
- Compare advertising platforms on spend, clicks, CTR, CPC and CPM.
- Identify high-spending campaigns with below-average CTR.
- Monitor daily and weekly performance trends.
- Detect possible ad fatigue through consistent CTR declines.
- Compare audience engagement while accounting for exposure.
- Rank ads within campaigns by CPC.
- Identify ads receiving high exposure but performing below their campaign average.
- Understand each platform's contribution to total clicks.
- Monitor CTR against a rolling recent-performance baseline.
- Build campaign and ad-spend leaderboards.
- Detect unusually high campaign spending days.

## Database Structure

The database follows a relational structure connecting platforms, campaigns, ad groups, audiences, ads and performance data.

- [Database Schema](marketing_database/schema.sql)
- [ER Diagram](marketing_database/ER_diagram_marketing_database.png)

The main performance table is `ad_performance`. Campaign-level analysis reaches this table through the relationship:

`campaigns → ad_groups → ads → ad_performance`

Audience analysis follows:

`audiences → ad_groups → ads → ad_performance`

Platform-level performance can use `platform_id` directly from `ad_performance`.


Each query folder contains the complete analysis for one business question:

- the question
- the thinking behind the approach
- the SQL query
- the observation from the result
- the exported result grid

## Marketing Analysis

| # | Analysis | Files |
|---|---|---|
| 01 | Campaign Performance Snapshot | [Analysis](marketing_campaign_analysis/campaign_performance/) |
| 02 | Top Performing Ads | [Analysis](marketing_campaign_analysis/top_performing_ads/) |
| 03 | Platform Comparison | [Analysis](marketing_campaign_analysis/platform_comparison/) |
| 04 | Expensive Campaigns With Poor Engagement | [Analysis](marketing_campaign_analysis/expensive_campaigns_poor_engagement/) |
| 05 | Daily Spend Trend | [Analysis](marketing_campaign_analysis/daily_spend_trend/) |
| 06 | Ad Fatigue Check | [Analysis](marketing_campaign_analysis/ad_fatigue_check/) |
| 07 | Best Audience Segments | [Analysis](marketing_campaign_analysis/best_audience_segments/) |
| 08 | Cost Efficiency Within Campaigns | [Analysis](marketing_campaign_analysis/cost_efficiency_within_campaigns/) |
| 09 | Budget Waste Detection | [Analysis](marketing_campaign_analysis/budget_waste_detection/) |
| 10 | Platform Contribution | [Analysis](marketing_campaign_analysis/platform_contribution/) |
| 11 | CTR Stability | [Analysis](marketing_campaign_analysis/ctr_stability/) |
| 12 | Campaign Leaderboard | [Analysis](marketing_campaign_analysis/campaign_leaderboard/) |
| 13 | Ads Driving Most Spend | [Analysis](marketing_campaign_analysis/ads_driving_most_spend/) |
| 14 | Weekly Performance Report | [Analysis](marketing_campaign_analysis/weekly_performance_report/) |
| 15 | Abnormal Spend Days | [Analysis](marketing_campaign_analysis/abnormal_spend_days/) |

## Key Business Insights

### 1. Google Ads is the main source of click volume, but scale comes with higher cost

Google Ads contributes **50.24% of total clicks** and has the largest spend at about **$4.63M**. However, its CPC is about **$2.19**, considerably higher than Meta Ads at about **$1.49** and LinkedIn Ads at about **$1.46**.

This means Google is currently the strongest platform for scale, but not the most cost-efficient source of clicks. I would not recommend moving budget based only on CPC because the actual business value of the traffic is not included in this analysis.

[Relevant analysis: Platform Comparison](marketing_campaign_analysis/platform_comparison/) · [Platform Contribution](marketing_campaign_analysis/platform_contribution/)

### 2. TikTok is expensive for clicks, while X Ads is cheap but has weak click response

TikTok has a CPC of about **$6.49**, the highest among the platforms, while X Ads has the lowest CPC at about **$0.84**. However, X Ads also has the lowest CTR at about **0.55%**, while TikTok's CTR is about **0.88%**.

So low CPC alone is not enough to call a platform efficient. The result shows a clear trade-off between cost per click and the platform's ability to generate clicks from impressions.

[Relevant analysis: Platform Comparison](marketing_campaign_analysis/platform_comparison/)

### 3. Several high-spending campaigns are below the overall campaign CTR average

The analysis identifies **10 campaigns** spending more than $50k while remaining below the campaign-level average CTR of about **2.10%**. Crypto Trading Platform Ads and Smartphone Launch Ads are particularly important to investigate because each spends close to **$600k** while remaining below the average CTR.

I would not call these campaigns wasteful from CTR alone. The next question should be whether their lower CTR is compensated by stronger conversion, revenue or profit.

[Relevant analysis: Expensive Campaigns With Poor Engagement](marketing_campaign_analysis/expensive_campaigns_poor_engagement/)

### 4. Some creatives show strong CTR at meaningful exposure levels

The top 10 ads after applying the minimum-impression criterion have CTRs of roughly **4.58%–4.95%**. Startup HR Video ranks first at about **4.95%**, followed by Gym Fitness Ad at about **4.89%**.

The small difference between the leading ads is important. I would treat them as strong candidates for further investigation rather than assuming the first-ranked ad is dramatically better.

[Relevant analysis: Top Performing Ads](marketing_campaign_analysis/top_performing_ads/)

### 5. Audience response varies considerably, but engagement does not yet equal business value

Frequent Travelers has the highest CTR at about **2.86%**, followed by Young Working Women at about **2.54%** and Startup Founders at about **2.51%**. Gamers is much lower at about **1.42%**.

This suggests meaningful differences in audience response, but I would not immediately increase budget toward the highest-CTR audience. Conversion, revenue, profit and CAC are needed to determine whether these audiences are actually more valuable to the business.

[Relevant analysis: Best Audience Segments](marketing_campaign_analysis/best_audience_segments/)

### 6. Cost efficiency differs significantly between creatives within the same campaign

The CPC ranking shows that ads within the same campaign can have very different click costs. For example, within Summer Electronics Sale, Developer Laptop Ad has a CPC of about **$0.78**, while several other creatives have CPCs above **$1.30**.

This makes within-campaign creative comparison useful for finding patterns worth investigating. However, I would still compare conversion and financial outcomes before moving budget simply because an ad has a lower CPC.

[Relevant analysis: Cost Efficiency Within Campaigns](marketing_campaign_analysis/cost_efficiency_within_campaigns/)

### 7. Some ads receive high exposure but generate much weaker CTR than their campaign peers

The budget-waste analysis identifies ads that receive more impressions than the average ad in their campaign while producing below-average campaign CTR. For example, Developer Laptop Ad and Top Gadget Deals both receive more than **1.28M impressions** in Summer Electronics Sale while their CTR is around **0.58%**, far below the campaign average of about **2.01%**.

These ads deserve investigation because they are receiving substantial exposure without converting that exposure into clicks at the same rate as their campaign peers.

[Relevant analysis: Budget Waste Detection](marketing_campaign_analysis/budget_waste_detection/)

### 8. High-spending ads do not all have the same click efficiency

The five highest-spending ads each consume roughly **$124k–$127k**, but their CTR and CPC differ. Gym Fitness Ad has about **4.89% CTR** and **$2.20 CPC**, while Premium Style Banner has about **3.94% CTR** and **$2.57 CPC**.

The high-spend list itself is not a list of bad ads. It shows where the budget is concentrated and gives us a starting point for checking whether the performance justifies that allocation.

[Relevant analysis: Ads Driving Most Spend](marketing_campaign_analysis/ads_driving_most_spend/)

### 9. The campaign leaderboard shows both scale and click efficiency

B2B SaaS Lead Generation ranks first with **285,063 clicks** and a CPC of about **$2.01**. Summer Electronics Sale generates **253,425 clicks** at a lower CPC of about **$1.91**.

This shows why the leaderboard should not be treated as a direct budget-allocation decision. Click volume provides scale, while CPC provides cost efficiency, but neither tells us whether the resulting traffic produces revenue or profit.

[Relevant analysis: Campaign Leaderboard](marketing_campaign_analysis/campaign_leaderboard/)

### 10. The current data does not show a 2x abnormal campaign-spend day

The abnormal-spend analysis uses each campaign's median daily spend as its baseline and flags days spending more than twice that level. **No campaign-day crossed the 2x threshold** in the available data.

This does not prove that spending is perfectly normal. It only means that no day met the specific rule used in this analysis. The rule can later be made more sensitive if the business wants tighter monitoring.

[Relevant analysis: Abnormal Spend Days](marketing_campaign_analysis/abnormal_spend_days/)

## Important Analytical Limitations

The current analysis is primarily focused on advertising performance metrics such as impressions, clicks, spend, CTR, CPC and engagement.

The database contains a `conversions` table, but the current questions do not require conversion-level analysis. Because of that, the recommendations above should not be interpreted as final budget-allocation decisions.

For stronger business decisions, I would want to connect advertising performance with:

- Conversion rate
- Conversion value / revenue
- Profit and profit margin
- ROAS
- CAC
- Customer lifetime value
- Customer and audience-level behavior

For audience analysis, I would also want client agreement on the relative importance of clicks, likes, shares and comments before creating a weighted engagement score.

Similarly, thresholds such as the 20% of median impression criterion, four-day CTR decline and 2x median-spend rule are analytical choices made to operationalize questions that were not fully specified. They can be changed after discussing the business context with stakeholders.

## Tools & Technologies

- MySQL
- SQL

### SQL Concepts Used

- Multilevel JOINs
- Aggregate functions — SUM(), AVG(), COUNT()
- NULL handling — NULLIF()
- Common Table Expressions (CTEs)
- Window functions
- Ranking functions — DENSE_RANK(), ROW_NUMBER()
- LAG()
- CASE expressions
- Subqueries
- Date functions — YEARWEEK()
- Rolling averages
- Median calculation
- Relational database design
- Primary and foreign keys
- EER modelling

## Project Status

This project is intended as a practical SQL portfolio project demonstrating not only query writing, but also the reasoning behind metric selection, assumptions, business interpretation and recommendation boundaries.
