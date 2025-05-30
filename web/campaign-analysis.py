import os
from datetime import datetime
import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
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


def load_data(mart_name):
    conn = get_db_connection()
    query = f"SELECT * FROM {mart_name}"
    loaded_df = pd.read_sql(query, conn, parse_dates=["Date"])
    loaded_df = loaded_df.sort_values("Date").reset_index(drop=True)
    conn.close()
    return loaded_df


df = load_data("CHECK_FULL")
df_channels = load_data("COMM_METRICS")

st.set_page_config(layout="wide", page_title="Marketing Campaign Analytics")

st.sidebar.header("📊 Data Filter")

max_date = df["Date"].max().date()
min_date = (max_date - pd.DateOffset(months=3)).date()
start_date = st.sidebar.date_input("📅 Start date", min_date, min_value=min_date, max_value=max_date)
end_date = st.sidebar.date_input("📅 End date", max_date, min_value=min_date, max_value=max_date)

regions = st.sidebar.multiselect("🌍 Select regions", df["Region"].unique(), default="Moscow")

agg_type = st.sidebar.radio("📊 Aggregation:", ["Day", "Week", "Month"], index=0)

show_last_year = st.sidebar.checkbox("Compare with last year", value=True)

mask_cur_period = (
        (df["Date"] >= pd.to_datetime(start_date)) &
        (df["Date"] <= pd.to_datetime(end_date)) &
        (df["Region"].isin(regions))
)
df_filtered_curr = df.loc[mask_cur_period].copy()

mask_prev_period = (
        (df["Date"] >= pd.to_datetime(start_date) - pd.DateOffset(years=1)) &
        (df["Date"] <= pd.to_datetime(end_date) - pd.DateOffset(years=1)) &
        (df["Region"].isin(regions))
)
df_filtered_prev = df.loc[mask_prev_period].copy()

df_filtered_curr["FakeDate"] = df_filtered_curr["Date"]
df_filtered_prev["FakeDate"] = df_filtered_prev["Date"] + pd.DateOffset(years=1)


def aggregate_data(df_in, agg_type_in):
    df_ = df_in.copy()
    df_.set_index("FakeDate", inplace=True)

    rule = "W" if agg_type_in == "Week" else "M" if agg_type_in == "Month" else None

    if rule:
        numeric_cols = df_.select_dtypes(include="number").columns
        non_numeric_cols = df_.columns.difference(numeric_cols)
        df_numeric = df_[numeric_cols].resample(rule).sum()
        df_non_numeric = df_[non_numeric_cols].resample(rule).first()
        df_agg = pd.concat([df_numeric, df_non_numeric], axis=1).reset_index()
        return df_agg
    else:
        df_.reset_index(inplace=True)
        return df_


if agg_type in ["Week", "Month"]:
    df_filtered_curr = aggregate_data(df_filtered_curr, agg_type)
    df_filtered_prev = aggregate_data(df_filtered_prev, agg_type)

st.subheader("📊 Sales Dynamics YoY")

fig = go.Figure()

fig.add_trace(go.Scatter(
    x=df_filtered_curr["FakeDate"],
    y=df_filtered_curr["Sales (million RUB)"],
    mode='lines',
    fill='tozeroy',
    line=dict(color="blue"),
    name="Sales (current year)"
))

if show_last_year and not df_filtered_prev.empty:
    fig.add_trace(go.Scatter(
        x=df_filtered_prev["FakeDate"],
        y=df_filtered_prev["Sales (million RUB)"],
        mode='lines',
        line=dict(color="black", dash="dash"),
        name="Sales (last year)"
    ))

if not df_filtered_curr.empty:
    x_min = df_filtered_curr["FakeDate"].min()
    x_max = df_filtered_curr["FakeDate"].max()
    if show_last_year and not df_filtered_prev.empty:
        x_min = min(x_min, df_filtered_prev["FakeDate"].min())
        x_max = max(x_max, df_filtered_prev["FakeDate"].max())
else:
    x_min = datetime(2024, 1, 1)
    x_max = datetime(2024, 12, 31)

fig.update_layout(
    title="Sales vs Last Year",
    xaxis=dict(title="Date", range=[x_min, x_max]),
    yaxis=dict(title="Sales (million RUB)"),
    legend=dict(x=0, y=1.1, orientation="h"),
    hovermode="x unified",
    template="plotly_white",
    margin=dict(l=40, r=40, t=80, b=40)
)

st.plotly_chart(fig, use_container_width=True)

st.subheader("📊 Marketing Campaign Analysis")

campaign_list = pd.concat([df_filtered_curr, df_filtered_prev])["Campaign Name"].unique()
campaign_list = "No promo during this period" if campaign_list.size == 0 else campaign_list

selected_campaign = st.selectbox("Select a campaign:", campaign_list)

st.subheader("📊 Promotional Product Sales")

fig_camp = px.line(
    df_filtered_curr,
    x="Date",
    y="Promotional Sales (mln RUB)",
    color="Region",
    title=f"Promotional product sales for: {selected_campaign}",
    markers=True
)
fig_camp.update_layout(template="plotly_white")

if not df_filtered_curr.empty:
    x_min2 = df_filtered_curr["Date"].min()
    x_max2 = df_filtered_curr["Date"].max()
    fig_camp.update_xaxes(range=[x_min2, x_max2])

st.plotly_chart(fig_camp, use_container_width=True)

st.subheader("📊 Promo Code Usage")
fig_promo = px.pie(
    df_filtered_curr,
    names="Promocode",
    title="Distribution of orders with promo code",
    hole=0.3,
    color_discrete_sequence=px.colors.qualitative.Prism
)
fig_promo.update_layout(template="plotly_white")
st.plotly_chart(fig_promo, use_container_width=True)

st.subheader("📈 Conversions by Communication Channels")

mask_channels = (
        (df_channels["Date"] >= pd.to_datetime(start_date)) &
        (df_channels["Date"] <= pd.to_datetime(end_date))
)
df_channels = df_channels.loc[mask_channels].copy()

fig_channels = px.bar(
    df_channels,
    x="Channel",
    y="Conversion (%)",
    title="Conversion by channel",
    color="Channel",
    text="Conversion (%)"
)
fig_channels.update_layout(template="plotly_white")
st.plotly_chart(fig_channels, use_container_width=True)

fig_unsub = px.bar(
    df_channels,
    x="Channel",
    y="Unsubscribe (%)",
    title="Unsubscribe rate by channel",
    color="Channel",
    text="Unsubscribe (%)"
)
fig_unsub.update_layout(template="plotly_white")
st.plotly_chart(fig_unsub, use_container_width=True)

st.dataframe(df_channels.style.highlight_max(color="lightgreen"))

st.subheader("📥 Download Report")
output = df_filtered_curr.to_csv(index=False).encode("utf-8")
st.download_button("📥 Download report (CSV)", data=output, file_name="campaign_report.csv", mime="text/csv")
