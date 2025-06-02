from datetime import datetime

from db_utils import get_db_connection


def get_last_update_date():
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT last_update_date FROM CHECK_FULL_LAST_UPDATE WHERE id = 1")
    last_dt, = cursor.fetchone()

    cursor.close()
    connection.close()
    return last_dt


def insert_new_data(last_update_date):
    conn   = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO CHECK_FULL (
            "Date", "Order id", "Region", "Receipts",
            "Sales (million RUB)", "Promotional Sales (mln RUB)",
            "Authorizations", "Promocode", "Temperature (°C)",
            "Campaign Name", "Campaign Type",
            "Campaign Start", "Campaign End", "Target Audience"
        )
        SELECT
            o.order_date                                     AS "Date",
            o.order_id                                       AS "Order id",
            s.region                                         AS "Region",

            ( SELECT COUNT(*) FROM ORDER_ITEMS i
              WHERE i.order_id = o.order_id )                AS "Receipts",

            o.total_amount       / 1e6                       AS "Sales (million RUB)",
            o.promo_amount       / 1e6                       AS "Promotional Sales (mln RUB)",
            o.authorizations                                AS "Authorizations",

            CASE WHEN o.promo_code_id IS NOT NULL
                 THEN 'With Promo' ELSE 'No Promo' END       AS "Promocode",

            o.temperature                                   AS "Temperature (°C)",

            mc.campaign_name                                AS "Campaign Name",
            mc.campaign_type                                AS "Campaign Type",
            mc.start_date                                   AS "Campaign Start",
            mc.end_date                                     AS "Campaign End",
            mc.target_audience                              AS "Target Audience"
        FROM ORDERS o
        JOIN STORES s
          ON s.store_id = o.store_id
        LEFT JOIN MARKETING_CAMPAIGNS mc
          ON mc.promo_code_id = o.promo_code_id
        WHERE o.order_date > :last_dt
    """, last_dt=last_update_date)

    conn.commit()
    cursor.close()
    conn.close()


def update_last_update_date():
    connection = get_db_connection()
    cursor = connection.cursor()

    query = "UPDATE CHECK_FULL_LAST_UPDATE SET last_update_date = :new_date"
    cursor.execute(query, {"new_date": datetime.now()})
    connection.commit()

    cursor.close()
    connection.close()


def refresh_check_full_data():
    last_update_date = get_last_update_date()
    insert_new_data(last_update_date)
    update_last_update_date()
