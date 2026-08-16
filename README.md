# 📈 US Tariff & Trade War Impact Analysis

An end-to-end data analytics and ETL pipeline built to evaluate how US tariff policy shifts influence international trade volumes, sector-level stock volatility, and market sentiment.

---

## 📌 Project Overview
Trade wars and tariff policy changes heavily influence supply chain flows, import costs, and financial markets. This project aggregates macroeconomic trade data, tariff rates, and market indicators to measure the direct financial impact of policy decisions across key industry sectors.

### Core Objectives
* Clean, transform, and aggregate raw macroeconomic and trade dataset files using Python.
* Engineer a robust SQL database schema using Window Functions and CTEs for metrics extraction.
* Calculate key metrics (YoY trade volume shifts, weighted tariff rates, sector volatility).
* Build an executive-ready Power BI dashboard layout for dynamic visualization.

---

## 🛠 Tech Stack
* **Language:** Python 3.10+ (`pandas`, `numpy`, `sqlalchemy`)
* **Database:** PostgreSQL (Advanced SQL, CTEs, Window Functions)
* **Visualization:** Power BI (DAX metrics, Data Modeling)
* **Tools:** Git, GitHub, Jupyter Notebooks

---

## 📁 Project Structure
```text
├── data/
│   ├── raw/                 # Original CSV datasets
│   └── processed/           # Processed datasets for SQL ingestion
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   └── 02_eda_and_insights.ipynb
├── sql/
│   ├── schema.sql           # DDL table creation scripts
│   └── analytics_queries.sql# Aggregations, Window functions & KPIs
├── src/
│   └── etl_pipeline.py      # Automated Python cleaning & loading script
├── dashboards/
│   └── trade_impact.pbix    # Power BI dashboard file
├── README.md
└── requirements.txt
