--This script (electrical_wholesale_database_script.sql) performs the following operations:
-- 1. Creates the user electrical_wholesale
-- 2. Creates the database tables
-- 3. Creates PL/SQL code
-- 4. Fills the database tables with sample data

-- Delete user electrical_wholesale (may return an error message if the user does not yet exist)
DROP USER electrical_wholesale CASCADE;
-- Create user electrical_wholesale with password who2500
CREATE USER electrical_wholesale IDENTIFIED BY who2500;
-- Granting permission to the electrical_wholesale user to connect to the database and create objects
GRANT connect, resource TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create sessions
GRANT CREATE SESSION TO electrical_wholesale;
-- Assigning the electrical_wholesale user an unlimited tablespace
GRANT UNLIMITED TABLESPACE TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create tables
GRANT CREATE TABLE TO electrical_wholesale;
-- Giving electrical_wholesale user permission to create sequences
GRANT CREATE SEQUENCE TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create views
GRANT CREATE VIEW TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create procedures
GRANT CREATE PROCEDURE TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create triggers
GRANT CREATE TRIGGER TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to execute the DBMS_SCHEDULER package
GRANT EXECUTE ON DBMS_SCHEDULER TO electrical_wholesale;
-- Granting the electrical_wholesale user permission to create jobs
GRANT CREATE JOB TO electrical_wholesale;


-- Creating tables
CREATE TABLE customers 
(
    customer_id         INTEGER NOT NULL
    , customer_name     VARCHAR2(500) NOT NULL
    , location_id       INTEGER NOT NULL
    , vat_number        VARCHAR2(17 BYTE) NOT NULL
);

CREATE UNIQUE INDEX un_customers_vat_number ON customers
(
    vat_number ASC
);
	
ALTER TABLE customers ADD CONSTRAINT customers_pk PRIMARY KEY (customer_id);


CREATE TABLE departments 
(
    department_id       INTEGER NOT NULL
    , department_name   VARCHAR2(30) NOT NULL
    , manager_id        INTEGER NOT NULL
);

ALTER TABLE departments ADD CONSTRAINT departments_pk PRIMARY KEY (department_id);


CREATE TABLE employees 
(
    employee_id         INTEGER NOT NULL
    , first_name        VARCHAR2(75) NOT NULL
    , middle_name       VARCHAR2(75)
    , last_name         VARCHAR2(75) NOT NULL
    , gender            VARCHAR2(11) NOT NULL
    , birthdate         DATE NOT NULL
    , citizenship       VARCHAR2(50 BYTE) NOT NULL
    , pesel             VARCHAR2(11 BYTE)
    , email             VARCHAR2(500) NOT NULL
    , phone_number      VARCHAR2(9 BYTE) NOT NULL
    , location_id       INTEGER NOT NULL
    , job_id            INTEGER NOT NULL
    , hire_date         DATE NOT NULL
    , salary            NUMBER(38, 2) NOT NULL
    , manager_id        INTEGER NOT NULL
    , department_id     INTEGER NOT NULL
);

ALTER TABLE employees ADD CONSTRAINT ch_employees_first_name 
CHECK (REGEXP_LIKE (first_name, '^[[:alpha:]]+$'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_middle_name 
CHECK (REGEXP_LIKE (middle_name, '^[[:alpha:]]+$'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_last_name 
CHECK (REGEXP_LIKE (last_name, '^[[:alpha:]]+$'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_gender 
CHECK (gender IN ('kobieta', 'mężczyzna'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_citizenship 
CHECK (substr(citizenship, -3) = 'kie');

ALTER TABLE employees ADD CONSTRAINT ch_employees_pesel_for_polish 
CHECK 
(
(pesel IS NOT NULL AND citizenship LIKE 'polskie') OR (pesel IS NULL AND citizenship NOT LIKE 'polskie')
);

ALTER TABLE employees ADD CONSTRAINT ch_employees_email 
CHECK (REGEXP_LIKE (email, '.+@.+\..+'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_phone_number 
CHECK (REGEXP_LIKE (phone_number, '^[0-9]+$'));

ALTER TABLE employees ADD CONSTRAINT ch_employees_min_salary 
CHECK (salary > 0);

CREATE UNIQUE INDEX un_phone_number ON employees
(
    phone_number ASC 
);

CREATE UNIQUE INDEX un_email ON employees 
(
    email ASC 
);

CREATE UNIQUE INDEX un_pesel ON employees 
(
    pesel ASC 
);

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY (employee_id);


CREATE TABLE job_history 
(
    event_date          DATE DEFAULT ON NULL sysdate NOT NULL
    , event_type        CHAR(6 BYTE) NOT NULL
    , employee_id       INTEGER NOT NULL
    , start_date        DATE
    , end_date          DATE
    , old_first_name    NVARCHAR2(75)
    , old_middle_name   NVARCHAR2(75)
    , old_last_name     NVARCHAR2(75)
    , old_gender        VARCHAR2(9 CHAR)
    , old_citizenship   VARCHAR2(50 BYTE)
    , old_email         NVARCHAR2(500)
    , old_phone_number  VARCHAR2(9 BYTE)
    , old_location_id   INTEGER
    , old_job_id        INTEGER
    , old_salary        NUMBER(38, 2)
    , old_manager_id    INTEGER
    , old_department_id INTEGER
    , new_first_name    NVARCHAR2(75)
    , new_middle_name   NVARCHAR2(75)
    , new_last_name     NVARCHAR2(75)
    , new_gender        VARCHAR2(9 CHAR)
    , new_citizenship   VARCHAR2(50 BYTE)
    , new_email         NVARCHAR2(500)
    , new_phone_number  VARCHAR2(9 BYTE)
    , new_location_id   INTEGER
    , new_job_id        INTEGER
    , new_salary        NUMBER(38, 2)
    , new_manager_id    INTEGER
    , new_department_id INTEGER
);

ALTER TABLE job_history
ADD CHECK (event_type IN ('Delete', 'Insert', 'Update'));

ALTER TABLE job_history ADD CONSTRAINT ch_job_history_end_date 
CHECK (end_date >= start_date);

ALTER TABLE job_history ADD CONSTRAINT job_history_pk PRIMARY KEY (employee_id, event_date);
																	

CREATE TABLE jobs 
(
    job_id          	INTEGER NOT NULL
    , job_title     	VARCHAR2(100 BYTE) NOT NULL
    , min_salary    	NUMBER(38, 2) NOT NULL
    , max_salary    	NUMBER(38, 2) NOT NULL
);

ALTER TABLE jobs ADD CONSTRAINT ch_jobs_min_salary 
CHECK (min_salary > 0);

ALTER TABLE jobs ADD CONSTRAINT ch_jobs_max_salary 
CHECK (max_salary >= min_salary);

ALTER TABLE jobs ADD CONSTRAINT jobs_pk PRIMARY KEY (job_id);


CREATE TABLE locations 
(
    location_id         INTEGER NOT NULL
    , city              VARCHAR2(100 BYTE) NOT NULL
    , street_name       VARCHAR2(100 BYTE) NOT NULL
    , property_number   VARCHAR2(6 BYTE) NOT NULL
    , postal_code       VARCHAR2(6) NOT NULL
    , voivodeship       INTEGER NOT NULL
);

ALTER TABLE locations ADD CONSTRAINT ch_locations_postal_code 
CHECK (REGEXP_LIKE (postal_code, '^[0-9]{2}-[0-9]{3}$'));

ALTER TABLE locations ADD CONSTRAINT locations_pk PRIMARY KEY (location_id);


CREATE TABLE product_ranges 
(
    product_range_id            INTEGER NOT NULL
    , product_range_name        VARCHAR2(200 CHAR) NOT NULL
    , product_range_description VARCHAR2(4000 CHAR)
);

CREATE UNIQUE INDEX un_range_name ON product_ranges 
(
    product_range_name ASC 
);

ALTER TABLE product_ranges ADD CONSTRAINT product_ranges_pk PRIMARY KEY (product_range_id);  


CREATE TABLE products 
(
    product_id              VARCHAR2(30 BYTE) NOT NULL
    , range_id              INTEGER NOT NULL
    , product_description   VARCHAR2(500 CHAR)
    , net_purchase_price    NUMBER(38, 2) NOT NULL
    , net_sale_price        NUMBER(38, 2) NOT NULL
    , vat_rate              INTEGER DEFAULT ON NULL 23 NOT NULL
    , quantity_in_stock     INTEGER DEFAULT ON NULL 0 NOT NULL
    , sales_status          VARCHAR2(1 BYTE) DEFAULT ON NULL 'A' NOT NULL
    , delivery_time         INTEGER NOT NULL
    , gtin_code             VARCHAR2(13 BYTE) NOT NULL
);

ALTER TABLE products ADD CONSTRAINT ch_products_vat_rate 
CHECK (vat_rate IN (0, 4, 5, 7, 8, 23));

ALTER TABLE products ADD CONSTRAINT ch_products_quantity_in_stock 
CHECK (quantity_in_stock >= 0);

ALTER TABLE products ADD CONSTRAINT ch_products_sales_status 
CHECK (sales_status IN ('A', 'I'));

CREATE UNIQUE INDEX un_gtin_code ON products 
(
    gtin_code ASC 
);

ALTER TABLE products ADD CONSTRAINT products_pk PRIMARY KEY (product_id);


CREATE TABLE purchase_history 
(
    purchase_id     	INTEGER NOT NULL
    , supplier_id   	INTEGER NOT NULL
    , orderer       	INTEGER NOT NULL
    , purchase_date 	DATE DEFAULT ON NULL sysdate NOT NULL
);

ALTER TABLE purchase_history ADD CONSTRAINT purchase_history_pk PRIMARY KEY (purchase_id);


CREATE TABLE sales_history 
(
    sales_id        	INTEGER NOT NULL
    , customer_id   	INTEGER NOT NULL
    , seller        	INTEGER NOT NULL
    , sale_date     	DATE DEFAULT ON NULL sysdate NOT NULL
);

ALTER TABLE sales_history ADD CONSTRAINT sales_history_pk PRIMARY KEY (sales_id);


CREATE TABLE suppliers 
(
    supplier_id         INTEGER NOT NULL
    , supplier_name     NVARCHAR2(500) NOT NULL
    , location_id       INTEGER NOT NULL
    , vat_number        VARCHAR2(17 BYTE) NOT NULL
    , bank_account      VARCHAR2(26 BYTE) NOT NULL
);

CREATE UNIQUE INDEX un_bank_account ON suppliers 
(
    bank_account ASC 
);

CREATE UNIQUE INDEX un_suppliers_vat_number ON suppliers 
(
    vat_number ASC 
);

ALTER TABLE suppliers ADD CONSTRAINT suppliers_pk PRIMARY KEY (supplier_id);


CREATE TABLE voivodeships 
(
    voivodeship_id   INTEGER NOT NULL
    , voivodeship_name VARCHAR2(25 BYTE) NOT NULL
);

ALTER TABLE voivodeships ADD CONSTRAINT ch_voivodeships_voivodeship_name
CHECK (REGEXP_LIKE(voivodeship_name, '^[A-Za-z[:punct:]]+$'));

ALTER TABLE voivodeships ADD CONSTRAINT voivodeships_pk PRIMARY KEY (voivodeship_id);


CREATE TABLE sales_items 
(
    sales_id        INTEGER NOT NULL
    , product_id    VARCHAR2(30 BYTE) NOT NULL
    , quantity      INTEGER NOT NULL
);

ALTER TABLE sales_items ADD CONSTRAINT sales_items_pk PRIMARY KEY ( sales_id, product_id );


CREATE TABLE shopping_items 
(
    purchase_id     INTEGER NOT NULL
    , product_id    VARCHAR2(30 BYTE) NOT NULL
    , quantity      INTEGER NOT NULL
);

ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_pk PRIMARY KEY (purchase_id, product_id);


ALTER TABLE customers ADD CONSTRAINT customers_fk_locations 
FOREIGN KEY (location_id) REFERENCES locations (location_id);


ALTER TABLE departments ADD CONSTRAINT departments_fk_manager 
FOREIGN KEY (manager_id) REFERENCES employees (employee_id);


ALTER TABLE employees ADD CONSTRAINT employees_fk_departments 
FOREIGN KEY (department_id) REFERENCES departments (department_id);

ALTER TABLE employees ADD CONSTRAINT employees_fk_jobs
FOREIGN KEY (job_id) REFERENCES jobs (job_id);

ALTER TABLE employees ADD CONSTRAINT employees_fk_locations 
FOREIGN KEY (location_id) REFERENCES locations (location_id);


ALTER TABLE sales_items ADD CONSTRAINT sales_items_fk_products 
FOREIGN KEY (product_id) REFERENCES products (product_id);

ALTER TABLE sales_items ADD CONSTRAINT sales_items_fk_sales_history 
FOREIGN KEY (sales_id) REFERENCES sales_history (sales_id)
ON DELETE CASCADE;

        
ALTER TABLE job_history ADD CONSTRAINT job_history_fk_departments_new 
FOREIGN KEY (new_department_id) REFERENCES departments (department_id);

ALTER TABLE job_history ADD CONSTRAINT job_history_fk_departments_old 
FOREIGN KEY (old_department_id) REFERENCES departments (department_id);

ALTER TABLE job_history ADD CONSTRAINT job_history_fk_employees 
FOREIGN KEY (employee_id) REFERENCES employees (employee_id);

ALTER TABLE job_history ADD CONSTRAINT job_history_fk_jobs_new 
FOREIGN KEY (new_job_id) REFERENCES jobs (job_id);

ALTER TABLE job_history ADD CONSTRAINT job_history_fk_jobs_old 
FOREIGN KEY (old_job_id) REFERENCES jobs (job_id);


ALTER TABLE locations ADD CONSTRAINT locations_fk_voivodeships 
FOREIGN KEY (voivodeship) REFERENCES voivodeships (voivodeship_id);


ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_fk_purchase_history 
FOREIGN KEY (purchase_id) REFERENCES purchase_history (purchase_id)
ON DELETE CASCADE;

ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_fk_products 
FOREIGN KEY (product_id) REFERENCES products (product_id);


ALTER TABLE products ADD CONSTRAINT products_fk_product_ranges 
FOREIGN KEY (range_id) REFERENCES product_ranges (product_range_id);


ALTER TABLE purchase_history ADD CONSTRAINT purchase_history_fk_employees 
FOREIGN KEY (orderer) REFERENCES employees (employee_id);

ALTER TABLE purchase_history ADD CONSTRAINT purchase_history_fk_suppliers 
FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id);


ALTER TABLE sales_history ADD CONSTRAINT sales_history_fk_customers 
FOREIGN KEY (customer_id) REFERENCES customers (customer_id);

ALTER TABLE sales_history ADD CONSTRAINT sales_history_fk_employees 
FOREIGN KEY (seller) REFERENCES employees (employee_id);


ALTER TABLE suppliers ADD CONSTRAINT suppliers_fk_locations 
FOREIGN KEY (location_id) REFERENCES locations (location_id);


--Tworzenie wyzwalaczy
CREATE OR REPLACE TRIGGER BIU_EMP_CITIZENSHIP_TGR
BEFORE INSERT OR UPDATE ON electrical_wholesale.employees
FOR EACH ROW
BEGIN
    :NEW.citizenship := LOWER(SUBSTR(:NEW.citizenship, 1, 1)) || SUBSTR(:NEW.citizenship, 2);
END;
/


CREATE OR REPLACE TRIGGER BIU_EMP_FIRST_NAME_TGR
BEFORE INSERT OR UPDATE ON electrical_wholesale.employees
FOR EACH ROW
BEGIN
    :NEW.first_name := UPPER(SUBSTR(:NEW.first_name, 1, 1)) || SUBSTR(:NEW.first_name, 2);
END;
/


CREATE OR REPLACE TRIGGER BIU_EMP_MIDDLE_NAME_TGR
BEFORE INSERT OR UPDATE ON electrical_wholesale.employees
FOR EACH ROW
BEGIN
    :NEW.middle_name := UPPER(SUBSTR(:NEW.middle_name, 1, 1)) || SUBSTR(:NEW.middle_name, 2);
END;
/


CREATE OR REPLACE TRIGGER BIU_EMP_LAST_NAME_TGR
BEFORE INSERT OR UPDATE ON electrical_wholesale.employees
FOR EACH ROW
BEGIN
    :NEW.last_name := UPPER(SUBSTR(:NEW.last_name, 1, 1)) || SUBSTR(:NEW.last_name, 2);
END;
/


CREATE OR REPLACE TRIGGER ADIU_JOB_HIST_ARCHIVE_TGR
AFTER INSERT OR UPDATE OR DELETE ON electrical_wholesale.employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO job_history
            ( event_date        
            , event_type        
            , employee_id       
            , start_date        
            , end_date          
            , old_first_name    
            , old_middle_name   
            , old_last_name     
            , old_gender        
            , old_citizenship   
            , old_email        
            , old_phone_number  
            , old_location_id   
            , old_job_id        
            , old_salary        
            , old_manager_id    
            , old_department_id 
            , new_first_name    
            , new_middle_name   
            , new_last_name     
            , new_gender        
            , new_citizenship   
            , new_email         
            , new_phone_number  
            , new_location_id  
            , new_job_id        
            , new_salary       
            , new_manager_id    
            , new_department_id
			)
        VALUES
			( SYSDATE
			, 'Insert'
            , :NEW.employee_id
            , :NEW.hire_date        
            , NULL          
            , NULL    
            , NULL   
            , NULL     
            , NULL        
            , NULL   
            , NULL        
            , NULL  
            , NULL   
            , NULL        
            , NULL        
            , NULL    
            , NULL 
            , :NEW.first_name    
            , :NEW.middle_name   
            , :NEW.last_name     
            , :NEW.gender        
            , :NEW.citizenship   
            , :NEW.email         
            , :NEW.phone_number  
            , :NEW.location_id  
            , :NEW.job_id        
            , :NEW.salary       
            , :NEW.manager_id    
            , :NEW.department_id
            );
    ELSIF UPDATING THEN
        INSERT INTO job_history
            ( event_date        
            , event_type        
            , employee_id       
            , start_date        
            , end_date          
            , old_first_name    
            , old_middle_name   
            , old_last_name     
            , old_gender        
            , old_citizenship   
            , old_email        
            , old_phone_number  
            , old_location_id   
            , old_job_id        
            , old_salary        
            , old_manager_id    
            , old_department_id 
            , new_first_name    
            , new_middle_name   
            , new_last_name     
            , new_gender        
            , new_citizenship   
            , new_email         
            , new_phone_number  
            , new_location_id  
            , new_job_id        
            , new_salary       
            , new_manager_id    
            , new_department_id
			)
        VALUES
			( SYSDATE
			, 'Update'
            , :OLD.employee_id
            , NULL        
            , NULL          
            , :OLD.first_name    
            , :OLD.middle_name   
            , :OLD.last_name     
            , :OLD.gender        
            , :OLD.citizenship   
            , :OLD.email         
            , :OLD.phone_number  
            , :OLD.location_id  
            , :OLD.job_id        
            , :OLD.salary       
            , :OLD.manager_id    
            , :OLD.department_id
            , :NEW.first_name    
            , :NEW.middle_name   
            , :NEW.last_name     
            , :NEW.gender        
            , :NEW.citizenship   
            , :NEW.email         
            , :NEW.phone_number  
            , :NEW.location_id  
            , :NEW.job_id        
            , :NEW.salary       
            , :NEW.manager_id    
            , :NEW.department_id
            );
    ELSE
        INSERT INTO job_history
            ( event_date        
            , event_type        
            , employee_id       
            , start_date        
            , end_date          
            , old_first_name    
            , old_middle_name   
            , old_last_name     
            , old_gender        
            , old_citizenship   
            , old_email        
            , old_phone_number  
            , old_location_id   
            , old_job_id        
            , old_salary        
            , old_manager_id    
            , old_department_id 
            , new_first_name    
            , new_middle_name   
            , new_last_name     
            , new_gender        
            , new_citizenship   
            , new_email         
            , new_phone_number  
            , new_location_id  
            , new_job_id        
            , new_salary       
            , new_manager_id    
            , new_department_id
			)
        VALUES
			( SYSDATE
			, 'Delete'
            , :OLD.employee_id
            , NULL        
            , SYSDATE          
            , :OLD.first_name    
            , :OLD.middle_name   
            , :OLD.last_name     
            , :OLD.gender        
            , :OLD.citizenship   
            , :OLD.email         
            , :OLD.phone_number  
            , :OLD.location_id  
            , :OLD.job_id        
            , :OLD.salary       
            , :OLD.manager_id    
            , :OLD.department_id
            , NULL    
            , NULL  
            , NULL    
            , NULL        
            , NULL   
            , NULL       
            , NULL  
            , NULL 
            , NULL        
            , NULL      
            , NULL   
            , NULL
            );
        END IF;
END;
/


-- Adding data to the table “voivodeships”
INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 1
	, 'dolnośląskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 2
	, 'kujawsko-pomorskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 3
	, 'lubelskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 4
	, 'lubuskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 5
	, 'łódzkie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 6
	, 'małopolskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 7
	, 'mazowieckie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 8
	, 'opolskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 9
	, 'podkarpackie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES
	( 10
	, 'podlaskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 11
	, 'pomorskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 12
	, 'śląskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 13
	, 'świętokrzyskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 14
	, 'warmińsko-mazurskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 15
	, 'wielkopolskie'
	);

INSERT INTO voivodeships (voivodeship_id, voivodeship_name) VALUES 
	( 16
	, 'zachodniopomorskie'
	);


-- Creating a trigger to preventing modification of data in the “voivodeships” table
CREATE OR REPLACE TRIGGER BDIU_VOIV_PREVENT_DATA_MODIFICATION_TGR
BEFORE INSERT OR UPDATE OR DELETE ON voivodeships
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Modyfikowanie danych w tabeli voivodeships jest zabronione.');
END;
/


-- Data to the “product_ranges” table was added using Data Import Wizard, using the file “product_ranges.xlsx”


-- Data to the “products” table was added using Data Import Wizard, using the file “price_list.xlsx”


-- Adding data to the “jobs” table
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 1
	, 'General Manager'
	, 25000
	, 50000
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES 
	( 2
	, 'Sales Manager'
	, 20000
	, 35000
	);

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 3  
	, 'Chief Accountant'  
	, 15000  
	, 30000  
	);  
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 4 
	, 'HR Manager'  
	, 15000  
	, 30000  
	); 
 
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 5 
	, 'Head Of Purchasing'  
	, 20000  
	, 35000  
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 6  
	, 'Logistics Manager'  
	, 20000  
	, 35000  
	);  

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 7 
	, 'Sales Analyst'  
	, 15000  
	, 30000  
	);  

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES   
	( 8  
	, 'Internet Marketing Specialist'  
	, 7500  
	, 15000  
	);  
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 9  
	, 'Accountant'  
	, 7500  
	, 15000  
	);  

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 10  
	, 'HR Specialist'  
	, 7500  
	, 15000  
	);   

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 11  
	, 'Warehouse Manager'  
	, 15000  
	, 30000  
	); 

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 12  
	, 'Sales Representative'  
	, 10000  
	, 20000  
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 13  
	, 'Customer Service Specialist'  
	, 5000  
	, 10000  
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 14  
	, 'Health and Safety Specialist'  
	, 10000  
	, 15000  
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 15  
	, 'Buyer'  
	, 10000  
	, 20000  
	); 
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 16  
	, 'Logistics Specialist'  
	, 10000  
	, 20000  
	);
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 17 
	, 'Warehouse Worker'  
	, 5000  
	, 10000  
	);
		
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 18 
	, 'Service Technician'  
	, 7500  
	, 15000  
	);

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 19  
	, 'Office Assistant'  
	, 5000  
	, 10000 
	);		

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES      
	( 20  
	, 'Foreperson'  
	, 10000  
	, 15000 
	);	

	
-- Disabling integrity constraint for “employees” to load data
ALTER TABLE departments
	DISABLE CONSTRAINT departments_fk_manager;

	
-- Adding data to the “departments” table
INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 1  
	, 'Administration'  
	, 1
	); 

INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 2  
	, 'Sales'  
	, 2
	); 
	
INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 3  
	, 'Finance'  
	, 3
	); 
	
INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 4  
	, 'Human Resources'  
	, 4
	); 

INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 5  
	, 'Purchasing'  
	, 5
	);

INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 6  
	, 'Logistic'  
	, 6
	);
	
INSERT INTO departments (department_id, department_name, manager_id) VALUES   
	( 7  
	, 'Storage'  
	, 7
	);
	

-- Disabling integrity constraint for “locations” to load data
ALTER TABLE employees
	DISABLE CONSTRAINT employees_fk_locations;

		
-- Adding data to the “employees” table
INSERT INTO employees (employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 1
    , 'Dariusz'
    , NULL
    , 'Szczygielski'
    , 'mężczyzna'
    , TO_DATE('27-03-1960', 'DD-MM-RRRR')
    , 'polskie'
    , '60032734175'
    , 'dariusz60@wp.pl'
    , '485635320'
    , 2
    , 1
    , TO_DATE('01-04-2000', 'DD-MM-RRRR')
    , 40000.00
    , 1
    , 1
    );

INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 2
    , 'Mariusz'
    , NULL
    , 'Zajezdny'
    , 'mężczyzna'
    , TO_DATE('21-12-1976', 'DD-MM-RRRR')
    , 'polskie'
    , '76122173375'
    , 'mariusz.1976@wp.pl'
    , '970313554'
    , 3
    , 2
    , TO_DATE('01-06-2000', 'DD-MM-RRRR')
    , 20000.00
    , 1
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 3
    , 'Jarosław'
    , 'Maria'
    , 'Dobroń'
    , 'mężczyzna'
    , TO_DATE('11-12-1963', 'DD-MM-RRRR')
    , 'polskie'
    , '63121183379'
    , 'jaroslaw.m.dobron@onet.pl'
    , '929994304'
    , 4
    , 3
    , TO_DATE('01-07-2000', 'DD-MM-RRRR')
    , 25000.00
    , 1
    , 3
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 4
    , 'Ewa'
    , NULL
    , 'Dobroń'
    , 'kobieta'
    , TO_DATE('18-02-1965', 'DD-MM-RRRR')
    , 'polskie'
    , '65021874261'
    , 'ewa.dobron@onet.pl'
    , '103649227'
    , 4
    , 4
    , TO_DATE('01-04-2000', 'DD-MM-RRRR')
    , 20000.00
    , 1
    , 4
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 5
    , 'Andrzej'
    , NULL
    , 'Kret'
    , 'mężczyzna'
    , TO_DATE('31-12-1967', 'DD-MM-RRRR')
    , 'polskie'
    , '67123146734'
    , 'kret_andrzej@wp.pl'
    , '961490871'
    , 5
    , 5
    , TO_DATE('10-04-2000', 'DD-MM-RRRR')
    , 30000.00
    , 1
    , 5
    );

INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 6
    , 'Kasjusz'
    , NULL
    , 'Marcoń'
    , 'mężczyzna'
    , TO_DATE('22-11-1990', 'DD-MM-RRRR')
    , 'polskie'
    , '90112231656'
    , 'kasjusz.marcon@wp.pl'
    , '906443134'
    , 6
    , 6
    , TO_DATE('01-04-2001', 'DD-MM-RRRR')
    , 30000.00
    , 1
    , 6
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 7
    , 'Adam'
    , NULL
    , 'Jonasz'
    , 'mężczyzna'
    , TO_DATE('16-07-1977', 'DD-MM-RRRR')
    , 'polskie'
    , '77071664392'
    , 'a.jonasz@wp.pl'
    , '967472472'
    , 7
    , 11
    , TO_DATE('10-04-2000', 'DD-MM-RRRR')
    , 30000.00
    , 1
    , 7
    );

INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 8
    , 'Kamil'
    , NULL
    , 'Szczygielski'
    , 'mężczyzna'
    , TO_DATE('23-06-1993', 'DD-MM-RRRR')
    , 'polskie'
    , '93062314392'
    , 'k.szczygiel@wp.pl'
    , '500923949'
    , 8
    , 7
    , TO_DATE('01-04-2020', 'DD-MM-RRRR')
    , 20000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 9
    , 'Emil'
    , NULL
    , 'Matusiak'
    , 'mężczyzna'
    , TO_DATE('06-08-1970', 'DD-MM-RRRR')
    , 'polskie'
    , '70080658754'
    , 'emil.matusiak@wp.pl'
    , '658588489'
    , 9
    , 8
    , TO_DATE('01-04-2020', 'DD-MM-RRRR')
    , 10000.00
    , 1
    , 1
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 10
    , 'Anna'
    , 'Julia'
    , 'Rolniak'
    , 'kobieta'
    , TO_DATE('29-01-1994', 'DD-MM-RRRR')
    , 'polskie'
    , '94012951588'
    , 'anna.rolniak@gmail.com'
    , '640364698'
    , 10
    , 9
    , TO_DATE('01-09-2016', 'DD-MM-RRRR')
    , 10000.00
    , 3
    , 3
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 11
    , 'Julia'
    , NULL
    , 'Kamińska'
    , 'kobieta'
    , TO_DATE('27-08-1997', 'DD-MM-RRRR')
    , 'polskie'
    , '97082752323'
    , 'j.kaminska@onet.pl'
    , '535077188'
    , 11
    , 10
    , TO_DATE('01-09-2020', 'DD-MM-RRRR')
    , 10000.00
    , 4
    , 4
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 12
    , 'Sylwia'
    , NULL
    , 'Antciuk'
    , 'kobieta'
    , TO_DATE('13-05-1990', 'DD-MM-RRRR')
    , 'polskie'
    , '90051376485'
    , 'sylwia.antciuk@onet.pl'
    , '730412058'
    , 12
    , 10
    , TO_DATE('01-10-2021', 'DD-MM-RRRR')
    , 9000.00
    , 4
    , 4
    );

INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 13
    , 'Marcin'
    , NULL
    , 'Lobo'
    , 'mężczyzna'
    , TO_DATE('20-02-1978', 'DD-MM-RRRR')
    , 'polskie'
    , '78022015694'
    , 'm.lobo@wp.pl'
    , '967820974'
    , 13
    , 12
    , TO_DATE('01-10-2021', 'DD-MM-RRRR')
    , 15000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 14
    , 'Kamil'
    , NULL
    , 'Piniewski'
    , 'mężczyzna'
    , TO_DATE('01-09-1990', 'DD-MM-RRRR')
    , 'polskie'
    , '90090155335'
    , 'piniewski90@wp.pl'
    , '931557275'
    , 14
    , 12
    , TO_DATE('01-09-2014', 'DD-MM-RRRR')
    , 17000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 15
    , 'Jan'
    , 'Paweł'
    , 'Farel'
    , 'mężczyzna'
    , TO_DATE('30-08-1985', 'DD-MM-RRRR')
    , 'polskie'
    , '85083068992'
    , 'farel-jtpzd@wp.pl'
    , '986658704'
    , 15
    , 12
    , TO_DATE('20-06-2010', 'DD-MM-RRRR')
    , 20000.00
    , 2
    , 2
    );
		
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 16
    , 'Jonasz'
    , NULL
    , 'Olkiewicz'
    , 'mężczyzna'
    , TO_DATE('13-03-2003', 'DD-MM-RRRR')
    , 'polskie'
    , '03301323153'
    , 'jonasz.o@wp.pl'
    , '706679456'
    , 16
    , 12
    , TO_DATE('01-01-2023', 'DD-MM-RRRR')
    , 10000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 17
    , 'Marcin'
    , NULL
    , 'Czynsz'
    , 'mężczyzna'
    , TO_DATE('31-12-1997', 'DD-MM-RRRR')
    , 'polskie'
    , '97123117696'
    , 'marcin_czynsz@wp.pl'
    , '900036856'
    , 17
    , 13
    , TO_DATE('01-01-2023', 'DD-MM-RRRR')
    , 10000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 18
    , 'Ewelina'
    , 'Ewa'
    , 'Sochacka'
    , 'kobieta'
    , TO_DATE('21-09-1999', 'DD-MM-RRRR')
    , 'polskie'
    , '99092129249'
    , 'e.e.sochacka@wp.pl'
    , '932481139'
    , 18
    , 13
    , TO_DATE('01-01-2023', 'DD-MM-RRRR')
    , 10000.00
    , 2
    , 2
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 19
    , 'Bogusław'
    , NULL
    , 'Ślizło'
    , 'mężczyzna'
    , TO_DATE('28-12-1964', 'DD-MM-RRRR')
    , 'polskie'
    , '64122849293'
    , 'bogus1964@onet.pl'
    , '668959863'
    , 19
    , 14
    , TO_DATE('01-01-2023', 'DD-MM-RRRR')
    , 12000.00
    , 4
    , 4
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 20
    , 'Mariusz'
    , NULL
    , 'Mameja'
    , 'mężczyzna'
    , TO_DATE('22-08-1992', 'DD-MM-RRRR')
    , 'polskie'
    , '92082246935'
    , 'mameja.mariusz@onet.pl'
    , '976887844'
    , 20
    , 15
    , TO_DATE('01-04-2018', 'DD-MM-RRRR')
    , 15000.00
    , 5
    , 5
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 21
    , 'Jan'
    , NULL
    , 'Zubrzycki'
    , 'mężczyzna'
    , TO_DATE('01-03-1988', 'DD-MM-RRRR')
    , 'polskie'
    , '88030126451'
    , 'j.zubrzycki@onet.pl'
    , '576900951'
    , 21
    , 15
    , TO_DATE('01-03-2010', 'DD-MM-RRRR')
    , 20000.00
    , 5
    , 5
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 22
    , 'Marcin'
    , NULL
    , 'Grzywacz'
    , 'mężczyzna'
    , TO_DATE('10-04-1987', 'DD-MM-RRRR')
    , 'polskie'
    , '87041083636'
    , 'grzywa@wp.pl'
    , '510438708'
    , 22
    , 15
    , TO_DATE('01-10-2020', 'DD-MM-RRRR')
    , 18000.00
    , 5
    , 5
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 23
    , 'Kamil'
    , NULL
    , 'Kopeć'
    , 'mężczyzna'
    , TO_DATE('03-10-1989', 'DD-MM-RRRR')
    , 'polskie'
    , '89100319476'
    , 'kamil.kopec@wp.pl'
    , '965090697'
    , 23
    , 16
    , TO_DATE('04-05-2019', 'DD-MM-RRRR')
    , 15000.00
    , 6
    , 6
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 24
    , 'Ilia'
    , NULL
    , 'Kowalenko'
    , 'mężczyzna'
    , TO_DATE('07-11-1999', 'DD-MM-RRRR')
    , 'ukraińskie'
    , NULL
    , 'ilia_kowal@proton.ua'
    , '782264248'
    , 24
    , 17
    , TO_DATE('04-05-2019', 'DD-MM-RRRR')
    , 7000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 25
    , 'Marcin'
    , NULL
    , 'Pucyk'
    , 'mężczyzna'
    , TO_DATE('26-08-1996', 'DD-MM-RRRR')
    , 'polskie'
    , '96082697456'
    , 'marcin.pucyk@wp.pl'
    , '978485888'
    , 25
    , 17
    , TO_DATE('04-05-2018', 'DD-MM-RRRR')
    , 9000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 26
    , 'Przemysław'
    , NULL
    , 'Wiącek'
    , 'mężczyzna'
    , TO_DATE('05-07-1993', 'DD-MM-RRRR')
    , 'polskie'
    , '93070599918'
    , 'wiacek.p@wp.pl'
    , '972276573'
    , 26
    , 17
    , TO_DATE('01-10-2016', 'DD-MM-RRRR')
    , 10000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 27
    , 'Arkadiusz'
    , NULL
    , 'Celej'
    , 'mężczyzna'
    , TO_DATE('01-11-1992', 'DD-MM-RRRR')
    , 'polskie'
    , '92110142611'
    , 'celej.arek@onet.pl'
    , '804467840'
    , 27
    , 17
    , TO_DATE('01-10-2015', 'DD-MM-RRRR')
    , 10000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 28
    , 'Jakub'
    , NULL
    , 'Przeworski'
    , 'mężczyzna'
    , TO_DATE('29-04-1996', 'DD-MM-RRRR')
    , 'polskie'
    , '96042943157'
    , 'kuba_96@onet.pl'
    , '935533615'
    , 28
    , 17
    , TO_DATE('01-01-2024', 'DD-MM-RRRR')
    , 5000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 29
    , 'Michał'
    , NULL
    , 'Kosa'
    , 'mężczyzna'
    , TO_DATE('18-07-1985', 'DD-MM-RRRR')
    , 'polskie'
    , '85071864773'
    , 'michal.kosa@wp.pl'
    , '935533616'
    , 29
    , 18
    , TO_DATE('10-02-2018', 'DD-MM-RRRR')
    , 12000.00
    , 7
    , 7
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 30
    , 'Marlena'
    , NULL
    , 'Jakubowska'
    , 'kobieta'
    , TO_DATE('25-12-1999', 'DD-MM-RRRR')
    , 'polskie'
    , '99122572661'
    , 'marlena1999jakubowska@wp.pl'
    , '608525732'
    , 30
    , 19
    , TO_DATE('01-02-2022', 'DD-MM-RRRR')
    , 10000.00
    , 1
    , 1
    );
	
INSERT INTO employees 
(employee_id, first_name, middle_name, last_name, gender, birthdate, citizenship, pesel, email, phone_number, location_id, job_id, hire_date, salary, manager_id, department_id ) VALUES
    ( 31
    , 'Andrzej'
    , 'Michał'
    , 'Jonkisz'
    , 'mężczyzna'
    , TO_DATE('16-12-1972', 'DD-MM-RRRR')
    , 'polskie'
    , '72121697892'
    , 'a.m.jonkisz@wp.pl'
    , '934165671'
    , 31
    , 20
    , TO_DATE('01-03-2016', 'DD-MM-RRRR')
    , 15000.00
    , 7
    , 7
    );


-- Enabling integrity restriction for “employees”
ALTER TABLE departments
	ENABLE CONSTRAINT departments_fk_manager;
	

-- Adding data to the “locations” table	
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (1, 'Warszawa', 'Aleja Jerozolimskie', 123, '00-001', 7);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (2, 'Kraków', 'Floriańska', 45, '30-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (3, 'Gdańsk', 'Długa', 67, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (4, 'Poznań', 'Wielka', 89, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (5, 'Wrocław', 'Plac Solny', 34, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (6, 'Łódź', 'Piotrkowska', 56, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (7, 'Szczecin', 'Monte Cassino', 78, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (8, 'Katowice', 'Mariacka', 21, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (9, 'Gdynia', 'Świętojańska', 32, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (10, 'Bydgoszcz', 'Gdańska', 43, '85-001', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (11, 'Lublin', 'Krakowskie Przedmieście', 76, '20-001', 3);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (12, 'Białystok', 'Lipowa', 54, '15-001', 10);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (13, 'Kraków', 'Szewska', 23, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (14, 'Gdańsk', 'Nowe Ogrody', 45, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (15, 'Poznań', 'Garbary', 67, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (16, 'Wrocław', 'Kazimierza Wielkiego', 89, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (17, 'Łódź', 'Rewolucji 1905 roku', 34, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (18, 'Szczecin', 'Malczewskiego', 56, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (19, 'Katowice', 'Wojewódzka', 78, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (20, 'Gdynia', 'Morska', 21, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (21, 'Olsztyn', 'Półwiejska', 32, '10-001', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (22, 'Kraków', 'Gołębia', 43, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (23, 'Gdańsk', 'Długie Pobrzeże', 76, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (24, 'Poznań', 'Roosevelta', 54, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (25, 'Wrocław', 'Rynek', 23, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (26, 'Łódź', 'Legionów', 45, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (27, 'Szczecin', 'Piłsudskiego', 67, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (28, 'Katowice', '3 Maja', 89, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (29, 'Gdynia', 'Starowiejska', 34, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (30, 'Bydgoszcz', 'Toruńska', 56, '85-001', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (31, 'Lublin', 'Narutowicza', 78, '20-001', 3);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (32, 'Białystok', 'Jagiellońska', 21, '15-001', 10);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (33, 'Kraków', 'Floriańska', 32, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (34, 'Gdańsk', 'Podwale Staromiejskie', 43, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (35, 'Poznań', 'Ratajczaka', 76, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (36, 'Wrocław', 'Kiełbaśnicza', 54, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (37, 'Łódź', 'Nawrot', 23, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (38, 'Szczecin', 'Wyzwolenia', 45, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (39, 'Katowice', 'Gliwicka', 67, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (40, 'Gdynia', '10 Lutego', 89, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (41, 'Olsztyn', 'Grunwaldzka', 34, '10-001', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (42, 'Kraków', 'Lubicz', 56, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (43, 'Gdańsk', 'Słowackiego', 78, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (44, 'Poznań', 'Naramowicka', 21, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (45, 'Wrocław', 'Odrzańska', 32, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (46, 'Łódź', 'Zachodnia', 43, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (47, 'Szczecin', 'Sienkiewicza', 67, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (48, 'Katowice', 'Mikołowska', 89, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (49, 'Gdynia', 'Hutnicza', 54, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (50, 'Bydgoszcz', 'Chodkiewicza', 23, '85-001', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (51, 'Lublin', 'Radziszewskiego', 45, '20-001', 3);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (52, 'Białystok', 'Waryńskiego', 67, '15-001', 10);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (53, 'Kraków', 'Lea', 78, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (54, 'Gdańsk', 'Rzeźnicka', 89, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (55, 'Poznań', 'Strzelecka', 34, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (56, 'Wrocław', 'Swobodna', 56, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (57, 'Łódź', 'Radwańska', 23, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (58, 'Szczecin', 'Krasińskiego', 45, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (59, 'Katowice', 'Armii Krajowej', 67, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (60, 'Gdynia', 'Obłuże', 89, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (61, 'Olsztyn', 'Pstrowskiego', 21, '10-001', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (62, 'Kraków', 'Karmelicka', 32, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (63, 'Gdańsk', 'Jagiellońska', 43, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (64, 'Poznań', 'Przemyska', 76, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (65, 'Wrocław', 'Sienkiewicza', 54, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (66, 'Łódź', 'Zachodnia', 23, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (67, 'Szczecin', 'Monte Cassino', 45, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (68, 'Katowice', '3 Maja', 67, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (69, 'Gdynia', 'Wzgórze Św. Maksymiliana', 89, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (70, 'Bydgoszcz', 'Podwale', 34, '85-001', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (71, 'Lublin', 'Kościuszki', 56, '20-001', 3);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (72, 'Białystok', 'Mickiewicza', 78, '15-001', 10);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (73, 'Kraków', 'Floriańska', 89, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (74, 'Gdańsk', 'Pocztowa', 54, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (75, 'Poznań', 'Dąbrowskiego', 23, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (76, 'Wrocław', 'Rzeźnicza', 45, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (77, 'Łódź', 'Piotrkowska', 67, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (78, 'Szczecin', 'Monte Cassino', 89, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (79, 'Katowice', 'Warszawska', 34, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (80, 'Gdynia', 'Morska', 56, '81-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (81, 'Olsztyn', 'Warmińska', 78, '10-001', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (82, 'Kraków', 'Krasickiego', 21, '31-001', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (83, 'Gdańsk', 'Długa', 32, '80-001', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (84, 'Poznań', 'Naramowicka', 43, '61-001', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (85, 'Wrocław', 'Kazimierza Wielkiego', 76, '50-001', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (86, 'Łódź', 'Legionów', 54, '90-001', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (87, 'Szczecin', 'Malczewskiego', 23, '70-001', 16);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (88, 'Katowice', '3 Maja', 45, '40-001', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (89, 'Szczawnica', 'Górska', 12, '34-460', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (90, 'Gliwice', 'Sikorników', 56, '44-100', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (91, 'Suwałki', 'Kościuszki', 78, '16-400', 10);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (92, 'Ostróda', 'Malborska', 34, '14-100', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (93, 'Kielce', 'Sienkiewicza', 67, '25-001', 13);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (94, 'Zakopane', 'Krupówki', 89, '34-500', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (95, 'Bielsko-Biała', 'Cieszyńska', 21, '43-300', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (96, 'Jelenia Góra', 'Piastowska', 43, '58-500', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (97, 'Tarnobrzeg', 'Sandomierska', 76, '39-400', 9);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (98, 'Krosno', 'Rynek', 54, '38-400', 9);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (99, 'Kalisz', 'Nowy Świat', 32, '62-800', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (100, 'Radom', '3 Maja', 65, '26-600', 7);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (101, 'Częstochowa', 'Katedralna', 87, '42-200', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (102, 'Płock', 'Tumska', 45, '09-400', 7);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (103, 'Siedlce', 'Wojska Polskiego', 23, '08-100', 7);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (104, 'Elbląg', 'Młyńska', 76, '82-300', 14);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (105, 'Rzeszów', '3 Maja', 98, '35-001', 9);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (106, 'Gdynia', 'Starowiejska', 32, '81-002', 11);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (107, 'Toruń', 'Bulwar Filadelfijski', 43, '87-100', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (108, 'Opole', 'Piastowska', 76, '45-001', 8);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (109, 'Biała Podlaska', 'Lubelska', 54, '21-500', 3);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (110, 'Piotrków Trybunalski', 'Sienkiewicza', 32, '97-300', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (111, 'Leszno', 'Rynek', 65, '64-100', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (112, 'Nowy Sącz', 'Jagiellońska', 87, '33-300', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (113, 'Tychy', 'Krakowska', 45, '43-100', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (114, 'Pabianice', 'Piotrkowska', 23, '95-200', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (115, 'Lubin', 'Narutowicza', 76, '59-300', 1);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (116, 'Kędzierzyn-Koźle', 'Racławicka', 98, '47-200', 8);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (117, 'Inowrocław', 'Dworcowa', 32, '88-100', 2);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (118, 'Sieradz', 'Kościuszki', 54, '98-200', 5);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (119, 'Mysłowice', 'Wyszyńskiego', 65, '41-400', 12);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (120, 'Otwock', 'Armii Krajowej', 87, '05-400', 7);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (121, 'Piła', 'Wojska Polskiego', 45, '64-920', 15);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (122, 'Oświęcim', 'Zamkowa', 23, '32-600', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (123, 'Bochnia', 'Krakowska', 76, '32-700', 6);
INSERT INTO locations (location_id, city, street_name, property_number ,postal_code, voivodeship) VALUES (124, 'Kołobrzeg', 'Portowa', 98, '78-100', 16);


-- Enabling integrity constraint for “locations”
ALTER TABLE employees
	ENABLE CONSTRAINT employees_fk_locations;


-- Adding data to the table “customers”	
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (1, 'ABC Company sp. z o. o.', 32, '7257521356');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (2, 'XYZ Corporation', 33, '3384165704');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (3, '123 Enterprises sp. j.', 34, '2321306525');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (4, 'Quick Solutions', 35, '4710530672');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (5, 'Global Innovations sp. z o. o.', 36, '9743446465');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (6, 'Tech Ventures Corp', 37, '6155799254');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (7, 'Dynamic Systems sp. j.', 38, '6824170244');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (8, 'Epic Enterprises sp. z o. o.', 39, '8881722541');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (9, 'Infinite Solutions', 40, '6813735613');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (10, 'Powerful Technologies sp. z o. o.', 41, '5281419608');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (11, 'Future Trends', 42, '3977769964');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (12, 'Pinnacle Innovations sp. j.', 43, '8579739883');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (13, 'Swift Solutions sp. z o. o.', 44, '7442538013');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (14, 'Agile Systems', 45, '9644003523');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (15, 'Strategic Ventures sp. j.', 46, '5540909113');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (16, 'Innovative Minds', 47, '8566544108');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (17, 'Smart Solutions sp. z o. o.', 48, '8854110791');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (18, 'Global Enterprises sp. j.', 49, '3372232984');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (19, 'Tech Innovators sp. z o. o.', 50, '8222116368');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (20, 'Pioneer Solutions', 51, '4750082062');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (21, 'Advanced Systems sp. z o. o.', 52, '2914480443');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (22, 'ABC Corporation sp. j.', 53, '1261266424');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (23, 'Infinite Ventures', 54, '9194430796');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (24, 'Quick Innovations sp. z o. o.', 55, '6120306710');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (25, 'Tech Solutions', 56, '4834097849');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (26, 'Dynamic Innovators', 57, '3221780239');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (27, 'Epic Ventures sp. z o. o.', 58, '4924996853');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (28, 'Powerful Enterprises', 59, '1894830105');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (29, 'Swift Innovations sp. j.', 60, '5255089379');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (30, 'Future Enterprises', 61, '9814086360');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (31, 'Global Solutions sp. z o. o.', 62, '5692976368');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (32, 'Pinnacle Technologies sp. j.', 63, '8637130734');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (33, 'Agile Innovations', 64, '7526110260');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (34, 'Strategic Enterprises sp. z o. o.', 65, '3279191763');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (35, 'Smart Innovations', 66, '4514191587');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (36, 'Global Technologies sp. j.', 67, '9440386675');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (37, 'Tech Ventures', 68, '4396775886');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (38, 'Pioneer Technologies sp. z o. o.', 69, '5637414708');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (39, 'ABC Ventures', 70, '4559235002');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (40, 'Innovative Enterprises sp. z o. o.', 71, '6512288579');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (41, 'XYZ Innovations', 72, '7478144188');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (42, '123 Innovators sp. j.', 73, '1111135531');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (43, 'Quick Technologies', 74, '4413279464');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (44, 'Global Ventures sp. z o. o.', 75, '9410300396');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (45, 'Tech Innovations', 76, '6690625079');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (46, 'Dynamic Enterprises sp. j.', 77, '7753176813');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (47, 'Epic Innovators sp. z o. o.', 78, '4934816864');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (48, 'Powerful Innovations', 79, '1967145356');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (49, 'Swift Technologies', 80, '2350794177');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (50, 'Future Innovations sp. z o. o.', 81, '8583194846');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (51, 'Pinnacle Enterprises sp. j.', 82, '7972639584');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (52, 'Agile Technologies', 83, '9411288272');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (53, 'Strategic Innovations sp. z o. o.', 84, '2459644875');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (54, 'Smart', 85, '3686585946');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (55, 'Global Tech. sp. j.', 86, '2578177049');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (56, 'Tech Ventures sp. j.', 87, '6175434567');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (57, 'Pioneer sp. z o. o.', 88, '8125734127');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (58, 'ABC', 89, '3929369439');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (59, 'Innovative sp. z o. o.', 90, '6590888661');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (60, 'XYZ Technologies', 91, '7969696388');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (61, '123 Ventures sp. j.', 92, '5592172771');
INSERT INTO customers (customer_id, customer_name, location_id, vat_number) VALUES (62, 'Quick Innovations', 93, '1811868968');


-- Data to the “suppliers” table was added using Data Import Wizard, using the file “suppliers.xlsx”


-- Changing the date format to “yyyy-mm-dd”
ALTER SESSION SET nls_date_format = 'yyyy-mm-dd';


-- Data to the table “sales_history” was added using Data Import Wizard, using the file “sale.xlsx”


-- Data to the “sales_items” table was added with Data Import Wizard, using the file “sale_-_details.xlsx”


-- Data to the “purchase_history” table was added with Data Import Wizard, using the file “materials_purchases.xlsx”


-- Data to the “shopping_items” table was added with Data Import Wizard, using the file “material_purchases_-_details.xlsx”


-- Adding a “reorder_level” column to the “products” table
ALTER TABLE products
ADD reorder_level NUMBER(38,0) DEFAULT 0;


-- Completion of data in the “reorder_level” column of the “products” table
UPDATE products
SET reorder_level = CEIL(quantity_in_stock * 0.10);

UPDATE products
SET reorder_level = 350
WHERE quantity_in_stock > 300 AND quantity_in_stock < 310; 

UPDATE products
SET reorder_level = 500
WHERE product_id LIKE UPPER('%a');
