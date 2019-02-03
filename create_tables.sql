

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
CREATE TABLE well_numbers(plate_format INTEGER,
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
       INSERT INTO well_numbers(plate_format, well_name, ROW, row_num, col, total_col_count, by_col, by_row, quad, parent_well )
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
       INSERT INTO well_numbers(plate_format, well_name, ROW, row_num, col,total_col_count,  by_col, quad, parent_well )
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
       INSERT INTO well_numbers(plate_format, well_name, row,row_num, col, total_col_count,  by_col, quad, parent_well ) VALUES( plt_size, concat(r,colm), r, rownum, colm, 48, i, NULL, NULL);
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
DROP TABLE IF EXISTS plate_format CASCADE;
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


CREATE TABLE plate_format (id SERIAL PRIMARY KEY,
	format INTEGER, rownum INTEGER, colnum INTEGER);

INSERT INTO plate_format (format, rownum, colnum) VALUES ( 96, 8, 12);
INSERT INTO plate_format (format, rownum, colnum) VALUES (384, 16, 24);
INSERT INTO plate_format (format, rownum, colnum) VALUES (1536, 32, 48);


-----------------------------
DROP TABLE IF EXISTS plate_set CASCADE;
DROP SEQUENCE IF EXISTS plate_set_id_seq;

CREATE TABLE plate_set
(id SERIAL PRIMARY KEY,
	plate_set_name VARCHAR(30),
        descr VARCHAR(250),
        plate_set_sys_name VARCHAR(30),
        num_plates INTEGER,
        plate_format_id INTEGER,
        plate_type_id INTEGER,
        project_id INTEGER,
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
        FOREIGN KEY (plate_type_id) REFERENCES plate_type(id),
        FOREIGN KEY (plate_format_id) REFERENCES plate_format(id),
        FOREIGN KEY (project_id) REFERENCES project(id));


   


----------------------------
DROP TABLE IF EXISTS plate CASCADE;
DROP TABLE IF EXISTS well CASCADE;
DROP TABLE IF EXISTS sample CASCADE;

CREATE TABLE plate (id SERIAL PRIMARY KEY,
		plate_sys_name VARCHAR(30),
        	plate_type_id INTEGER,
  	        project_id INTEGER,
		plate_format_id INTEGER,
	        updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
                FOREIGN KEY (project_id) REFERENCES project(id),
                FOREIGN KEY (plate_type_id) REFERENCES plate_type(id),
		FOREIGN KEY (plate_format_id) REFERENCES plate_format(id));

----------------------------------------------------------------------------
DROP TABLE IF EXISTS plate_plate_set CASCADE;

CREATE TABLE plate_plate_set (
        	plate_set_id INTEGER,
        	plate_id INTEGER,
		plate_order INTEGER,
                FOREIGN KEY (plate_set_id) REFERENCES plate_set(id),
                FOREIGN KEY (plate_id) REFERENCES plate(id));

 
----------------------------------------------------------------------------

CREATE TABLE sample (id SERIAL PRIMARY KEY,
		sample_sys_name VARCHAR(20),
		project_id INTEGER,
                accs_id INTEGER,
		FOREIGN KEY (project_id) REFERENCES project(id));



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
DROP TABLE IF EXISTS hit_list CASCADE;

CREATE TABLE hit_list
(id SERIAL PRIMARY KEY,
 hitlist_sys_name VARCHAR(30),
        descr VARCHAR(250),
	updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
 project_id INTEGER,
 FOREIGN KEY (project_id) REFERENCES project(id));


DROP TABLE IF EXISTS hit_sample CASCADE;
CREATE TABLE hit_sample
(
 hitlist_id INTEGER,
  sample_id INTEGER,

 FOREIGN KEY (hitlist_id) REFERENCES hit_list(id),
 FOREIGN KEY (sample_id) REFERENCES sample(id));

----------------------------
   

DROP TABLE IF EXISTS assay_run CASCADE;

CREATE TABLE assay_run (id serial PRIMARY KEY,
               assay_run_sys_name VARCHAR(30),
	       assay_run_name VARCHAR(30),
               descr VARCHAR(250),
		assay_type_id INTEGER,
                plate_set_id INTEGER,
		plate_layout_name_id INTEGER,
                updated  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
               FOREIGN KEY (plate_set_id) REFERENCES plate_set(id),
               FOREIGN KEY (plate_layout_name_id) REFERENCES plate_layout_name(id),
		FOREIGN KEY (assay_type_id) REFERENCES assay_type(id));


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

CREATE TABLE assay_result (
		sample_id INTEGER,
                response REAL,
                assay_run_id INTEGER,
		FOREIGN KEY (assay_run_id) REFERENCES assay_run(id),
		FOREIGN KEY (sample_id) REFERENCES sample(id));


----------------------------

DROP TABLE IF EXISTS plate_layout_name CASCADE;

CREATE TABLE plate_layout_name (
		id SERIAL PRIMARY KEY,
                name VARCHAR(30),
                descr VARCHAR(30),
                plate_format_id INTEGER,
		FOREIGN KEY (plate_format_id) REFERENCES plate_format(id));
	
INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('4 controls column 12', 'singlecates', 1);		
INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 controls column 12', 'duplicates', 1);
INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('4 controls columns 23, 24', 'quadruplicates', 2);
INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 controls columns 23, 24', 'octuplicates', 2);
INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 controls columns 47, 48', 'quadruplicates', 3);


DROP TABLE IF EXISTS well_type CASCADE;
CREATE TABLE well_type (
		id SERIAL PRIMARY KEY,
                name VARCHAR(30));
    
INSERT INTO well_type (name) VALUES ('unknown');
INSERT INTO well_type (name) VALUES ('positive');
INSERT INTO well_type (name) VALUES ('negative');
INSERT INTO well_type (name) VALUES ('blank');


DROP TABLE IF EXISTS plate_layout CASCADE;

CREATE TABLE plate_layout (
		plate_layout_name_id INTEGER,
                well_by_col INTEGER,
                well_type_id INTEGER,
		FOREIGN KEY (plate_layout_name_id) REFERENCES plate_layout_name(id),
                FOREIGN KEY (well_type_id) REFERENCES well_type(id));




--INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('4 controls column 12', 'singlecates', 1);		

DROP FUNCTION IF EXISTS f96_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);
CREATE OR REPLACE FUNCTION f96_layout(_plate_layout_name_id INTEGER, _well_type_id INTEGER)
  RETURNS void AS
$BODY$

BEGIN
FOR i IN 1..92 loop  --96 well plate 4 controls
   INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id)
   VALUES ( _plate_layout_name_id, i,  _well_type_id);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT f96_layout(1,1);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 1, 93, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 1, 94, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 1, 95, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 1, 96, 4);

DROP FUNCTION IF EXISTS f96_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);

--INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 controls column 12', 'duplicates', 1);

DROP FUNCTION IF EXISTS f96_8_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);
CREATE OR REPLACE FUNCTION f96_8_layout(_plate_layout_name_id INTEGER, _well_type_id INTEGER)
  RETURNS void AS
$BODY$

BEGIN
FOR i IN 1..88 loop  --96 well plate 8 controls
   INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id)
   VALUES ( _plate_layout_name_id, i,  _well_type_id);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT f96_8_layout(2,1);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 89, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 90, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 91, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 92, 2);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 93, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 94, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 95, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 2, 96, 4);

DROP FUNCTION IF EXISTS f96_8_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);




---384 well layouts


--INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('4 contols columns 23, 24', 'quadruplicates', 2);

DROP FUNCTION IF EXISTS f384_4_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);
CREATE OR REPLACE FUNCTION f384_4_layout(_plate_layout_name_id INTEGER, _well_type_id INTEGER)
  RETURNS void AS
$BODY$

BEGIN
FOR i IN 1..360 loop 
   INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id)
   VALUES ( _plate_layout_name_id, i,  _well_type_id);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT f384_4_layout(3,1);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 361, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 362, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 363, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 364, 2);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 365, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 366, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 367, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 368, 4);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 369, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 370, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 371, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 372, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 373, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 374, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 375, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 376, 1);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 377, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 378, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 379, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 380, 2);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 381, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 382, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 383, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 3, 384, 4);

DROP FUNCTION IF EXISTS f384_4_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);



--INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 contols columns 23, 24', 'octuplicates', 2);

DROP FUNCTION IF EXISTS f384_8_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);
CREATE OR REPLACE FUNCTION f384_8_layout(_plate_layout_name_id INTEGER, _well_type_id INTEGER)
  RETURNS void AS
$BODY$

BEGIN
FOR i IN 1..352 loop 
   INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id)
   VALUES ( _plate_layout_name_id, i,  _well_type_id);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT f384_8_layout(4,1);


INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 353, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 354, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 355, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 356, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 357, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 358, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 359, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 360, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 361, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 362, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 363, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 364, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 365, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 366, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 367, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 368, 4);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 369, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 370, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 371, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 372, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 373, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 374, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 375, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 376, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 377, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 378, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 379, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 380, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 381, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 382, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 383, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 4, 384, 4);

DROP FUNCTION IF EXISTS f384_8_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);


--INSERT INTO plate_layout_name (name, descr, plate_format_id) VALUES ('8 contols columns 47, 48', 'quadruplicates', 3);

DROP FUNCTION IF EXISTS f1536_4_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);
CREATE OR REPLACE FUNCTION f1536_4_layout(_plate_layout_name_id INTEGER, _well_type_id INTEGER)
  RETURNS void AS
$BODY$

BEGIN
FOR i IN 1..1488 loop 
   INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id)
   VALUES ( _plate_layout_name_id, i,  _well_type_id);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT f1536_4_layout(5,1);


INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1489, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1490, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1491, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1492, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1493, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1494, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1495, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1496, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1497, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1498, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1499, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1500, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1501, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1502, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1503, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1504, 4);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1505, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1506, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1507, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1508, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1509, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1510, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1511, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1512, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1513, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1514, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1515, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1516, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1517, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1518, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1519, 1);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1520, 1);

INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1521, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1522, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1523, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1524, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1525, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1526, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1527, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1528, 2);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1529, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1530, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1531, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1532, 3);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1533, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1534, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1535, 4);
INSERT INTO plate_layout( plate_layout_name_id, well_by_col, well_type_id) VALUES ( 5, 1536, 4);

DROP FUNCTION IF EXISTS f1536_4_layout( _plate_layout_name_id INTEGER,  _well_type_id INTEGER);

-----------------------------------

DROP TABLE IF EXISTS temp_data CASCADE;

CREATE TABLE temp_data (
                plate INTEGER NOT NULL,
                well INTEGER NOT NULL,
                response REAL,
		PRIMARY KEY (plate, well));





