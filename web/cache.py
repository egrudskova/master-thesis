import json
import time

import psutil
import redis
from prometheus_client import start_http_server, Gauge, Counter

from db_utils import get_db_connection

start_http_server(8001)

REQ_LATENCY = Gauge("request_processing_seconds",
                    "Time spent processing load_campaign_data()")

QUERY_TIME = Gauge("query_execution_time",
                   "Oracle query execution time when cache miss")

CPU_USAGE = Gauge("cpu_usage",
                  "Container CPU utilisation percent")

CACHE_HITS = Counter("redis_cache_hit_total", "Redis cache hits")
TOTAL_REQ = Counter("load_campaign_requests_total", "Total calls of load_campaign_data()")
CACHE_RATE = Gauge("redis_cache_hit_rate", "Ratio of cache hits vs total requests")

redis_client = redis.StrictRedis(
    host="redis", port=6379, db=0, decode_responses=True
)


def _update_cpu_and_rate():
    CPU_USAGE.set(psutil.cpu_percent(interval=None))
    if TOTAL_REQ._value.get() > 0:
        rate = CACHE_HITS._value.get() / TOTAL_REQ._value.get()
        CACHE_RATE.set(rate * 100)


def load_campaign_data():
    start_total = time.time()
    TOTAL_REQ.inc()

    cached = redis_client.get("sales_data")
    if cached:
        CACHE_HITS.inc()
        _update_cpu_and_rate()  # CPU + hit-rate
        REQ_LATENCY.set(time.time() - start_total)
        return json.loads(cached)

    conn = get_db_connection()
    cur = conn.cursor()

    start_q = time.time()
    cur.execute("""
                SELECT "Campaign Name"            AS campaign_name,
                       SUM("Sales (million RUB)") AS total_sales
                FROM CHECK_FULL
                GROUP BY "Campaign Name"
                """)
    result = cur.fetchall()
    QUERY_TIME.set(time.time() - start_q)

    cur.close()
    conn.close()

    redis_client.set("sales_data", json.dumps(result), ex=3600)

    _update_cpu_and_rate()
    REQ_LATENCY.set(time.time() - start_total)
    return result
