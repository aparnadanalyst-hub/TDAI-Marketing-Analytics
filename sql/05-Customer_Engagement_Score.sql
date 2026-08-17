-- Business Question 5: Customer engagement score
--A composite score built from open rate, click rate, and web session activity, used to rank and segment contacts by engagement score.
WITH messaging AS (
    SELECT
        contact_id,
        SUM(delivered_flag) AS delivered,
        SUM(opened_flag) AS opens,
        SUM(clicked_flag) AS clicks,
        ROUND(100.0 * SUM(opened_flag) / NULLIF(SUM(delivered_flag), 0), 2) AS open_rate,
        ROUND(100.0 * SUM(clicked_flag) / NULLIF(SUM(delivered_flag), 0), 2) AS click_rate
    FROM fact_campaign_message
    GROUP BY contact_id
),
sessions AS (
    SELECT
        contact_id,
        COUNT(session_id) AS session_count
    FROM fact_web_session
    GROUP BY contact_id
),
engagement AS (
    SELECT
        m.contact_id,
        m.delivered,
        m.opens,
        m.clicks,
        m.open_rate,
        m.click_rate,
        COALESCE(s.session_count, 0) AS session_count,
        ROUND(
            (
                m.open_rate
                + m.click_rate
                + (MIN(COALESCE(s.session_count, 0), 10) / 10.0 * 100)
            ) / 3,
            2
        ) AS engagement_score
    FROM messaging m
    LEFT JOIN sessions s ON m.contact_id = s.contact_id
)
SELECT
    d.customer_segment,
    e.contact_id,
    e.delivered,
    e.opens,
    e.clicks,
    e.open_rate,
    e.click_rate,
    e.session_count,
    e.engagement_score,
    DENSE_RANK() OVER (ORDER BY e.engagement_score DESC) AS engagement_rank
FROM engagement e
JOIN dim_contact d ON d.contact_id = e.contact_id
ORDER BY e.engagement_score DESC;
