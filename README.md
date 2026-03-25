# Electrical Wholesale Sales Analysis

## 📊 Project Overview
This project presents an end-to-end data analysis workflow for an electrical wholesale company.

It covers:
- database design and data modeling (Oracle SQL)
- data extraction and transformation (SQL)
- data analysis (Excel)
- interactive dashboard creation (Power BI)

The goal of the project was to analyze sales performance, identify trends and support business decision-making.

---

## Key Insights

- Sales are concentrated in selected regions, indicating geographic revenue clusters  
- Significant variation in monthly sales suggests seasonality  
- A small group of products generates the majority of revenue (Pareto effect)  
- Employee contribution to sales differs across customers  

---

## Tools & Technologies

- SQL (Oracle)
- Microsoft Excel (Pivot Tables, Power Query)
- Power BI (data visualization, dashboarding)

---

## Project Structure

/sql
/excel
/powerbi
/images



## Data Model (ERD)
The diagram below shows the initial structure of the database. Some tables and relationships were later updated during the project, but this gives a clear overview of the main entities and relationships.

![Preliminary entity relationship diagram (ERD) of the data model](images/erd_initial.png)

Notes:
- This ERD reflects the early design of the database used for SQL analysis and reporting.
- Some changes were made after this diagram, including updates to tables like sales_history, products, and purchase_history.
- Despite updates, the diagram illustrates the core structure, relationships, and logic of the data model.

---

## 📸 Dashboard Preview

### Overview
![Dashboard](images/purchase_dashboard_overview.png)

### Sales by Region
![Map](images/sales_map.png)

### Sales Trend
![Trend](images/sales_trend.png)
