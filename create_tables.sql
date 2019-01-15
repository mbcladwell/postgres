

CREATE EXTENSION pgcrypto;


DROP  FUNCTION IF EXISTS calc_by_row_num_func()  CASCADE;

CREATE FUNCTION calc_by_row_num_func()
  RETURNS trigger AS
  $BODY$

BEGIN
 NEW.by_row := NEW.total_col_count*(NEW.row_num -1) + CAST(NEW.col AS integer);
 IF  (CAST(NEW.col AS INTEGER)%2 = 1) AND ( NEW.row_num%2 = 1)  THEN
    NEW.quad :=1;
    elsif (CAST(NEW.col AS INTEGER)%2 = 0) AND ( NEW.row_num%2 = 1)  THEN
    NEW.quad :=2;
    ELSIF (CAST(NEW.col AS INTEGER)%2 = 1) AND ( NEW.row_num%2 = 0)  THEN
    NEW.quad :=3;
    ELSE
    NEW.quad :=4;
    END IF;
    
 RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS calculate_by_row_number ON well_numbers;

DROP TABLE IF EXISTS well_numbers CASCADE;
CREATE TABLE well_numbers(plate_size INTEGER,
			well_name VARCHAR(5), 
                           row VARCHAR(2),
			   row_num INTEGER,
                           col VARCHAR(2),
			   total_col_count INTEGER,
                           by_row INTEGER,
                           by_col INTEGER,
                           quad INTEGER,
			   parent_well VARCHAR(5));

CREATE TRIGGER calculate_by_row_number
before INSERT ON well_numbers
FOR EACH row EXECUTE PROCEDURE calc_by_row_num_func();



-----well_numbers-------------------------

DROP FUNCTION IF EXISTS fill_well_numbers_a();

CREATE OR REPLACE FUNCTION fill_well_numbers_a()
  RETURNS void AS
$BODY$
DECLARE
   plt_size INTEGER;
   row_holder   VARCHAR[] := ARRAY['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF'];
   row_names VARCHAR[];
   r VARCHAR(2);	
   col_holder   VARCHAR[] := ARRAY['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48'];
   col_names VARCHAR[];
   colm VARCHAR(2);	
   i INTEGER;
   rownum INTEGER;
BEGIN

   plt_size := 96;
   row_names := row_holder[1:8];
   col_names := col_holder[1:12];
   i := 1;
   rownum := 1;
   --total_col_count*(rownum -1) + colnum

    FOREACH colm IN ARRAY col_names
   LOOP
      FOREACH r  IN ARRAY row_names
     LOOP
       INSERT INTO well_numbers(plate_size, well_name, ROW, row_num, col, total_col_count, by_col, by_row, quad, parent_well )
                          VALUES( plt_size, concat(r,colm), r, rownum, colm, 12, i, NULL , NULL, NULL);
       i := i +1;
       IF rownum = 8 THEN rownum :=1; ELSE rownum := rownum+1; END if;
   END LOOP;
   END LOOP;

   plt_size := 384;
   row_names := row_holder[1:16];
   col_names := col_holder[1:24];
   i := 1;
   rownum := 1;

   
    FOREACH colm IN ARRAY col_names
   LOOP
      FOREACH r  IN ARRAY row_names
     LOOP
       INSERT INTO well_numbers(plate_size, well_name, ROW, row_num, col,total_col_count,  by_col, quad, parent_well )
       VALUES( plt_size, concat(r,colm), r, rownum, colm, 24, i, NULL, NULL);
       i := i +1;
       IF rownum = 16 THEN rownum :=1; ELSE rownum := rownum+1; END if;
   END LOOP;
   END LOOP;

   plt_size := 1536;
   row_names := row_holder[1:32];
   col_names := col_holder[1:48];
   i := 1;
   rownum := 1;

   
    FOREACH colm IN ARRAY col_names
   LOOP
      FOREACH r  IN ARRAY row_names
     LOOP
       INSERT INTO well_numbers(plate_size, well_name, row,row_num, col, total_col_count,  by_col, quad, parent_well ) VALUES( plt_size, concat(r,colm), r, rownum, colm, 48, i, NULL, NULL);
       i := i +1;
       IF rownum = 32 THEN rownum :=1; ELSE rownum := rownum+1; END if;
   END LOOP;
   END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT fill_well_numbers_a();

DROP TRIGGER IF EXISTS calculate_by_row_number ON well_numbers;
DROP  FUNCTION IF EXISTS calc_by_row_num_func()  CASCADE;
DROP FUNCTION IF EXISTS fill_well_numbers_a();


--users------------------------------------------------------

DROP TABLE IF EXISTS pmuser_permissions CASCADE;
DROP SEQUENCE IF EXISTS  pmuser_permissions_id_seq CASCADE;
DROP INDEX IF EXISTS pmuser_permissions_pkey CASCADE;
CREATE TABLE pmuser_permissions
(id SERIAL PRIMARY KEY,
        permissions VARCHAR(30),
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp);

INSERT INTO pmuser_permissions (permissions) VALUES ('administrator');
INSERT INTO pmuser_permissions (permissions) VALUES ('superpmuser');
INSERT INTO pmuser_permissions (permissions) VALUES ('user');

DROP TABLE IF EXISTS pmuser CASCADE;
DROP SEQUENCE IF EXISTS  pmuser_id_seq CASCADE;
DROP INDEX IF EXISTS pmuser_pkey CASCADE;
CREATE TABLE pmuser
(id SERIAL PRIMARY KEY,
        permissions INTEGER,
	pmuser_name VARCHAR(30),
	email VARCHAR(30) NOT NULL UNIQUE,
        password VARCHAR(64) NOT NULL,
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp);

--INSERT INTO pmuser ( pmuser_name, email, permissions, password) VALUES ('admin1', 'pmadmin@postgres', 1, crypt('welcome',gen_salt('bf')));
INSERT INTO pmuser ( pmuser_name, email, permissions, password) VALUES ('admin1', 'pmadmin@postgres', 1, 'welcome');
INSERT INTO pmuser ( pmuser_name, email, permissions, password) VALUES ('user1', 'pmadmin2@postgres', 1, 'welcome');


select * from pmuser;


DROP TABLE IF EXISTS pmsession CASCADE;
DROP SEQUENCE IF EXISTS  pmsession_id_seq CASCADE;
DROP INDEX IF EXISTS pmsession_pkey CASCADE;
CREATE TABLE pmsession
(id SERIAL PRIMARY key,
        pmuser_id INTEGER,
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
        FOREIGN KEY (pmuser_id) REFERENCES pmuser(id));



DROP TABLE IF EXISTS project CASCADE;
DROP SEQUENCE IF EXISTS  project_id_seq CASCADE;
DROP INDEX IF EXISTS project_pkey CASCADE;
CREATE TABLE project
(id SERIAL PRIMARY KEY,
        project_sys_name VARCHAR(30),
        descr VARCHAR(30),
	project_name VARCHAR(30),
        pmuser_id INTEGER,
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
        FOREIGN KEY (pmuser_id) REFERENCES pmuser(id));


------------------------------------------------
DROP TABLE IF EXISTS plate_size CASCADE;
DROP TABLE IF EXISTS plate_type CASCADE;

CREATE TABLE plate_type
(id SERIAL PRIMARY KEY,
	plate_type_name VARCHAR(30));

INSERT INTO plate_type (plate_type_name) VALUES ('assay');
INSERT INTO plate_type (plate_type_name) VALUES ('rearray');
INSERT INTO plate_type (plate_type_name) VALUES ('master');
INSERT INTO plate_type (plate_type_name) VALUES ('daughter');
INSERT INTO plate_type (plate_type_name) VALUES ('archive');
INSERT INTO plate_type (plate_type_name) VALUES ('replicate');


CREATE TABLE plate_size (id SERIAL PRIMARY KEY,
	format INTEGER, rownum INTEGER, colnum INTEGER);

INSERT INTO plate_size (format, rownum, colnum) VALUES ( 96, 8, 12);
INSERT INTO plate_size (format, rownum, colnum) VALUES (384, 16, 24);
INSERT INTO plate_size (format, rownum, colnum) VALUES (1536, 32, 48);


-----------------------------
DROP TABLE IF EXISTS plate_set CASCADE;
DROP SEQUENCE IF EXISTS plate_set_id_seq;

CREATE TABLE plate_set
(id SERIAL PRIMARY KEY,
	plate_set_name VARCHAR(30),
        descr VARCHAR(250),
        plate_set_sys_name VARCHAR(30),
        num_plates INTEGER,
        plate_size_id INTEGER,
        plate_type_id INTEGER,
        project_id INTEGER,
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
        FOREIGN KEY (plate_type_id) REFERENCES plate_type(id),
        FOREIGN KEY (plate_size_id) REFERENCES plate_size(id),
        FOREIGN KEY (project_id) REFERENCES project(id));


----------------------------
DROP TABLE IF EXISTS hit_list CASCADE;

CREATE TABLE hit_list
(id SERIAL PRIMARY KEY,
 hitlist_sys_name VARCHAR(30),
        descr VARCHAR(250),
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
 project_id INTEGER,
 FOREIGN KEY (project_id) REFERENCES project(id));
   


----------------------------
DROP TABLE IF EXISTS plate CASCADE;
DROP TABLE IF EXISTS well CASCADE;
DROP TABLE IF EXISTS sample CASCADE;

CREATE TABLE plate (id SERIAL PRIMARY KEY,
		plate_sys_name VARCHAR(30),
        	plate_type_id INTEGER,
        	plate_seq_num INTEGER, --sequence order in a plate set 
	        project_id INTEGER,
		plate_size_id INTEGER,
	        updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
                FOREIGN KEY (project_id) REFERENCES project(id),
                FOREIGN KEY (plate_type_id) REFERENCES plate_type(id),
		FOREIGN KEY (plate_size_id) REFERENCES plate_size(id));

----------------------------------------------------------------------------
DROP TABLE IF EXISTS plate_plate_set CASCADE;

CREATE TABLE plate_plate_set (
        	plate_set_id INTEGER,
        	plate_id INTEGER,
                FOREIGN KEY (plate_set_id) REFERENCES plate_set(id),
                FOREIGN KEY (plate_id) REFERENCES plate(id));


  
----------------------------------------------------------------------------

CREATE TABLE sample (id SERIAL PRIMARY KEY,
		sample_sys_name VARCHAR(20),
		project_id INTEGER,
		type VARCHAR(30),  --positive, negative, unknown, blank
        	plate_id INTEGER, 
                accs_id INTEGER,
		FOREIGN KEY (project_id) REFERENCES project(id),
		FOREIGN KEY (plate_id) REFERENCES plate(id));



DROP TABLE IF EXISTS well CASCADE;
CREATE TABLE well (id SERIAL PRIMARY KEY,
  		well_name VARCHAR(5),
		plate_id INTEGER,
		FOREIGN KEY (plate_id) REFERENCES plate(id));


----------------------------------------------------------------------------
DROP TABLE IF EXISTS well_sample CASCADE;

CREATE TABLE well_sample (
        	well_id INTEGER,
        	sample_id INTEGER,
                FOREIGN KEY (well_id) REFERENCES well(id),
                FOREIGN KEY (sample_id) REFERENCES sample(id));



----------------------------
DROP TABLE IF EXISTS hits CASCADE;
CREATE TABLE hits
(id SERIAL PRIMARY KEY,
 
 hitlist_id INTEGER,
  sample_id INTEGER,

 FOREIGN KEY (hitlist_id) REFERENCES hit_list(id),
 FOREIGN KEY (sample_id) REFERENCES sample(id));
   

DROP TABLE IF EXISTS assay_run CASCADE;

CREATE TABLE assay_run (id serial PRIMARY KEY,
               assay_run_sys_name VARCHAR(30),
	       assay_run_name VARCHAR(30),
               descr VARCHAR(250),
		assay_type_id INTEGER,
                plate_set_id INTEGER,
                updated  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
               FOREIGN KEY (plate_set_id) REFERENCES plate_set(id),
		FOREIGN KEY (assay_type_id) REFERENCES assay_type(ID));


DROP TABLE IF EXISTS assay_type CASCADE;
CREATE TABLE assay_type (id SERIAL PRIMARY KEY,
	assay_type_name VARCHAR(30));

INSERT INTO assay_type (assay_type_name) VALUES ('ELISA');
INSERT INTO assay_type (assay_type_name) VALUES ('Octet');
INSERT INTO assay_type (assay_type_name) VALUES ('SNP');
INSERT INTO assay_type (assay_type_name) VALUES ('HCS');
INSERT INTO assay_type (assay_type_name) VALUES ('NGS');
INSERT INTO assay_type (assay_type_name) VALUES ('FACS');		

DROP TABLE IF EXISTS assay_result CASCADE;

CREATE TABLE assay_result (id SERIAL PRIMARY KEY,
		sample_id INTEGER,
                response REAL,
                assay_run_id INTEGER,
		FOREIGN KEY (assay_run_id) REFERENCES assay_run(id),
		FOREIGN KEY (sample_id) REFERENCES sample(id));



