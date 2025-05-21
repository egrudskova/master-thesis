import os
import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from datetime import datetime
import cx_Oracle

# -------------------------------------
# Function to establish DB connection
# -------------------------------------
def get_db_connection():
    dsn = cx_Oracle.makedsn(
        os.getenv("ORACLE_HOST"),
        int(os.getenv("ORACLE_PORT")),
        sid=os.getenv("ORACLE_SID")
    )
    return cx_Oracle.connect(
        user=os.getenv("ORACLE_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=dsn
    )

# -------------------------------------
# Load data from CHECK_FULL mart
# -------------------------------------
def load_data():
    conn = get_db_connection()
    query = "SELECT * FROM CHECK_FULL"
    df = pd.read_sql(query, conn, parse_dates=["Дата"])
    conn.close()
    return df

# Load DataFrame
df = load_data()

# -------------------------------------
# Streamlit App Configuration
# -------------------------------------
st.set_page_config(layout="wide", page_title="Marketing Analytics")

st.sidebar.header("Filters")

# Date Range Filter
min_date = df["Дата"].min().date()
max_date = df["Дата"].max().date()
start_date = st.sidebar.date_input("Start Date", min_date, min_value=min_date, max_value=max_date)
end_date = st.sidebar.date_input("End Date", max_date, min_value=min_date, max_value=max_date)

# Region Filter
regions = st.sidebar.multiselect(
    "Regions", options=df["Регион"].unique(), default=df["Регион"].unique()
)

# Aggregation Type
agg_type = st.sidebar.radio("Aggregation", ["Day", "Week", "Month"], index=0)

# Show Temperature
show_temperature = st.sidebar.checkbox("Show Temperature", value=True)

# -------------------------------------
# Data Filtering and Aggregation
# -------------------------------------
df_filtered = df[
    (df["Дата"] >= pd.to_datetime(start_date)) &
    (df["Дата"] <= pd.to_datetime(end_date)) &
    (df["Регион"].isin(regions))
].copy()

# set index for resampling
df_filtered.set_index("Дата", inplace=True)

if agg_type == "Week":
    df_agg = df_filtered.resample("W").sum()
elif agg_type == "Month":
    df_agg = df_filtered.resample("M").sum()
else:
    df_agg = df_filtered.resample("D").sum()

df_agg.reset_index(inplace=True)

# -------------------------------------
# Plot: Sales and Temperature
# -------------------------------------
st.subheader("Sales Dynamics")
fig = go.Figure()
fig.add_trace(go.Scatter(
    x=df_agg["Дата"],
    y=df_agg["Продажи (млн руб.)"],
    mode='lines', name="Sales"
))
if show_temperature:
    fig.update_layout(
        yaxis2=dict(title="Temperature (°C)", overlaying='y', side='right')
    )
    fig.add_trace(go.Scatter(
        x=df_agg["Дата"],
        y=df_agg["Температура (°C)"],
        mode='markers', name="Temperature", yaxis='y2'
    ))
fig.update_layout(xaxis_title="Date", yaxis_title="Sales (mln RUB)", hovermode="x unified")
st.plotly_chart(fig, use_container_width=True)

# -------------------------------------
# Promo Code Distribution
# -------------------------------------
st.subheader("Promo Code Distribution")
pie = px.pie(
    df_filtered.reset_index(),
    names="Промокоды",
    title="Promo Code Usage"
)
st.plotly_chart(pie, use_container_width=True)

# -------------------------------------
# Show raw data and download
# -------------------------------------
st.subheader("Data Preview")
st.dataframe(df_agg)

st.subheader("Download Data")
csv = df_agg.to_csv(index=False).encode('utf-8')
st.download_button("Download CSV", data=csv, file_name="sales_data.csv")
