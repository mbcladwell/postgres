-- -*- mode: sql; sql-product: postgres; -*-

--https://postgres.cz/wiki/PostgreSQL_SQL_Tricks

-- assay_result:    assay_run_id  plate(plate_order)  well  response  bkgrnd_sub    norm   norm_pos 
-- assay_run:       id  assay_run_sys_name  assay_run_name  assay_type_id  plate_set_id  plate_layout_name_id
-- plate_layout:    plate_layout_name_id  well_by_col, well_type_id replicates  target
-- plate:           id plate_sys_name   plate_type_id   project_id   plate_format_id 
-- plate_set:       id   plate_set_name  plate_set_sys_name  num_plates  plate_format_id  plate_type_id  project_id  plate_layout_name_id
-- well:            id  plate_id  well_name
-- sample:          id
-- well_sample:     well_id  sample_id
-- well_type:       id  name
-- well_numbers:    plate_format  well_name  by_col quad 
-- plate_plate_set: plate_set_id   plate_id   plate_order
-- plate_layout_name  id  plate_format_id  replicates  targets  use_edge  num_controls control_loc source_dest 


--https://stackoverflow.com/questions/17864911/return-setof-rows-from-postgresql-function


SELECT * FROM well_numbers LIMIT 5;
SELECT * FROM plate_set WHERE plate_set.id=5;  LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM plate_plate_set LIMIT 5;
SELECT * FROM well LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM sample LIMIT 5;
SELECT * FROM assay_run WHERE assay_run.ID = 3  LIMIT 5;
SELECT * FROM assay_result WHERE assay_result.assay_run_ID = 3 limit   5;
SELECT * FROM plate_layout_name;

SELECT *  FROM assay_result, assay_run WHERE assay_result.assay_run_id=assay_run.ID and assay_run.ID IN (3,2,1);

LIMIT 5;


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
SELECT new_plate_set(dest_descr ,dest_plate_set_name, dest_num_plates, dest_plate_format_id, dest_plate_type_id, project_id, dest_plate_layout_name_id, lnsession_id, false) INTO dest_plate_set_id;

--RAISE notice 'dest_plate_set_id: (%)', dest_plate_set_id;

CREATE TEMP TABLE temp1(counter INT, plate_id INT, plate_order INT, well_by_col INT, well_id INT);

FOR i IN 1..n_reps_source LOOP
INSERT INTO temp1 select i, well.plate_id, plate_plate_set.plate_order, well.by_col, well.id AS well_id FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = source_plate_set_id AND plate_plate_set.plate_id = well.plate_id   ORDER BY well.plate_id, well.ID;
END LOOP;



SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.by_col,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = dest_plate_set_id  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.by_col=foo.by_col) ORDER BY plate_id, quad, dest.by_col) INTO all_dest_well_ids;


FOR w IN 1..array_length(all_source_well_ids,1)  LOOP
SELECT sample.id FROM sample, well, well_sample WHERE well_sample.well_id=well.id AND well_sample.sample_id=sample.id AND well.id= all_source_well_ids[w] INTO holder;
INSERT INTO well_sample (well_id, sample_id) VALUES (all_dest_well_ids[w], holder );


--RAISE notice  'w: (%)', w;
--RAISE notice  'all_source_well_ids[w]: (%)', all_source_well_ids[w];
--RAISE notice  'all_dest_well_ids[w]: (%)', all_dest_well_ids[w];

END LOOP;

--RAISE notice  'all_source_well_ids: (%)', all_source_well_ids;
--RAISE notice  'all_dest_well_ids: (%)', all_dest_well_ids;


DROP TABLE temp1;

RETURN dest_plate_set_id;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;



-----------------my query

--this query provides a full assay run of data annotated with sample ids
--left join includes control wells
DROP FUNCTION  get_all_data_for_assay_run(_assay_run_ids INTEGER );
CREATE OR REPLACE FUNCTION get_all_data_for_assay_run(_assay_run_id INTEGER )
RETURNS TABLE(assay_run_sys_name VARCHAR,  plate_set_sys_name VARCHAR(32),  plate_sys_name VARCHAR(32), plate_order INT, well_name VARCHAR,   by_col INTEGER, response REAL, bkgrnd_sub REAL, norm REAL, norm_pos REAL, p_enhance REAL, sample_sys_name VARCHAR(32) ) AS
$BODY$
DECLARE

v_assay_run_ids INTEGER := _assay_run_id;
v_plate_set_id INTEGER;
v_plate_format INTEGER;

BEGIN

SELECT assay_run.plate_set_id FROM assay_run WHERE assay_run.ID =v_assay_run_id INTO v_plate_set_id;
SELECT plate_layout_name.plate_format_id FROM plate_layout_name, assay_run WHERE plate_layout_name.ID= assay_run.plate_layout_name_id AND assay_run.ID =v_assay_run_id INTO v_plate_format;

--get the plate set
CREATE TEMP TABLE plate_set_data(assay_run_sys_name VARCHAR, plate_set_sys_name VARCHAR, plate_sys_name VARCHAR, plate_order INT, well_name VARCHAR, by_col INT, well_id INT, response REAL, bkgrnd_sub REAL, norm REAL, norm_pos REAL, p_enhance REAL );

INSERT INTO plate_set_data SELECT assay_run.assay_run_sys_name, plate_set.plate_set_sys_name , plate.plate_sys_name, plate_plate_set.plate_order, well_numbers.well_name, well.by_col, well.ID AS "well_id", assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_result.p_enhance  FROM  plate_set, plate_plate_set, plate, well, assay_result, assay_run, well_numbers WHERE plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and plate.id=well.plate_id  AND plate_set.ID = v_plate_set_id AND assay_result.assay_run_id= v_assay_run_id AND assay_result.plate_order=plate_plate_set.plate_order AND assay_result.well=well.by_col AND assay_run.ID = v_assay_run_id AND well_numbers.plate_format= v_plate_format AND well_numbers.by_col=well.by_col;

CREATE TEMP TABLE sample_names(well_id INT, sample_sys_name VARCHAR);

INSERT INTO sample_names SELECT well.ID AS "well_id", sample.sample_sys_name  FROM well, well_sample, sample WHERE well_sample.sample_id=sample.ID AND well_sample.well_id=well.ID AND well.ID IN (SELECT well.ID FROM  plate_plate_set, plate, well WHERE plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.ID AND plate_plate_set.plate_set_id = v_plate_set_id);


RETURN query
  SELECT  plate_set_data.assay_run_sys_name,  plate_set_data.plate_set_sys_name, plate_set_data.plate_sys_name, plate_set_data.plate_order, plate_set_data.well_name, plate_set_data.by_col, plate_set_data.response, plate_set_data.bkgrnd_sub, plate_set_data.norm, plate_set_data.norm_pos, plate_set_data.p_enhance, sample_names.sample_sys_name FROM plate_set_data LEFT JOIN sample_names on (plate_set_data.well_id=sample_names.well_id) ORDER BY plate_set_data.plate_order desc, plate_set_data.by_col DESC;

DROP TABLE plate_set_data;
DROP TABLE sample_names;


END;
$BODY$
LANGUAGE plpgsql VOLATILE;

----

SELECT * from get_all_data_for_assay_run(2);


SELECT * FROM plate_set WHERE plate_set.id=5;  LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM plate_plate_set LIMIT 5;
SELECT * FROM well LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM sample LIMIT 5;
SELECT * FROM well_numbers LIMIT 5;
SELECT * FROM assay_result LIMIT 5;



SELECT well.ID AS "well_id", sample.sample_sys_name  FROM well, well_sample, sample WHERE well_sample.sample_id=sample.ID AND well_sample.well_id=well.ID AND well.ID IN (SELECT well.ID FROM  plate_plate_set, plate, well WHERE plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.ID AND plate_plate_set.plate_set_id =1);




SELECT assay_run.assay_run_sys_name, plate_set.plate_set_sys_name , plate.plate_sys_name, plate_plate_set.plate_order, well_numbers.well_name, well.by_col, well.ID AS "well_id", assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_result.p_enhance  FROM  plate_set, plate_plate_set, plate, well, assay_result, assay_run, well_numbers WHERE plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and plate.id=well.plate_id  AND plate_set.ID = 1 AND assay_result.assay_run_id=3 AND assay_result.plate_order=plate_plate_set.plate_order AND assay_result.well=well.by_col AND well_numbers.plate_format=96 AND assay_run.ID = 3 AND well_numbers.by_col=well.by_col ;




















---this works
DROP FUNCTION  get_all_data_for_assay_run(_assay_run_id INTEGER );
CREATE OR REPLACE FUNCTION get_all_data_for_assay_run(_assay_run_id INTEGER )
--RETURNS TABLE(  plate_set_sys_name VARCHAR,  plate_sys_name VARCHAR, well_name VARCHAR,  well INTEGER, response REAL, bkgrnd_sub REAL,   norm REAL,   norm_pos REAL, p_enhance REAL,  well_type_id INTEGER,  replicates integer, target integer, sample_id integer ) AS
RETURNS TABLE(  plate_set_sys_name VARCHAR(32),  plate_sys_name VARCHAR(32),  by_col INTEGER, well_name VARCHAR(32), response REAL ) AS
$BODY$
DECLARE

v_assay_run_id INTEGER := _assay_run_id;
v_plate_set_id INTEGER;
v_plate_format INTEGER;

BEGIN

SELECT assay_run.plate_set_id FROM assay_run WHERE assay_run.ID =v_assay_run_id INTO v_plate_set_id;
SELECT plate_layout_name.plate_format_id FROM plate_layout_name, assay_run WHERE plate_layout_name.ID= assay_run.plate_layout_name_id AND assay_run.ID =v_assay_run_id INTO v_plate_format;

--get the plate set
CREATE TEMP TABLE plate_set_data(plate_set_sys_name VARCHAR, plate_sys_name VARCHAR, plate_order INT, by_col INT, sample_sys_name VARCHAR );

INSERT INTO plate_set_data SELECT plate_set.plate_set_sys_name , plate.plate_sys_name, plate_plate_set.plate_order, well.by_col  FROM  plate_set, plate_plate_set, plate, well, well_sample, sample  WHERE plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and plate.id=well.plate_id  AND plate_set.ID = v_plate_set_id AND well_sample.sample_id=sample.ID AND well_sample.well_id=well.id;

CREATE TEMP TABLE well_num_data(well_name VARCHAR,  by_col INT );
INSERT INTO well_num_data SELECT well_numbers.well_name, well_numbers.by_col FROM well_numbers WHERE well_numbers.plate_format = v_plate_format;

CREATE TEMP TABLE assay_run_data(  plate_order INTEGER, well INTEGER, response REAL,  bkgrnd_sub  REAL, norm REAL, norm_pos REAL, p_enhance  REAL );
INSERT INTO assay_run_data  SELECT assay_result.plate_order, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_result.p_enhance FROM assay_result WHERE assay_result.assay_run_id = v_assay_run_id;


RETURN query
  SELECT  plate_set_data.plate_set_sys_name ,  plate_set_data.plate_sys_name ,  plate_set_data.by_col, well_num_data.well_name, assay_run_data.response FROM plate_set_data JOIN well_num_data on (plate_set_data.by_col=well_num_data.by_col) JOIN assay_run_data on (well_num_data.by_col=assay_run_data.well  AND  plate_set_data.plate_order= assay_run_data.plate_order) ;

DROP TABLE plate_set_data;
DROP TABLE well_num_data;
DROP TABLE assay_run_data;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;


