CREATE TABLE ORDERS (
    order_id            NUMBER         PRIMARY KEY,
    customer_id         NUMBER         NOT NULL,
    order_date          TIMESTAMP      NOT NULL,
    total_amount        DECIMAL(12,2)  NOT NULL,
    payment_method      VARCHAR2(50)   NOT NULL,
    delivery_address    VARCHAR2(255)  NOT NULL,
    order_channel       VARCHAR2(50)   NOT NULL,
    store_id            NUMBER         NOT NULL,
    promo_code_id       NUMBER,
    authorizations      NUMBER,
    temperature         NUMBER(5,1)
);


CREATE TABLE ORDER_ITEMS (
    order_item_id NUMBER PRIMARY KEY,
    order_id      NUMBER REFERENCES ORDERS(order_id),
    product_id    NUMBER,
    quantity      NUMBER,
    price         NUMBER(12,2)
);

CREATE TABLE PRODUCTS (
    product_id   NUMBER PRIMARY KEY,
    product_name VARCHAR2(255),
    category     VARCHAR2(100)
);

CREATE TABLE STORES (
    store_id    NUMBER PRIMARY KEY,
    store_name  VARCHAR2(100),
    region      VARCHAR2(50)
);

CREATE TABLE CHECK_FULL_LAST_UPDATE (
    id               NUMBER(1) PRIMARY KEY,
    last_update_date DATE
);

INSERT INTO CHECK_FULL_LAST_UPDATE VALUES (1, TO_DATE('1900-01-01','YYYY-MM-DD'));
