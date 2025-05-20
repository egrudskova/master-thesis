BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CHECK_FULL';
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
/

CREATE TABLE CHECK_FULL AS
SELECT
    o.order_date                         AS "Date",
    s.region                             AS "Region",
    o.customer_id                        AS "Clients",
    (SELECT COUNT(*)
       FROM ORDER_ITEMS i
      WHERE i.order_id = o.order_id
    )                                    AS "Items Count",
    o.total_amount / 1e6                 AS "Revenue (mln)",
    o.authorizations                     AS "Authorizations",
    o.temperature                        AS "Temperature (°C)",
    CASE
      WHEN o.promo_code_id IS NOT NULL THEN 'With promocode'
      ELSE 'Without promocode'
    END                                  AS "Promo Code Usage"
FROM ORDERS o
JOIN STORES s
  ON s.store_id = o.store_id;

CREATE INDEX idx_check_full_date
  ON CHECK_FULL("Date");
