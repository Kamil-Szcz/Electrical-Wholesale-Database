# Electrical Wholesale Database
Introduction
This project contains a SQL script to create a database for an electrical wholesale company. After setting up the database structure, data can be imported from Excel files using the Data Import Wizard in SQL Developer.

# Requirements
Oracle SQL Developer
Excel

# Instructions
1. Creating the Database
To create the database, follow these steps:
- Open SQL Developer.
- Connect to your database instance.
- Open the file electrical_wholesale_database_script.sql.
- Run the script (F5 or Run Script) to create all required tables and structures.
2. Importing Data from Excel Files
Once the database structure is created, data can be imported from Excel files using the Data Import Wizard in SQL Developer:
- Prepare the Excel Files: Ensure that the Excel files contain data corresponding to the tables in the database.
- Launching the Data Import Wizard:
    In SQL Developer, go to the Connections tab.
    Locate and expand the connection to your database.
    Right-click on the table where you want to import the data.
    Select Import Data....
    Configuring the Import:

Select the Excel file to import.
In the import configuration window, map the columns from the Excel file to the columns in the database table.
Proceed through the rest of the wizard, ensuring all steps are correctly configured.
Click Finish to start the import.
Verifying the Data:

After the import is complete, check that the data has been correctly imported into the table.
You can modify this template according to your specific needs or add any additional details that might be necessary for your project.
