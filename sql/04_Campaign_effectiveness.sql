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
