BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CHECK_FULL';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE CHECK_FULL AS
SELECT
    o.order_date                                                         AS "Date",
    s.region                                                             AS "Region",
    o.customer_id                                                        AS "Customers",
    ( SELECT COUNT(*)
        FROM ORDER_ITEMS i
       WHERE i.order_id = o.order_id )                                   AS "Receipts",
    o.total_amount / 1e6                                                 AS "Sales (million RUB)",
    o.authorizations                                                     AS "Authorizations",
    o.temperature                                                        AS "Temperature (°C)",
    CASE WHEN o.promo_code_id IS NOT NULL
         THEN 'With Promo'
         ELSE 'No Promo'
    END                                                                 AS "PromoCode",
    mc.campaign_name                                                     AS "CampaignName",
    mc.campaign_type                                                     AS "CampaignType",
    mc.start_date                                                        AS "CampaignStart",
    mc.end_date                                                          AS "CampaignEnd",
    mc.target_audience                                                   AS "TargetAudience"
FROM ORDERS o
JOIN STORES s                ON s.store_id      = o.store_id
LEFT JOIN MARKETING_CAMPAIGNS mc
                             ON mc.promo_code_id = o.promo_code_id;

CREATE INDEX idx_check_full_date ON CHECK_FULL("Date");
