import redis
import json

from db_utils import get_db_connection

redis_client = redis.StrictRedis(host="redis", port=6379, db=0, decode_responses=True)
def load_campaign_data():
    cached_data = redis_client.get("sales_data")
    if cached_data:
        return json.loads(cached_data)
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("""
        SELECT "Campaign Name" AS campaign_name, SUM("Sales (million RUB)") AS total_sales
        FROM CHECK_FULL
        GROUP BY "Campaign Name"
    """)
    result = cursor.fetchall()
    cursor.close()
    connection.close()

    redis_client.set("sales_data", json.dumps(result), ex=3600)
    return result
