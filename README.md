
# Master Thesis (Marketing Analytics Platform)

```
master-thesis/
│
├── airflow/                          # DAGs and Python scripts for ETL processes
│   ├── dags/                         # Airflow DAG definitions
│   └── src/                          # Python logic reused across DAGs
│
├── db/                               # Database initialization scripts
│   └── init/                         # SQL files to create schema and data marts
│
├── grafana/                          # Grafana provisioning
│   └── provisioning/
│       ├── datasources/             # Data source config (Prometheus)
│       └── dashboards/              # Predefined Grafana dashboards (JSON)
│
├── monitoring/                       # Monitoring configuration files
│   ├── prometheus.yml               # Prometheus scrape config
│   └── custom-metrics.toml          # Oracle exporter metrics mapping
│
├── web/                              # Streamlit app
│   ├── campaign_analysis.py         # Main dashboard logic
│   ├── cache.py                     # Redis cache integration
│   └── db_utils.py                  # Database connection helper
│
├── .env                              # Environment variables (Oracle, Redis, Airflow, Grafana)
├── docker-compose.yml                # Multi-service setup for the entire analytics platform
└── README.md                         # Project overview and usage instructions
```
