
---User

DROP FUNCTION IF EXISTS new_user(_name character varying, _tags character VARYING, _password CHARACTER VARYING, _group INTEGER);
CREATE OR REPLACE FUNCTION new_user(_name character varying, _tags character VARYING, _password CHARACTER VARYING, _group INTEGER)
  RETURNS void AS
$BODY$
BEGIN
   INSERT INTO pmuser(usergroup, pmuser_name, tags, password)
   VALUES (_group, _name, _tags, _password);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




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


DROP FUNCTION IF exists new_plate_set(_descr VARCHAR(30), _plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER,  _plate_type_id INTEGER, _project_id INTEGER, _plate_layout_name_id INTEGER, _with_samples boolean);

CREATE OR REPLACE FUNCTION new_plate_set(_descr VARCHAR(30),_plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER, _plate_type_id INTEGER, _project_id INTEGER, _plate_layout_name_id INTEGER, _with_samples boolean)
  RETURNS integer AS
$BODY$
DECLARE
   ps_id INTEGER;
   n_plates INTEGER;
   p_type INTEGER;
   p_form INTEGER;
   prj_id INTEGER;
   plt_id INTEGER;
   play_n_id INTEGER;
   w_spls BOOLEAN := _with_samples;
BEGIN
   
   INSERT INTO plate_set(descr, plate_set_name, num_plates, plate_format_id, plate_type_id, project_id, plate_layout_name_id)
   VALUES (_descr, _plate_set_name, _num_plates, _plate_format_id, _plate_type_id, _project_id, _plate_layout_name_id )
   RETURNING ID, plate_format_id, num_plates, project_id, plate_type_id, plate_layout_name_id INTO ps_id, p_form, n_plates, prj_id, p_type, play_n_id;
   UPDATE plate_set SET plate_set_sys_name = 'PS-'||ps_id WHERE id=ps_id;

FOR i IN 1..n_plates loop
	     -- _plate_type_id INTEGER, _plate_set_id INTEGER, _project_id INTEGER, _plate_format_id INTEGER, include_sample BOOLEAN
	    SELECT new_plate(p_type, ps_id, p_form, play_n_id, w_spls) INTO plt_id;
	    UPDATE plate_plate_set SET plate_order = i WHERE plate_set_id = ps_id AND plate_id = plt_id;

END LOOP;

RETURN ps_id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




--SELECT new_plate_set('using loop','ps-name-by-user',20,3,1,1,TRUE);
select COUNT(*) FROM plate;
SELECT COUNT(*) FROM sample;
SELECT COUNT(*) FROM well;

-----Plate_set from group-------------------------------------------

DROP FUNCTION IF exists new_plate_set_from_group(_descr VARCHAR(30), _plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER,  _plate_type_id INTEGER, _project_id INTEGER, _plate_layout_name_id INTEGER);

CREATE OR REPLACE FUNCTION new_plate_set_from_group(_descr VARCHAR(30),_plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER, _plate_type_id INTEGER, _project_id INTEGER, _plate_layout_name_id INTEGER)
  RETURNS integer AS
$BODY$
DECLARE
   ps_id INTEGER;
    
BEGIN
   
   INSERT INTO plate_set(descr, plate_set_name, num_plates, plate_format_id, plate_type_id, project_id, plate_layout_name_id)
   VALUES (_descr, _plate_set_name, _num_plates, _plate_format_id, _plate_type_id, _project_id, _plate_layout_name_id )
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


-----Plate-----------------------
--well name converted to by_col integer


DROP FUNCTION new_plate(INTEGER, INTEGER,INTEGER,INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION new_plate(_plate_type_id INTEGER, _plate_set_id INTEGER, _plate_format_id INTEGER, _plate_layout_name_id INTEGER,  _include_sample BOOLEAN)
  RETURNS integer AS
$BODY$
DECLARE
   plt_id INTEGER;
   ps_id INTEGER = _plate_set_id;
   pf_id INTEGER;
   w_id INTEGER;
   s_id INTEGER;
   spl_include BOOLEAN := _include_sample;
   w integer;	

BEGIN

   INSERT INTO plate(plate_type_id,   plate_format_id, plate_layout_name_id)
   VALUES (_plate_type_id,  _plate_format_id, _plate_layout_name_id)
   RETURNING id  INTO plt_id;

    UPDATE plate SET plate_sys_name = 'PLT-'||plt_id WHERE id=plt_id;


FOR w IN 1.._plate_format_id LOOP

--RAISE notice 'w: (%)', w;
       INSERT INTO well(by_col, plate_id) VALUES(w, plt_id)
       RETURNING id INTO w_id;
       
       IF spl_include THEN  --check if it is an "unknown" well i.e. not a control
       IF w IN (SELECT well_by_col  FROM plate_layout, plate_layout_name  WHERE plate_layout.plate_layout_name_id = plate_layout_name.id AND plate_layout.well_type_id = 1 AND plate_layout.plate_layout_name_id = _plate_layout_name_id) THEN
       INSERT INTO sample (sample_sys_name) VALUES (null)
       RETURNING id INTO s_id;
       UPDATE sample SET sample_sys_name = 'SPL-'||s_id WHERE id=s_id;

       INSERT INTO well_sample(well_id, sample_id)VALUES(w_id, s_id);
      END IF;
       END IF;
   END LOOP;

   INSERT INTO plate_plate_set(plate_set_id, plate_id)
   VALUES (ps_id, plt_id );

RETURN plt_id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT new_plate(1,1,96,1, TRUE);


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

---------Number of samples in a plate set-----------------------------------------------------------------

DROP FUNCTION get_number_samples_for_psid( _psid INTEGER );

CREATE OR REPLACE FUNCTION get_number_samples_for_psid( _psid INTEGER) 
  RETURNS integer AS
$BODY$
DECLARE
   num_samples INTEGER;
   sql_statement VARCHAR;
  --plate_layout_name_id INTEGER;

BEGIN

     --sql_statement := 'SELECT plate_layout_name_id FROM plate_set WHERE id = ' || _psid;
     --EXECUTE sql_statement INTO plate_layout_name_id;

      sql_statement := 'SELECT count(sample_id) FROM well_sample WHERE well_sample.well_id IN (SELECT well.id FROM well WHERE well.plate_id  IN (SELECT plate_id FROM plate_plate_set WHERE plate_plate_set.plate_set_id = ' || _psid || '))'; 
      EXECUTE sql_statement INTO num_samples;

RETURN num_samples;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE PARALLEL UNSAFE;


------new plate layout

DROP FUNCTION new_plate_layout(  VARCHAR(30), VARCHAR(30), INTEGER,  VARCHAR[][]);

CREATE OR REPLACE FUNCTION new_plate_layout( _plate_layout_name VARCHAR(30), _descr VARCHAR(30), _plate_format_id INTEGER, _data VARCHAR[][])
  RETURNS integer AS
$BODY$
DECLARE
   src_id integer;
   dest_id INTEGER;
   dest_name VARCHAR(30);
BEGIN


   INSERT INTO plate_layout_name(name, descr, plate_format_id)
   VALUES (_plate_layout_name, _descr, _plate_format_id)
   RETURNING id INTO src_id;

dest_name := _plate_layout_name || '-dest';

   INSERT INTO plate_layout_name(name, descr, plate_format_id)
   VALUES (_plate_layout_name, _descr, _plate_format_id)
   RETURNING id INTO dest_id;

INSERT INTO layout_source_dest(src, dest) VALUES (src_id, dest_id);


 
RETURN plname_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


----reformat



DROP FUNCTION IF exists reformat_plate_set(source_plate_set_id INTEGER, source_num_plates INTEGER, n_reps_source INTEGER, dest_descr VARCHAR(30), dest_plate_set_name VARCHAR(30), dest_num_plates INTEGER, dest_plate_format_id INTEGER, dest_plate_type_id INTEGER, project_id INTEGER, dest_plate_layout_name_id INTEGER );

CREATE OR REPLACE FUNCTION reformat_plate_set(source_plate_set_id INTEGER, source_num_plates INTEGER, n_reps_source INTEGER, dest_descr VARCHAR(30), dest_plate_set_name VARCHAR(30), dest_num_plates INTEGER, dest_plate_format_id INTEGER, dest_plate_type_id INTEGER, project_id INTEGER, dest_plate_layout_name_id INTEGER )
 RETURNS integer AS
$BODY$
DECLARE

dest_plate_set_id INTEGER;
all_source_well_ids INTEGER[];
all_dest_well_ids INTEGER[];
 w INTEGER;
holder INTEGER;

BEGIN
--here I am creating the destination plate set, no samples included
SELECT new_plate_set(dest_descr ,dest_plate_set_name, dest_num_plates, dest_plate_format_id, dest_plate_type_id, project_id, dest_plate_layout_name_id, false) INTO dest_plate_set_id;

--RAISE notice 'dest_plate_set_id: (%)', dest_plate_set_id;

CREATE TEMP TABLE temp1(plate_id INT, well_name VARCHAR(10), well_id INT);

FOR i IN 1..n_reps_source LOOP
INSERT INTO temp1 select well.plate_id, well.well_name, well.id AS well_id FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = source_plate_set_id AND plate_plate_set.plate_id = well.plate_id   ORDER BY plate_plate_set.plate_order, well.ID;
END LOOP;

SELECT ARRAY (SELECT well_id FROM temp1) INTO all_source_well_ids;


SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = dest_plate_set_id  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col) INTO all_dest_well_ids;


FOR w IN 1..array_length(all_source_well_ids,1)  LOOP
SELECT sample.id FROM sample, well, well_sample WHERE well_sample.well_id=well.id AND well_sample.sample_id=sample.id AND well.id= all_source_well_ids[w] INTO holder;
INSERT INTO well_sample (well_id, sample_id) VALUES (all_dest_well_ids[w], holder );


--RAISE notice  'w: (%)', w;
--RAISE notice  'all_source_well_ids[w]: (%)', all_source_well_ids[w];
--RAISE notice  'all_dest_well_ids[w]: (%)', all_dest_well_ids[w];

END LOOP;

DROP TABLE temp1;

RETURN dest_plate_set_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


-------update raw data with normalized


DROP FUNCTION IF exists process_assay_run_data(_assay_run_id integer);

CREATE OR REPLACE FUNCTION process_assay_run_data(_assay_run_id integer)
  RETURNS void AS
$BODY$
DECLARE
   plates INTEGER[];   
   background decimal;
   positives decimal;
   negatives DECIMAL;
   unk_max DECIMAL;
   norm_factor DECIMAL;
   format INTEGER;
BEGIN

CREATE TEMP TABLE data_set  ON COMMIT DROP AS SELECT assay_result.assay_run_id, assay_result.plate_order, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = _assay_run_id AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = _assay_run_id);

SELECT ARRAY (SELECT distinct plate_order FROM data_set WHERE data_set.assay_run_id = _assay_run_id  ORDER BY plate_order) INTO plates;

FOR plate_var IN 1..array_length(plates,1) LOOP

SELECT AVG(data_set.response) FROM data_set WHERE data_set.plate_order = plate_var AND data_set.well_type_id=2 INTO positives;
SELECT AVG(data_set.response) FROM data_set WHERE data_set.plate_order = plate_var AND data_set.well_type_id=3 INTO negatives;
SELECT AVG(data_set.response) FROM data_set WHERE data_set.plate_order = plate_var AND data_set.well_type_id=4 INTO background;
SELECT MAX(data_set.response) FROM data_set WHERE data_set.plate_order = plate_var AND data_set.well_type_id=1 INTO unk_max;

SELECT plate_layout_name.plate_format_id FROM plate_layout_name, assay_run WHERE assay_run.plate_layout_name_id=plate_layout_name.ID AND assay_run.id=_assay_run_id INTO format;

       FOR well_var IN 1..format LOOP

          UPDATE assay_result SET bkgrnd_sub  = (assay_result.response-background), norm = ((assay_result.response-background)/unk_max), norm_pos = ((response-background)/positives) WHERE assay_result.assay_run_id=_assay_run_id AND assay_result.plate_order=plate_var AND assay_result.well = well_var;

   END LOOP;

END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--------scatter plot data

DROP FUNCTION IF exists get_scatter_plot_data( integer);

CREATE OR REPLACE FUNCTION get_scatter_plot_data(_assay_run_id INTEGER)
RETURNS TABLE(  plate INTEGER, well INTEGER, response REAL, bkgrnd_sub REAL,   norm REAL,   norm_pos REAL,  well_type_id INTEGER,  replicates integer, target integer, sample_id integer ) AS
$BODY$
begin

CREATE TEMPORARY TABLE temp1 AS (SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result JOIN plate_layout ON ( assay_result.well = plate_layout.well_by_col) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = _assay_run_id AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id);


CREATE TEMPORARY TABLE temp2 AS (SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample, assay_run, sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID AND well_sample.sample_id=sample.id AND plate_plate_set.plate_set_id = assay_run.plate_set_id AND assay_run.ID = _assay_run_id);


RETURN query
  SELECT temp1.plate_order,temp1.well, temp1.response, temp1.bkgrnd_sub, temp1.norm, temp1.norm_pos, temp1.well_type_id, temp1.replicates, temp1.target, temp2.sample_id FROM temp1 LEFT OUTER JOIN temp2 on (temp1.plate_order=temp2.plate_order AND temp1.well= temp2.by_col);

DROP TABLE temp1;
DROP TABLE temp2;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--create hit lists


CREATE OR REPLACE FUNCTION new_hit_list(_name VARCHAR, _descr VARCHAR, _num_hits INTEGER, _assay_run_id INTEGER, hit_list integer[])
  RETURNS void AS
$BODY$
DECLARE
 hl_id INTEGER;
 hl_sys_name VARCHAR(10);
 s_id INTEGER;
BEGIN


  INSERT INTO hit_list(hitlist_name, descr, n, assay_run_id)
   VALUES (_name, _descr, _num_hits, _assay_run_id)
   RETURNING id INTO hl_id;

    UPDATE hit_list SET hitlist_sys_name = 'HL-'|| hl_id WHERE id=hl_id;
    
FOR i IN 1.._num_hits loop
 INSERT INTO hit_sample(hitlist_id, sample_id)VALUES(hl_id, hit_list[i]);
END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


------------------------------------------------------

DROP FUNCTION process_access_ids( INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION process_access_ids(ps_id INTEGER, sql_statement VARCHAR )
 RETURNS SETOF temp_accs_id AS
$BODY$
DECLARE
  r temp_accs_id%rowtype;
BEGIN

TRUNCATE temp_accs_id RESTART IDENTITY CASCADE;

--RAISE notice 'sql: (%)', sql_statement;
execute sql_statement;


   FOR r IN
      SELECT * FROM temp_accs_id
   loop

UPDATE sample SET accs_id = r.accs_id WHERE sample.ID IN ( SELECT sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=ps_id AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID AND plate_plate_set.plate_order=r.plate_order AND well.by_col=r.by_col);


       RETURN NEXT r;
   END LOOP;

TRUNCATE temp_accs_id RESTART IDENTITY CASCADE;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE;

------------------------------------------------------
--called from DialogRearrayHitList

DROP FUNCTION rearray_transfer_samples(integer, INTEGER, integer);
CREATE OR REPLACE FUNCTION rearray_transfer_samples(source_plate_set_id INTEGER, dest_plate_set_id INTEGER, hit_list_id integer)
 RETURNS void AS
$BODY$
DECLARE
   i INTEGER;
all_hit_sample_ids INTEGER[];
dest_wells INTEGER[];
num_hits INTEGER;
rp_id INTEGER;


BEGIN
--select get in plate, well order, not necessarily sample order 
SELECT ARRAY (SELECT  sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=source_plate_set_id AND sample.ID  IN  (SELECT hit_sample.sample_id FROM hit_sample WHERE hit_sample.hitlist_id = hit_list_id) ORDER BY plate.ID, well.ID) INTO all_hit_sample_ids;

num_hits := array_length(all_hit_sample_ids, 1);
--raise NOTice 'num_hits: (%)', num_hits;

SELECT ARRAY (SELECT well.ID FROM plate_set, plate_plate_set, plate, well, plate_layout WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND plate_set.plate_layout_name_id=plate_layout.plate_layout_name_id AND plate_layout.well_by_col= well.by_col AND plate_set.id=dest_plate_set_id AND plate_layout.well_type_id=1 ORDER BY well.ID) INTO dest_wells;


  for i IN 1..num_hits
  loop
  INSERT INTO well_sample (well_id, sample_id) VALUES ( dest_wells[i], all_hit_sample_ids[i]);   
raise NOTice 'dest_well: (%)', dest_wells[i];
raise NOTice 'sample: (%)', all_hit_sample_ids[i];


END LOOP;

INSERT INTO rearray_pairs (src, dest) VALUES (source_plate_set_id, dest_plate_set_id)  returning id INTO rp_id;

CREATE TEMP TABLE temp1 (plate_sys_name VARCHAR(10), by_col INTEGER, sample_id INTEGER);

INSERT INTO temp1 SELECT  plate.plate_sys_name, well.by_col, sample.ID AS "sample_id"  FROM plate_set, plate_plate_set, plate, well, well_sample, sample  WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=source_plate_set_id  AND sample.ID IN  (SELECT hit_sample.sample_id FROM hit_sample WHERE hit_sample.hitlist_id = hit_list_id ORDER BY sample.ID);

CREATE TEMP TABLE temp2 (plate_sys_name VARCHAR(10), by_col INTEGER, sample_id INTEGER);

INSERT INTO temp2 SELECT  plate.plate_sys_name, well.by_col, sample.ID AS "sample_id" FROM plate_set, plate_plate_set, plate, well, well_sample, sample  WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=dest_plate_set_id  ORDER BY sample.ID;

INSERT INTO worklists ( rearray_pairs_id, sample_id, source_plate, source_well, dest_plate, dest_well) SELECT rp_id, temp1.sample_id, temp1.plate_sys_name, temp1.by_col, temp2.plate_sys_name, temp2.by_col FROM temp1, temp2 WHERE temp1.sample_id = temp2.sample_id;

DROP TABLE temp1, temp2;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

---------------------------------------------------

DROP FUNCTION create_layout_records(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, INTEGER, integer );
CREATE OR REPLACE FUNCTION create_layout_records(source_name VARCHAR, source_description VARCHAR, control_location VARCHAR, n_controls INTEGER, n_unknowns INTEGER, format INTEGER, n_edge integer)
 RETURNS void AS
$BODY$
DECLARE
   source_id INTEGER;
   dest_id INTEGER;
   edge INTEGER;
dest_layout_ids INTEGER[];
dest_layout_descr VARCHAR[] := '{"1S4T","2S2T","2S4T","4S1T","4S2T"}';
dest_format INTEGER;
i INTEGER;

BEGIN

IF n_edge >0 THEN edge = 0; ELSE edge = 1; END IF;

IF format = 96 THEN
dest_layout_ids := '{2,3,4,5,6}';
dest_format := 384;
END IF;

IF format = 384 THEN
dest_layout_ids := '{14,15,16,17,18}';
dest_format := 1536;
END IF;

INSERT INTO plate_layout_name (NAME, descr, plate_format_id, replicates, targets, use_edge, num_controls, unknown_n, control_loc, source_dest) VALUES (source_name, source_description, format, 1, 1, edge, n_controls, n_unknowns, control_location, 'source') RETURNING ID INTO source_id;

    UPDATE plate_layout_name SET sys_name = 'LYT-'|| source_id WHERE id=source_id;

--insert source
INSERT INTO plate_layout (SELECT source_id AS "plate_layout_name_id", well_by_col, well_type_id, replicates, target FROM import_plate_layout); 


--insert destinations
FOR i IN 1..5 loop
INSERT INTO plate_layout_name ( descr, plate_format_id, replicates, targets, use_edge, num_controls, unknown_n, control_loc, source_dest) VALUES ( dest_layout_descr[i], dest_format, 1, 1, edge, n_controls, n_unknowns, control_location, 'dest') RETURNING ID INTO dest_id;
 UPDATE plate_layout_name SET sys_name = 'LYT-'|| dest_id WHERE id=dest_id;

INSERT INTO plate_layout (SELECT dest_id AS "plate_layout_name_id", well_numbers.by_col AS "well_by_col", import_plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM well_numbers, import_plate_layout, plate_layout WHERE well_numbers.plate_format = dest_format AND import_plate_layout.well_by_col=well_numbers.parent_well AND plate_layout.plate_layout_name_id=dest_layout_ids[i] AND plate_layout.well_by_col=well_numbers.by_col);


INSERT INTO layout_source_dest (src, dest) VALUES (source_id, dest_id);
END LOOP;
--


TRUNCATE TABLE import_plate_layout;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
