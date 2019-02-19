
----Project


DROP FUNCTION IF EXISTS new_project(_descr character varying, _project_name character VARYING, _pmuser_id INTEGER);
CREATE OR REPLACE FUNCTION new_project(_descr character varying, _project_name character VARYING, _pmuser_id INTEGER)
  RETURNS void AS
$BODY$
DECLARE
   v_id integer;
BEGIN
   INSERT INTO project(descr, project_name, pmuser_id)
   VALUES (_descr, _project_name, _pmuser_id)
   RETURNING id INTO v_id;
   UPDATE project SET project_sys_name = 'PRJ-'||v_id WHERE id=v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


-----Plate_set-------------------------------------------

DROP FUNCTION IF exists new_plate_set(_descr VARCHAR(30), _plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER,  _plate_type_id INTEGER, _project_id INTEGER, _with_samples boolean);

CREATE OR REPLACE FUNCTION new_plate_set(_descr VARCHAR(30),_plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER, _plate_type_id INTEGER, _project_id INTEGER, _with_samples boolean)
  RETURNS void AS
$BODY$
DECLARE
   ps_id INTEGER;
   n_plates INTEGER;
   p_type INTEGER;
   p_form INTEGER;
   prj_id INTEGER;
   plt_id INTEGER;
   w_spls BOOLEAN := _with_samples;
BEGIN
   
   INSERT INTO plate_set(descr, plate_set_name, num_plates, plate_format_id, plate_type_id, project_id)
   VALUES (_descr, _plate_set_name, _num_plates, _plate_format_id, _plate_type_id, _project_id )
   RETURNING ID, plate_format_id, num_plates, project_id, plate_type_id INTO ps_id, p_form, n_plates, prj_id, p_type;
   UPDATE plate_set SET plate_set_sys_name = 'PS-'||ps_id WHERE id=ps_id;

FOR i IN 1..n_plates loop
	     -- _plate_type_id INTEGER, _plate_set_id INTEGER, _project_id INTEGER, _plate_format_id INTEGER, include_sample BOOLEAN
	    SELECT new_plate(p_type, ps_id, prj_id, p_form, w_spls) INTO plt_id;
	    UPDATE plate_plate_set SET plate_order = i WHERE plate_set_id = ps_id AND plate_id = plt_id;

END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT new_plate_set('using loop','ps-name-by-user',20,3,1,1,TRUE);
select COUNT(*) FROM plate;
SELECT COUNT(*) FROM sample;
SELECT COUNT(*) FROM well;

-----Plate_set from group-------------------------------------------

DROP FUNCTION IF exists new_plate_set_from_group(_descr VARCHAR(30), _plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER,  _plate_type_id INTEGER, _project_id INTEGER);

CREATE OR REPLACE FUNCTION new_plate_set_from_group(_descr VARCHAR(30),_plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER, _plate_type_id INTEGER, _project_id INTEGER)
  RETURNS integer AS
$BODY$
DECLARE
   ps_id INTEGER;
    
BEGIN
   
   INSERT INTO plate_set(descr, plate_set_name, num_plates, plate_format_id, plate_type_id, project_id)
   VALUES (_descr, _plate_set_name, _num_plates, _plate_format_id, _plate_type_id, _project_id )
   RETURNING id INTO ps_id;
   UPDATE plate_set SET plate_set_sys_name = 'PS-'||ps_id WHERE id=ps_id;


RETURN ps_id;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


---Get all sample IDs in a plate set

DROP FUNCTION IF exists get_num_samples_for_plate_set( _plate_set_id INTEGER);
CREATE OR REPLACE FUNCTION get_num_samples_for_plate_set(_plate_set_id INTEGER)
  RETURNS INTEGER AS
$BODY$
DECLARE
   psid int := _plate_set_id;
   
   counter INTEGER;
   sql_statement VARCHAR;
all_sample_ids INTEGER[];
num_samples INTEGER;
   
BEGIN

sql_statement := 'SELECT ARRAY(SELECT sample.id FROM plate, plate_plate_set, well, sample, well_sample WHERE plate_plate_set.plate_set_id = ' || psid || ' AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id ORDER BY plate_plate_set.plate_id, plate_plate_set.plate_order, well.id)';

--    RAISE notice 'sql_statement: (%)', sql_statement;

     EXECUTE sql_statement INTO all_sample_ids;
     num_samples := array_length(all_sample_ids ,1); 
 -- RAISE notice 'ids: (%)', all_sample_ids;
 -- RAISE notice 'num: (%)', num_samples;

RETURN num_samples;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



--associate multiple plate IDs with a plate set ID----------------------

DROP FUNCTION IF exists assoc_plate_ids_with_plate_set_id( _plate_ids INTEGER[], _plate_set_id INTEGER);
CREATE OR REPLACE FUNCTION assoc_plate_ids_with_plate_set_id(_plate_ids int[], _plate_set_id int)
  RETURNS void AS
$BODY$
DECLARE
   pid int;
   plate_ids int[];
   counter INTEGER;
   sql_statement VARCHAR;
   
BEGIN
counter := 1;
SELECT sort(_plate_ids) INTO plate_ids;
sql_statement := 'INSERT INTO plate_plate_set (plate_set_id, plate_id, plate_order) VALUES ';

  FOREACH pid IN ARRAY plate_ids
     LOOP
     sql_statement := sql_statement || '(' || _plate_set_id || ', '  ||  pid || ', ' || counter || '),';
     counter = counter + 1;
    END LOOP;

     sql_statement := SUBSTRING(sql_statement, 1, CHAR_LENGTH(sql_statement)-1) || ';';
     --RAISE notice 'sqlstatement: (%)', sql_statement;
     EXECUTE sql_statement;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT assoc_plate_ids_with_plate_set_id('{101,100,102}', 10);


---hit_list-------------------------
   
CREATE OR REPLACE FUNCTION new_hit_list(_descr VARCHAR(250), _project_id INTEGER)
  RETURNS integer AS
$BODY$
DECLARE
   v_id integer;
BEGIN
   
   INSERT INTO hit_list(descr,  project_id)
   VALUES (_descr,  _project_id )
   RETURNING id INTO v_id;
   UPDATE hit_list SET hitlist_sys_name = 'HL-'||v_id WHERE id=v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



-----Plate-----------------------

DROP FUNCTION new_plate(INTEGER, INTEGER,INTEGER,INTEGER,  BOOLEAN);

CREATE OR REPLACE FUNCTION new_plate(_plate_type_id INTEGER, _plate_set_id INTEGER, _project_id INTEGER, _plate_format_id INTEGER,  _include_sample BOOLEAN)
  RETURNS integer AS
$BODY$
DECLARE
   plt_id INTEGER;
   ps_id INTEGER = _plate_set_id;
   prj_id INTEGER;
   pf_id INTEGER;
   w_id INTEGER;
   s_id INTEGER;
   spl_include BOOLEAN := _include_sample;
   row_holder   VARCHAR[] := ARRAY['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF'];
   row_names VARCHAR[];
   r VARCHAR(2);	
   col_holder   VARCHAR[] := ARRAY['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48'];
   col_names VARCHAR[];
   c VARCHAR(2);	

BEGIN
--spl_include := _include_sample;
CASE _plate_format_id
   WHEN 96 THEN
   row_names := row_holder[1:8];
   col_names := col_holder[1:12];
   WHEN 384 THEN
   row_names := row_holder[1:16];
   col_names := col_holder[1:24];
   WHEN 1536 THEN
   row_names := row_holder[1:32];
   col_names := col_holder[1:48];
   ELSE
   END CASE;
   
   INSERT INTO plate(plate_type_id,  project_id, plate_format_id)
   VALUES (_plate_type_id,  _project_id, _plate_format_id)
   RETURNING id, project_id INTO plt_id, prj_id;


    UPDATE plate SET plate_sys_name = 'PLT-'||plt_id WHERE id=plt_id;
   FOREACH c IN ARRAY col_names
     LOOP
   FOREACH r  IN ARRAY row_names
   LOOP
       INSERT INTO well(well_name, plate_id) VALUES(concat(r,c), plt_id)
       RETURNING id INTO w_id;
       IF spl_include THEN 
       INSERT INTO sample( project_id) VALUES (prj_id)
       RETURNING id INTO s_id;
       UPDATE sample SET sample_sys_name = 'SPL-'||s_id WHERE id=s_id;

       INSERT INTO well_sample(well_id, sample_id)VALUES(w_id, s_id);

       END IF;
   END LOOP;
   END LOOP;

   INSERT INTO plate_plate_set(plate_set_id, plate_id)
   VALUES (ps_id, plt_id );

RETURN plt_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


---Plate2-------------------------------------------------------------------------

DROP FUNCTION new_plate2(INTEGER, INTEGER,INTEGER,INTEGER, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION new_plate2(_plate_type_id INTEGER, _plate_set_id INTEGER, _project_id INTEGER, _plate_format_id INTEGER, _plate_layout_name_id INTEGER,  _include_sample BOOLEAN)
  RETURNS integer AS
$BODY$
DECLARE
   plt_id INTEGER;
   ps_id INTEGER = _plate_set_id;
   prj_id INTEGER;
   pf_id INTEGER;
   play_id INTEGER;
   w_id INTEGER;
   s_id INTEGER;
   spl_include BOOLEAN := _include_sample;

 INSERT INTO plate(plate_type_id,  project_id, plate_format_id, plate_layout_name_id)
   VALUES (_plate_type_id,  _project_id, _plate_format_id, _plate_layout_name_id )
   RETURNING id, project_id INTO plt_id, prj_id;

    UPDATE plate SET plate_sys_name = 'PLT-'||plt_id WHERE id=plt_id;


   FOR temprow  IN 
	SELECT well_by_col FROM plate_layout WHERE plate_layout.plate_layout_name_id = _plate_layout_name_id ;
   LOOP
       INSERT INTO well(well_name, plate_id) VALUES(concat(r,c), plt_id)
       RETURNING id INTO w_id;

       IF spl_include THEN 
       INSERT INTO sample( project_id) VALUES (prj_id)
       RETURNING id INTO s_id;
       UPDATE sample SET sample_sys_name = 'SPL-'||s_id WHERE id=s_id;

       INSERT INTO well_sample(well_id, sample_id)VALUES(w_id, s_id);

       END IF;
   END LOOP;

   INSERT INTO plate_plate_set(plate_set_id, plate_id)
   VALUES (ps_id, plt_id );

RETURN plt_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT new_plate(1,1,1,1,3, TRUE);
SELECT * FROM sample;
SELECT * FROM well;
SELECT * FROM plate;

----Sample------------------------------------------------------------------------


DROP FUNCTION new_sample(INTEGER,INTEGER,INTEGER);
CREATE OR REPLACE FUNCTION new_sample(_project_id INTEGER, _plate_id INTEGER,  _accs_id INTEGER)
  RETURNS void AS
$BODY$
DECLARE
   v_id integer;
BEGIN
   
   INSERT INTO sample(project_id, plate_id, accs_id)
   VALUES (_project_id, _plate_id,   _accs_id)
   RETURNING id INTO v_id;

    UPDATE sample SET sample_sys_name = 'SPL-'||v_id WHERE id=v_id RETURNING id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


----Well--------------------------------------------


-----Hits-----------------------

-----Assay_run---------------------

DROP FUNCTION new_assay_run(  VARCHAR(30), VARCHAR(30), INTEGER,  INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION new_assay_run( _assay_run_name VARCHAR(30), _descr VARCHAR(30), _assay_type_id INTEGER, _plate_set_id INTEGER, _plate_layout_name_id INTEGER)
  RETURNS integer AS
$BODY$
DECLARE
   v_id integer;
BEGIN
   
   INSERT INTO assay_run(assay_run_name , descr, assay_type_id, plate_set_id, plate_layout_name_id)
   VALUES (_assay_run_name, _descr, _assay_type_id, _plate_set_id, _plate_layout_name_id)
   RETURNING id INTO v_id;

    UPDATE assay_run SET assay_run_sys_name = 'AR-'||v_id WHERE id=v_id;

RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

-----assay_type----------------------------------------------------

-----assay_result----------------------------------------------------------------


-----plate_type----------------------------


--https://hub.packtpub.com/how-to-implement-dynamic-sql-in-postgresql-10/

DROP FUNCTION get_ids_for_sys_names( VARCHAR[], VARCHAR(30), VARCHAR(30));

CREATE OR REPLACE FUNCTION get_ids_for_sys_names( _sys_names VARCHAR[], _table VARCHAR(30), _sys_name VARCHAR(30))
  RETURNS integer[] AS
$BODY$
DECLARE
   sn varchar(20);
   an_int integer;
   sys_ids INTEGER[];
   sql_statement VARCHAR;
   sql_statement2 VARCHAR;
   
   temp INTEGER;

BEGIN

 sql_statement := 'SELECT id FROM ' || _table || ' WHERE ' || _sys_name   || ' = ';

  FOREACH sn IN ARRAY _sys_names
     LOOP
     sql_statement2 := sql_statement || quote_literal(sn);
     EXECUTE sql_statement2 INTO temp;
     sys_ids := array_append(sys_ids, temp );
    END LOOP;

RETURN sys_ids;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE PARALLEL UNSAFE;


--SELECT get_ids_for_sys_names('{"PLT-1","PLT-2","PLT-3"}', 'plate', 'plate_sys_name');




