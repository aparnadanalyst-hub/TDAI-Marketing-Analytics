[README.md](https://github.com/user-attachments/files/30869662/README.md)
# TDAI Marketing Analysis

## Business Context

The Data Analytics Institute (TDAI) is an Australian training and career-coaching
organisation that helps job seekers, career changers, and newcomers break into data and
AI roles through live technical training and real-world internships.

This project analyses TDAI's marketing funnel — from campaign message, to website
session, to consultation booking, to enrolment — to answer key business questions the
marketing team can act on to improve engagement, channel strategy, and ROI.

*Note: this analysis uses a synthetic dataset built to mirror a real marketing analytics
environment. No real person, campaign, or company data is used.*

## Business Questions

1. **Customer segment engagement** — Which customer segments show the highest
   engagement with marketing communications?
2. **Channel performance** — Which communication channel (email, WhatsApp, SMS,
   LinkedIn DM, Instagram DM, push) drives the best open, click, and reply rates?
3. **Engagement gaps** — Which segments or contacts are highly engaged but not
   converting to consultations, or show high unsubscribe/bounce rates?
4. **Campaign effectiveness** — Which campaigns and campaign types perform best, and
   how does owned media compare to paid media (Meta Ads, Google Ads)?
5. **Customer engagement score** — A composite score built from open rate, click rate,
   and web session activity, used to rank and segment contacts by engagement level.
6. **Funnel conversion & ROI** — Which lead sources and campaigns convert best from
   consultation to enrolment, and at what cost per enrolment?

## Advanced Analytics

Beyond descriptive reporting, this project applies the following techniques:

7. **Engagement scoring & tiering** — A multi-factor score combining recency (days
   since `last_activity_date`), frequency (opens/clicks), and depth (web sessions,
   pages viewed), with contacts bucketed into High / Medium / Low tiers using
   percentile ranking (`NTILE`).
8. **Multi-touch attribution comparison** — First-touch vs last-touch attribution
   compared side by side, showing how enrolment credit shifts across channels
   depending on the model used.
9. **Predictive modelling (lightweight)** — A logistic regression / decision tree
   (Python, pandas + scikit-learn) predicting consultation booking or enrolment
   likelihood from lead source, segment, and engagement score, evaluated with AUC.
10. **Cost efficiency / marginal ROI** — Cost per lead → cost per consultation → cost
    per enrolment, broken down by channel and campaign, connecting engagement to spend
    efficiency.

## Data Model

Star schema — three dimensions (`dim_programme`, `dim_contact`, `dim_campaign`) and four
facts (`fact_campaign_message`, `fact_web_session`, `fact_consultation`,
`fact_enrolment`), with `contact_id` as the spine connecting the marketing → website →
consultation → enrolment funnel.

## Repository Structure

```
tdai-marketing-analytics/
├── README.md                    <- this file: context, questions, findings
├── sql/                          <- descriptive queries, one per business question
│   ├── 01_segment_engagement.sql
│   ├── 02_channel_performance.sql
│   ├── 03_engagement_gaps.sql
│   ├── 04_campaign_effectiveness.sql
│   ├── 05_engagement_score.sql
│   └── 06_funnel_conversion_roi.sql
├── advanced/                     <- advanced analytics: SQL + Python
│   ├── 07_engagement_tiering.sql
│   ├── 08_attribution_comparison.sql
│   ├── 09_predictive_model.py
│   └── 10_cost_efficiency_roi.sql
├── results/                      <- query outputs (csv / charts)
└── data_model.png                <- star schema diagram
```
# TDAI Marketing Analysis

## Business Context

The Data Analytics Institute (TDAI) is an Australian training and career-coaching
organisation that helps job seekers, career changers, and newcomers break into data and
AI roles through live technical training and real-world internships.

This project analyses TDAI's marketing funnel, from campaign message, to website
session, to consultation booking, to enrolment, to answer key business questions the
marketing team can act on to improve engagement, channel strategy, and ROI.

*Note: this analysis uses a synthetic dataset built to mirror a real marketing analytics
environment. No real person, campaign, or company data is used.*

## Business Questions

1. **Customer segment engagement**
   - Which customer segments show the highest engagement with marketing communications?
2. **Channel performance**
   - Which communication channel (email, WhatsApp, SMS, LinkedIn DM, Instagram DM,
     push) drives the best open, click, and reply rates?
3. **Engagement gaps**
   - Which segments or contacts are highly engaged but not converting to
     consultations, or show high unsubscribe/bounce rates?
4. **Campaign effectiveness**
   - Which campaigns and campaign types perform best, and how does owned media
     compare to paid media (Meta Ads, Google Ads)?
5. **Customer engagement score**
   - A composite score built from open rate, click rate, and web session activity,
     used to rank and segment contacts by engagement level.
6. **Funnel conversion and ROI**
   - Which lead sources and campaigns convert best from consultation to enrolment,
     and at what cost per enrolment?

## Advanced Analytics

Beyond descriptive reporting, this project applies the following techniques:

7. **Engagement scoring and tiering**
   - A multi-factor score combining recency (days since `last_activity_date`),
     frequency (opens/clicks), and depth (web sessions, pages viewed).
   - Contacts bucketed into High, Medium, and Low tiers using percentile ranking
     (`NTILE`).
8. **Multi-touch attribution comparison**
   - First-touch vs last-touch attribution compared side by side.
   - Shows how enrolment credit shifts across channels depending on the model used.
9. **Predictive modelling (lightweight)**
   - A logistic regression / decision tree (Python, pandas, scikit-learn) predicting
     consultation booking or enrolment likelihood from lead source, segment, and
     engagement score.
   - Evaluated with AUC.
10. **Cost efficiency and marginal ROI**
    - Cost per lead, cost per consultation, cost per enrolment, broken down by
      channel and campaign.
    - Connects engagement to spend efficiency.

## Data Model

Star schema. Three dimensions (`dim_programme`, `dim_contact`, `dim_campaign`) and four
facts (`fact_campaign_message`, `fact_web_session`, `fact_consultation`,
`fact_enrolment`), with `contact_id` as the spine connecting the marketing, website,
consultation, and enrolment funnel.

## Repository Structure

```
tdai-marketing-analytics/
├── README.md                    <- this file: context, questions, findings
├── sql/                          <- descriptive queries, one per business question
│   ├── 01_segment_engagement.sql
│   ├── 02_channel_performance.sql
│   ├── 03_engagement_gaps.sql
│   ├── 04_campaign_effectiveness.sql
│   ├── 05_engagement_score.sql
│   └── 06_funnel_conversion_roi.sql
├── advanced/                     <- advanced analytics: SQL + Python
│   ├── 07_engagement_tiering.sql
│   ├── 08_attribution_comparison.sql
│   ├── 09_predictive_model.py
│   └── 10_cost_efficiency_roi.sql
├── results/                      <- query outputs (csv / charts)
└── data_model.png                <- star schema diagram
```

## Further Improvements

Given more time, more data, or a production environment, the next additions would be:

- **Cohort analysis over a longer time horizon.**
  - This dataset spans 7 months, enough for an early signal but not a robust trend.
  - At production scale, with years of customer history, cohort analysis would show
    how communication engagement evolves across a customer's full lifecycle, not just
    a single training-programme funnel.
- **Statistical significance testing on strategy changes before rollout.**
  - With 420 enrolments spread across 183 campaigns, most campaigns have too few
    conversions to test reliably at the individual-campaign level.
  - In a live environment with higher volume, this would extend to proper A/B or
    sequential significance testing, validating a contact-strategy change on a sample
    before deploying it to the full customer base.

## Status

Analysis in progress. SQL queries and findings being added.

## Findings

### 1. Customer segment engagement

**Insight**
- Experienced professionals, career switchers, and return-to-work contacts show the
  highest and most consistent message-level engagement (47-49%).
- Final year students and international students engage least (40-44%).
- Nearly all segments reach broad one-time engagement (94-97% of contacts engage with
  at least one message), so the real differentiator between segments is sustained
  interest, not initial reach.

**Recommendation**
- Prioritise career-progression content, such as career growth pathways, job search
  accelerator programmes, and career-change success stories, for experienced
  professionals, career switchers, and return-to-work contacts, since these segments
  are already most responsive and likely to act on advancement-focused messaging.
- For final year students and international students, where engagement is weaker,
  test alternative content angles (for example, internship and real-world experience
  framing for final year students, or visa/work-rights guidance for international
  students) rather than assuming the same messaging will resonate.
- Since this reasoning is based on general assumptions about each segment rather than
  evidence from this dataset, treat it as a hypothesis to A/B test, not a confirmed
  driver. A follow-up check would be to see whether contacts in these segments already
  engage more with any existing internship or visa-related campaigns, which would turn
  this into an evidence-based recommendation.

## Further Improvements

Given more time, more data, or a production environment, the next additions would be:

- **Cohort analysis over a longer time horizon.** This dataset spans 7 months, which is
  enough for an early signal but not a robust trend. At production scale — years of
  customer history — cohort analysis would show how communication engagement evolves
  across a customer's full lifecycle, not just a single training-programme funnel.
- **Statistical significance testing on strategy changes before rollout.** With 420
  enrolments spread across 183 campaigns, most campaigns have too few conversions to
  test reliably at the individual-campaign level. In a live environment with higher
  volume, this would extend to proper A/B or sequential significance testing — validating
  a contact-strategy change on a sample before deploying it to the full customer base.

## Tools Used

SQL (SQLite), star schema data modelling, marketing funnel analysis.
