--Business Question 3.Engagement gaps
--Which segments or contacts are highly engaged but not converting to consultations, or show high unsubscribe/bounce rates?
WITH engagement AS (
    SELECT
        dc.contact_id,
        dc.customer_segment,
        MAX(
            CASE
                WHEN fcm.opened_flag = 1
                  OR fcm.clicked_flag = 1
                  OR fcm.replied_flag = 1
                THEN 1
                ELSE 0
            END
        ) AS is_engaged
    FROM dim_contact dc
    JOIN fact_campaign_message fcm
        ON dc.contact_id = fcm.contact_id
    GROUP BY
        dc.contact_id,
        dc.customer_segment
),

consultation AS (
    SELECT DISTINCT
        contact_id
    FROM fact_consultation
),

bounce_unsub AS (
    SELECT
        dc.contact_id,
        dc.customer_segment,
        SUM(fcm.delivered_flag) AS delivered,
        SUM(fcm.bounced_flag) AS bounced,
        SUM(fcm.unsubscribed_flag) AS unsubscribed
    FROM dim_contact dc
    JOIN fact_campaign_message fcm
        ON dc.contact_id = fcm.contact_id
    GROUP BY
        dc.contact_id,
        dc.customer_segment
)

SELECT
    e.customer_segment,
    COUNT(DISTINCT e.contact_id) AS total_contacts,
    SUM(e.is_engaged) AS engaged_customers,
    COUNT(DISTINCT CASE
        WHEN e.is_engaged = 1
         AND c.contact_id IS NULL
        THEN e.contact_id
    END) AS engaged_not_converted,
    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN e.is_engaged = 1
             AND c.contact_id IS NULL
            THEN e.contact_id
        END)
        / NULLIF(SUM(e.is_engaged), 0),
        2
    ) AS engaged_not_converted_pct,
    ROUND(
        100.0 * SUM(bu.bounced)
        / NULLIF(SUM(bu.delivered + bu.bounced), 0),
        2
    ) AS bounce_rate,
    ROUND(
        100.0 * SUM(bu.unsubscribed)
        / NULLIF(SUM(bu.delivered), 0),
        2
    ) AS unsubscribe_rate
FROM engagement e
LEFT JOIN consultation c
    ON e.contact_id = c.contact_id
LEFT JOIN bounce_unsub bu
    ON e.contact_id = bu.contact_id
GROUP BY
    e.customer_segment
ORDER BY
    engaged_not_converted_pct DESC;

/* Note: bounce_rate = bounced / (delivered + bounced), which excludes a small
number of messages (~1.3%) with no recorded delivery outcome (bounced_flag = 0
AND delivered_flag = 0).*/
