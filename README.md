# 🛒 Retail Business Intelligence Pipeline

An end-to-end data engineering and analytics project featuring a robust **MySQL** backend, a **30,000+ row** retail dataset, and automated **Excel** reporting.

---

## 📌 Project Overview
This project simulates a real-world retail environment, covering the entire data lifecycle: from database schema design and data ingestion to complex SQL analytics and executive-level visualization. 

The goal is to transform 30k rows of raw transactional data into actionable business insights, such as identifying high-value customers and optimizing inventory turnover.

## 🛠️ Tech Stack & Tools
*   **Database:** MySQL (Schema Design, Constraints, Indexing)
*   **Language:** SQL (Window Functions, CTEs, Aggregations)
*   **Processing:** Python (Data cleaning & ETL)
*   **Reporting:** Microsoft Excel (Pivot Tables, Power Query, Dashboards)
*   **Dataset:** 30,000+ rows of synthetic retail transactions

## 📂 Repository Structure
```text
├── data/               # Raw and cleaned CSV datasets (30K rows)
├── sql/
│   ├── schema.sql      # Database & Table definitions
│   └── analytics.sql   # 12 Advanced business queries
├── python/             # Scripts for automated Excel export
├── reports/            # Final Excel BI Report & Dashboard
└── README.md

----

📊 Analytics & Insights
The project includes 12 specialized SQL queries designed to answer critical business questions:
Revenue Trends: Monthly and quarterly growth analysis.
Customer Segmentation: Identifying Top 10% of spenders.
Product Performance: Top-selling categories by profit margin.
Inventory Health: Tracking stock-to-sales ratios.
Churn Analysis: Detecting inactive customers over 90 days.

📈 Final Deliverables
MySQL Schema: A normalized database structure for high-performance querying.
Excel Dashboard: An interactive report featuring dynamic charts for sales performance, pivot tables, and slicers.


🚀 How to Run
Clone the repo:
bash
git clone https://github.com
Use code with caution.

Setup Database: Import sql/schema.sql into your MySQL instance.
Run Analytics: Execute sql/analytics.sql to generate insights.
View Report: Open reports/retail_bi_report.xlsx to see the visualized data.
