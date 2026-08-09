--Channel performance
--Which communication channel (email, WhatsApp, SMS, LinkedIn DM, Instagram DM, push) drives the best open, click, and reply rates?

SELECT
    dc.channel,
    SUM(fcm.delivered_flag) AS total_delivered,
    ROUND(100.0 * SUM(fcm.opened_flag) / NULLIF(SUM(fcm.delivered_flag), 0), 2) AS open_rate,
    ROUND(100.0 * SUM(fcm.clicked_flag) / NULLIF(SUM(fcm.delivered_flag), 0), 2) AS click_rate,
    ROUND(100.0 * SUM(fcm.replied_flag) / NULLIF(SUM(fcm.delivered_flag), 0), 2) AS reply_rate
FROM dim_campaign dc
JOIN fact_campaign_message fcm
    ON dc.campaign_id = fcm.campaign_id
GROUP BY dc.channel
ORDER BY open_rate DESC;

----------------------------------------------------------------------------------------------------------
--Does channel performance vary by campaign type?
SELECT
    dcamp.channel,
    dcamp.campaign_type,
    SUM(fcm.delivered_flag) AS total_delivered,
    ROUND(100.0 * SUM(fcm.replied_flag) / NULLIF(SUM(fcm.delivered_flag), 0), 2) AS reply_rate
FROM dim_campaign dcamp
JOIN fact_campaign_message fcm ON dcamp.campaign_id = fcm.campaign_id
--WHERE dcamp.channel IN ('WhatsApp', 'LinkedIn DM')
GROUP BY dcamp.channel, dcamp.campaign_type
ORDER BY dcamp.channel, reply_rate DESC;
