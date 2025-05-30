import os

import oracledb as cx_Oracle


def get_db_connection():
    dsn = cx_Oracle.makedsn(
        os.getenv("ORACLE_HOST"),
        int(os.getenv("ORACLE_PORT")),
        sid=os.getenv("ORACLE_SID")
    )
    return cx_Oracle.connect(
        user=os.getenv("ORACLE_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=dsn,
        mode=cx_Oracle.SYSDBA
    )
