-- Business Question 1: Customer segment engagement
-- Engagement defined as a message with at least one open, click, or reply

-- Message-level engagement rate
SELECT
    dc.customer_segment,
    SUM(fcm.delivered_flag) AS total_delivered,
    SUM(fcm.opened_flag) AS total_opens,
    SUM(fcm.clicked_flag) AS total_clicks,
    SUM(fcm.replied_flag) AS total_replies,
    ROUND(
        100.0 * SUM(
            CASE WHEN fcm.opened_flag = 1
                   OR fcm.clicked_flag = 1
                   OR fcm.replied_flag = 1
                 THEN 1 ELSE 0 END
        ) / NULLIF(SUM(fcm.delivered_flag), 0),
        2
    ) AS engagement_rate
FROM dim_contact dc
JOIN fact_campaign_message fcm
    ON dc.contact_id = fcm.contact_id
GROUP BY dc.customer_segment
ORDER BY engagement_rate DESC;
-------------------------------------------------------------------------------------------------------

-- Customer-level engagement rate (% of unique contacts who engaged at least once)
SELECT
    dc.customer_segment,
    COUNT(DISTINCT CASE
        WHEN fcm.opened_flag = 1 OR fcm.clicked_flag = 1 OR fcm.replied_flag = 1
        THEN dc.contact_id
    END) AS unique_engaged_customers,
    COUNT(DISTINCT dc.contact_id) AS total_customers_contacted,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN fcm.opened_flag = 1 OR fcm.clicked_flag = 1 OR fcm.replied_flag = 1
            THEN dc.contact_id
        END) / NULLIF(COUNT(DISTINCT dc.contact_id), 0),
        2
    ) AS customer_engagement_rate
FROM dim_contact dc
JOIN fact_campaign_message fcm
    ON dc.contact_id = fcm.contact_id
GROUP BY dc.customer_segment
ORDER BY customer_engagement_rate DESC;
