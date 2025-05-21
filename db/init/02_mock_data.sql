INSERT ALL
  INTO STORES (store_id, store_name, region) VALUES (101, 'Moscow, Aviapark Mall',    'Moscow')
  INTO STORES (store_id, store_name, region) VALUES (102, 'Moscow, MEGA Khimki',      'Moscow')
  INTO STORES (store_id, store_name, region) VALUES (201, 'St. Petersburg, Gallery',  'St. Petersburg')
  INTO STORES (store_id, store_name, region) VALUES (202, 'St. Petersburg, PIK',      'St. Petersburg')
  INTO STORES (store_id, store_name, region) VALUES (301, 'Kazan, Park House',        'Kazan')
  INTO STORES (store_id, store_name, region) VALUES (401, 'Yekaterinburg, Greenwich', 'Yekaterinburg')
  INTO STORES (store_id, store_name, region) VALUES (501, 'Novosibirsk, Aura',        'Novosibirsk')
SELECT 1 FROM dual;

INSERT ALL
  INTO PROMO_CODES (promo_code_id, code_label) VALUES (1001, 'HUGGIES15')
  INTO PROMO_CODES (promo_code_id, code_label) VALUES (1002, 'KLEENEXFREE')
  INTO PROMO_CODES (promo_code_id, code_label) VALUES (1003, 'KOTEX50')
SELECT 1 FROM dual;

INSERT ALL
    INTO MARKETING_CAMPAIGNS (campaign_id, campaign_name, campaign_type,
                             start_date, end_date, target_audience, promo_code_id)
        VALUES (1,
                '15% off Huggies® diapers on orders over 2000 RUB',
                'Product Discount',
                DATE '2024-05-01', DATE '2024-05-31',
                'Parents of infants', 1001)
    INTO MARKETING_CAMPAIGNS (campaign_id, campaign_name, campaign_type,
                             start_date, end_date, target_audience, promo_code_id)
        VALUES (2,
                'Free box of Kleenex® tissues with any purchase of 500 RUB or more',
                'Gift with Purchase',
                DATE '2024-06-01', DATE '2024-06-30',
                'All customers', 1002)
    INTO MARKETING_CAMPAIGNS (campaign_id, campaign_name, campaign_type,
                             start_date, end_date, target_audience, promo_code_id)
        VALUES (3,
                'Buy two Kotex® products and get the third at 50% off',
                'Bundle Offer',
                DATE '2024-07-01', DATE '2024-07-31',
                'Women 18-35', 1003)
SELECT 1 FROM dual;


INSERT /*+ APPEND */ INTO ORDERS (
    order_id, customer_id, order_date, total_amount, payment_method,
    delivery_address, order_channel, store_id, promo_code_id,
    authorizations, temperature
)
SELECT
    LEVEL                                    AS order_id,
    MOD(LEVEL, 5000) + 1                     AS customer_id,
    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365))               AS order_date,
    ROUND(DBMS_RANDOM.VALUE(100, 10000), 2)                  AS total_amount,
    CASE MOD(LEVEL, 4)
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'Online'
        ELSE 'Mobile Pay'
    END                                         AS payment_method,
    'Address ' || LEVEL                         AS delivery_address,
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Web'
        WHEN 1 THEN 'Mobile'
        ELSE 'In-Store'
    END                                         AS order_channel,
    CASE MOD(LEVEL, 7)
        WHEN 0 THEN 101
        WHEN 1 THEN 102
        WHEN 2 THEN 201
        WHEN 3 THEN 202
        WHEN 4 THEN 301
        WHEN 5 THEN 401
        ELSE      501
    END                                         AS store_id,
    CASE
        WHEN DBMS_RANDOM.VALUE < 0.05 THEN 1001
        WHEN DBMS_RANDOM.VALUE < 0.10 THEN 1002
        WHEN DBMS_RANDOM.VALUE < 0.15 THEN 1003
        ELSE NULL
    END                                         AS promo_code_id,
    TRUNC(DBMS_RANDOM.VALUE(1, 150))            AS authorizations,
    ROUND(DBMS_RANDOM.VALUE(-15, 30), 1)        AS temperature
FROM dual
CONNECT BY LEVEL <= 36000;

INSERT /*+ APPEND */ INTO PRODUCTS (
    product_id, product_name, category
)
SELECT
    LEVEL                   AS product_id,
    'Product ' || LEVEL     AS product_name,
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Apparel'
        ELSE 'Home'
    END                     AS category
FROM dual
CONNECT BY LEVEL <= 100;

INSERT /*+ APPEND */ INTO ORDER_ITEMS (
    order_item_id, order_id, product_id, quantity, price
)
SELECT
    ROWNUM                              AS order_item_id,
    MOD(ROWNUM, 36000) + 1              AS order_id,
    MOD(ROWNUM, 100) + 1                AS product_id,
    TRUNC(DBMS_RANDOM.VALUE(1, 5))      AS quantity,
    ROUND(DBMS_RANDOM.VALUE(10, 500),2) AS price
FROM dual
CONNECT BY ROWNUM <= 100000;

COMMIT;