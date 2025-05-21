CREATE TABLE PRODUCTS (
    product_id   NUMBER PRIMARY KEY,
    product_name VARCHAR2(255),
    category     VARCHAR2(100)
);

CREATE TABLE STORES (
    store_id   NUMBER PRIMARY KEY,
    store_name VARCHAR2(100),
    region     VARCHAR2(50)
);

CREATE TABLE PROMO_CODES (
    promo_code_id NUMBER PRIMARY KEY,
    code_label    VARCHAR2(50)
);

CREATE TABLE MARKETING_CAMPAIGNS (
    campaign_id     NUMBER        PRIMARY KEY,
    campaign_name   VARCHAR2(255) NOT NULL,
    campaign_type   VARCHAR2(100),
    start_date      DATE,
    end_date        DATE,
    target_audience VARCHAR2(255),
    promo_code_id   NUMBER UNIQUE,
    CONSTRAINT fk_campaign_code
        FOREIGN KEY (promo_code_id)
        REFERENCES PROMO_CODES (promo_code_id)
);

CREATE TABLE ORDERS (
    order_id         NUMBER        PRIMARY KEY,
    customer_id      NUMBER        NOT NULL,
    order_date       TIMESTAMP     NOT NULL,
    total_amount     DECIMAL(12,2) NOT NULL,
    payment_method   VARCHAR2(50)  NOT NULL,
    delivery_address VARCHAR2(255) NOT NULL,
    order_channel    VARCHAR2(50)  NOT NULL,
    store_id         NUMBER        NOT NULL,
    promo_code_id    NUMBER,
    authorizations   NUMBER,
    temperature      NUMBER(5,1),
    CONSTRAINT fk_order_store
        FOREIGN KEY (store_id)
        REFERENCES STORES (store_id),
    CONSTRAINT fk_order_promo
        FOREIGN KEY (promo_code_id)
        REFERENCES PROMO_CODES (promo_code_id)
);


CREATE TABLE ORDER_ITEMS (
    order_item_id NUMBER PRIMARY KEY,
    order_id      NUMBER NOT NULL,
    product_id    NUMBER NOT NULL,
    quantity      NUMBER,
    price         NUMBER(12,2),
    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id)
        REFERENCES ORDERS (order_id),
    CONSTRAINT fk_item_product
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS (product_id)
);

CREATE TABLE CHECK_FULL_LAST_UPDATE (
    id               NUMBER(1) PRIMARY KEY,
    last_update_date DATE
);

INSERT INTO CHECK_FULL_LAST_UPDATE
VALUES (1, DATE '1900-01-01');
