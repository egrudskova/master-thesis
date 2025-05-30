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
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("""
                   INSERT INTO CHECK_FULL
                   SELECT o.order_date                     AS order_date,
                          s.region                         AS region,
                          o.customer_id                    AS customers,
                          (SELECT COUNT(*)
                           FROM ORDER_ITEMS i
                           WHERE i.order_id = o.order_id)  AS items_count,
                          o.total_amount / 1e6             AS revenue_mln,
                          o.authorizations                 AS authorizations,
                          o.temperature                    AS temperature,
                          CASE
                              WHEN o.promo_code_id IS NOT NULL
                                  THEN 'with_promocode'
                              ELSE 'without_promocode' END AS promo_usage
                   FROM ORDERS o
                            JOIN STORES s ON s.store_id = o.store_id
                   WHERE o.order_date > :last_dt
                   """, last_dt=last_update_date)

    connection.commit()
    cursor.close()
    connection.close()


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
