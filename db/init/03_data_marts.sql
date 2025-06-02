BEGIN
EXECUTE IMMEDIATE 'DROP TABLE CHECK_FULL';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE;
END IF;
END;
/

CREATE TABLE CHECK_FULL AS
SELECT o.order_date                    AS "Date",
       o.order_id                      AS "Order id",
       s.region                        AS "Region",
       (SELECT COUNT(*)
        FROM ORDER_ITEMS i
        WHERE i.order_id = o.order_id) AS "Receipts",
       o.total_amount / 1e6            AS "Sales (million RUB)",
       o.promo_amount / 1e6            AS "Promotional Sales (mln RUB)",
       o.authorizations                AS "Authorizations",
       CASE
           WHEN o.promo_code_id IS NOT NULL
               THEN 'With Promo'
           ELSE 'No Promo'
           END                         AS "Promocode",
       o.temperature                   AS "Temperature (°C)",
       mc.campaign_name                AS "Campaign Name",
       mc.campaign_type                AS "Campaign Type",
       mc.start_date                   AS "Campaign Start",
       mc.end_date                     AS "Campaign End",
       mc.target_audience              AS "Target Audience"
FROM ORDERS o
         JOIN STORES s ON s.store_id = o.store_id
         LEFT JOIN MARKETING_CAMPAIGNS mc
                   ON mc.promo_code_id = o.promo_code_id;

CREATE INDEX idx_check_full_date ON CHECK_FULL ("Date");

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE COMM_METRICS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE;
END IF;
END;
/

CREATE TABLE COMM_METRICS AS
SELECT stat_date                                          AS "Date",
       channel                                            AS "Channel",
       sent_cnt                                           AS "Sent",
       opened_cnt                                         AS "Opened",
       clicks_cnt                                         AS "Clicks",
       unsub_cnt                                          AS "Unsubscribed",
       ROUND(opened_cnt / NULLIF(sent_cnt, 0) * 100, 2)   AS "Open Rate (%)",
       ROUND(clicks_cnt / NULLIF(opened_cnt, 0) * 100, 2) AS "Conversion (%)",
       ROUND(unsub_cnt / NULLIF(opened_cnt, 0) * 100, 2)  AS "Unsubscribe (%)"
FROM COMM_CHANNEL_STATS;

ALTER TABLE COMM_METRICS
    ADD CONSTRAINT pk_comm_metrics
        PRIMARY KEY ("Date", "Channel");

CREATE INDEX idx_cm_date ON COMM_METRICS ("Date");