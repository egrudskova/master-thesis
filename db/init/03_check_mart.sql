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
    CASE WHEN o.promo_code_id IS NOT NULL
         THEN 'With Promo'
         ELSE 'No Promo'
    END                                                                 AS "Promo Code",
    mc.campaign_name                                                     AS "Campaign Name",
    mc.campaign_type                                                     AS "Campaign Type",
    mc.start_date                                                        AS "Campaign Start",
    mc.end_date                                                          AS "Campaign End",
    mc.target_audience                                                   AS "Target Audience"
FROM ORDERS o
JOIN STORES s                ON s.store_id      = o.store_id
LEFT JOIN MARKETING_CAMPAIGNS mc
                             ON mc.promo_code_id = o.promo_code_id;

CREATE INDEX idx_check_full_date ON CHECK_FULL("Date");
