from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

import sys, pathlib
sys.path.append(str(pathlib.Path(__file__).resolve().parents[1] / "src"))
from refresh_job import refresh_check_full_data

dag = DAG(
    'refresh_check_full_data',
    description='Incremental data update for CHECK_FULL',
    schedule_interval='0 3 * * *',
    start_date=datetime(2023, 1, 1),
    catchup=False
)

refresh_task = PythonOperator(
    task_id='refresh_check_full_data',
    python_callable=refresh_check_full_data,
    dag=dag
)
