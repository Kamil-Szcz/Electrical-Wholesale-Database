# Electrical Wholesale Database
## Introduction

This project encompasses the full lifecycle of data management and analysis for an electrical wholesale company. It includes:
1. Database Creation: SQL script to create the database structure.
2. Data Import: Steps to import data from Excel files into the database.
3. SQL Queries: Sample queries to extract and manipulate data.
4. Data Analysis: Conducting data analysis in Excel.
5. Data Visualization: Creating visualizations in Power BI.

## Requirements
- Oracle SQL Developer
- Oracle Database
- Microsoft Excel
- Microsoft Power BI

## Sections
### 1. Database Creation
To create the database, follow these steps:
- Open SQL Developer.
- Connect to your database instance.
- Open the file electrical_wholesale_database_script.sql.
- Run the script (F5 or Run Script) to create all required tables and structures.

### 2. Importing Data from Excel Files
After creating the database, data can be imported using the Data Import Wizard in SQL Developer:
1. Prepare the Excel Files: Ensure that the Excel files contain data corresponding to the tables in the database.
2. Launch the Data Import Wizard:
- In SQL Developer, go to the Connections tab.
- Locate and expand the connection to your database.
- Right-click on the table where you want to import the data.
- Select "Import Data...".
3. Configure the Import: Map the columns from the Excel file to the database table columns.
4. Verify the Data: Check that the data has been correctly imported.

### 3. SQL Queries
This section includes example SQL queries for:
- Data extraction
- Data aggregation
- Data transformation

### 4. Data Analysis in Excel
After extracting the necessary data using SQL queries, this section includes:
- Importing the data into Excel.
- Performing data analysis using PivotTables, formulas, and other Excel features.

### 5. Data Visualization in Power BI
Finally, the data analyzed in Excel can be visualized using Power BI. This section covers:
- Importing the data from Excel into Power BI.
- Creating dashboards and reports.
- Sharing insights and visualizations.
