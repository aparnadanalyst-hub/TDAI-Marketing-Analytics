-- Business Question 4: Campaign effectiveness
-- Which campaigns and campaign types perform best, and how does owned media
-- compare to paid media (Meta Ads, Google Ads)?

WITH spend AS (
    SELECT
        campaign_type,
        is_paid_media,
        COUNT(*) AS num_campaigns,
        SUM(
            CASE
                WHEN is_paid_media = 0 THEN campaign_cost_aud
                ELSE media_spend_aud
            END
        ) AS total_spend
    FROM dim_campaign
    GROUP BY
        campaign_type,
        is_paid_media
),

enrolments AS (
    SELECT
        dcamp.campaign_type,
        dcamp.is_paid_media,
        COUNT(fe.enrolment_id) AS total_enrolments
    FROM dim_campaign dcamp
    LEFT JOIN fact_enrolment fe
        ON dcamp.campaign_id = fe.last_touch_campaign_id
    GROUP BY
        dcamp.campaign_type,
        dcamp.is_paid_media
)

SELECT
    s.campaign_type,
    s.is_paid_media,
    s.num_campaigns,
    s.total_spend,
    e.total_enrolments,
    ROUND(
        s.total_spend / NULLIF(e.total_enrolments, 0),
        2
    ) AS cost_per_enrolment
FROM spend s
JOIN enrolments e
    ON s.campaign_type = e.campaign_type
   AND s.is_paid_media = e.is_paid_media
ORDER BY
    cost_per_enrolment;

/*Note: last_touch_campaign_id is blank (not NULL) for organic/referral enrolments.
 143 of 420 total enrolments (34%) have no last-touch campaign attribution and are
 excluded from this analysis. These enrolments converted at zero attributable campaign spend.*/
SELECT COUNT(*) AS organic_enrolments
FROM fact_enrolment
WHERE last_touch_campaign_id = ''
  OR last_touch_campaign_id IS NULL;
---------------------------------------------------------------------------------------------------------------------------------------
-- Funnel breakdown for paid Intake launch campaigns specifically
-- campaign message sent -> consultation booked -> enrolled
-- Note: fact_web_session has no campaign_id (only utm_source/utm_medium), so the
-- session step cannot be isolated to a specific campaign in this dataset.

WITH target_campaigns AS (
    SELECT campaign_id
    FROM dim_campaign
    WHERE campaign_type = 'Intake launch'
      AND is_paid_media = 1
),

messages AS (
    SELECT COUNT(*) AS messages_sent, SUM(delivered_flag) AS delivered
    FROM fact_campaign_message
    WHERE campaign_id IN (SELECT campaign_id FROM target_campaigns)
),

consultations AS (
    SELECT COUNT(*) AS consultations_booked
    FROM fact_consultation
    WHERE attributed_campaign_id IN (SELECT campaign_id FROM target_campaigns)
),

enrolled AS (
    SELECT COUNT(*) AS enrolments
    FROM fact_enrolment
    WHERE last_touch_campaign_id IN (SELECT campaign_id FROM target_campaigns)
)

SELECT
    m.messages_sent,
    m.delivered,
    c.consultations_booked,
    ROUND(100.0 * c.consultations_booked / NULLIF(m.delivered, 0), 2) AS delivered_to_consultation_pct,
    e.enrolments,
    ROUND(100.0 * e.enrolments / NULLIF(c.consultations_booked, 0), 2) AS consultation_to_enrolment_pct
FROM messages m, consultations c, enrolled e;

/*Note: fact_campaign_message only captures owned sends. Paid media (Meta/Google Ads)
 has no traceable messaging step, so a full funnel from ad exposure to consultation
 cannot be built for paid campaigns with this dataset.*/
