INSERT INTO STORES (store_id, store_name, region) VALUES (101, 'Moscow, Aviapark Mall',        'Moscow');
INSERT INTO STORES (store_id, store_name, region) VALUES (102, 'Moscow, MEGA Khimki',         'Moscow');
INSERT INTO STORES (store_id, store_name, region) VALUES (201, 'St. Petersburg, Gallery',     'St. Petersburg');
INSERT INTO STORES (store_id, store_name, region) VALUES (202, 'St. Petersburg, PIK',         'St. Petersburg');
INSERT INTO STORES (store_id, store_name, region) VALUES (301, 'Kazan, Park House',           'Kazan');
INSERT INTO STORES (store_id, store_name, region) VALUES (401, 'Yekaterinburg, Greenwich',    'Yekaterinburg');
INSERT INTO STORES (store_id, store_name, region) VALUES (501, 'Novosibirsk, Aura',           'Novosibirsk');

INSERT /*+ APPEND */ INTO ORDERS (
    order_id,
    customer_id,
    order_date,
    total_amount,
    payment_method,
    delivery_address,
    order_channel,
    store_id,
    promo_code_id,
    authorizations,
    temperature
)
SELECT
    LEVEL                          AS order_id,
    MOD(LEVEL, 5000) + 1           AS customer_id,
    TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 365)) AS order_date,
    ROUND(DBMS_RANDOM.VALUE(100, 10000), 2)    AS total_amount,
    CASE MOD(LEVEL, 4)
      WHEN 0 THEN 'Credit Card'
      WHEN 1 THEN 'Cash'
      WHEN 2 THEN 'Online'
      ELSE 'Mobile Pay'
    END                              AS payment_method,
    'Address ' || LEVEL             AS delivery_address,
    CASE MOD(LEVEL, 3)
      WHEN 0 THEN 'Web'
      WHEN 1 THEN 'Mobile'
      ELSE 'In-Store'
    END                              AS order_channel,
    CASE MOD(LEVEL, 7)
      WHEN 0 THEN 101  -- Москва
      WHEN 1 THEN 102  -- Москва
      WHEN 2 THEN 201  -- Санкт-Петербург
      WHEN 3 THEN 202  -- Санкт-Петербург
      WHEN 4 THEN 301  -- Казань
      WHEN 5 THEN 401  -- Екатеринбург
      ELSE      501    -- Новосибирск
    END AS store_id,
    CASE WHEN DBMS_RANDOM.VALUE < 0.3
      THEN MOD(LEVEL, 50) + 1
      ELSE NULL
    END                              AS promo_code_id,
    TRUNC(DBMS_RANDOM.VALUE(1, 150)) AS authorizations,
    ROUND(DBMS_RANDOM.VALUE(-15, 30), 1) AS temperature
FROM dual
CONNECT BY LEVEL <= 36000;

INSERT /*+ APPEND */ INTO PRODUCTS (
    product_id,
    product_name,
    category
)
SELECT
    LEVEL                                 AS product_id,
    'Product ' || LEVEL                   AS product_name,
    CASE MOD(LEVEL,3)
      WHEN 0 THEN 'Electronics'
      WHEN 1 THEN 'Apparel'
      ELSE 'Home'
    END                                    AS category
FROM dual
CONNECT BY LEVEL <= 100;


INSERT /*+ APPEND */ INTO ORDER_ITEMS (
    order_item_id,
    order_id,
    product_id,
    quantity,
    price
)
SELECT
    ROWNUM                                      AS order_item_id,
    MOD(ROWNUM,36000) + 1                       AS order_id,
    MOD(ROWNUM,100) + 1                         AS product_id,
    TRUNC(DBMS_RANDOM.VALUE(1,5))               AS quantity,
    ROUND(DBMS_RANDOM.VALUE(10,500),2)          AS price
FROM dual
CONNECT BY ROWNUM <= 100000;
