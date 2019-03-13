-- -*- mode: sql; sql-product: postgres; -*-

--https://postgres.cz/wiki/PostgreSQL_SQL_Tricks

// table assay_result: sample_id, response, assay_run_id
    // table temp_data: plate, well, response
    // table assay_run: id, plate_set_id, plate_layout_name_id
    // plate_layout:  plate_layout_name_id, well_by_col, well_type_id
    // plate:  id plate_sys_name | plate_type_id | project_id | plate_format_id 
    // plate_set: id  plate_set_name   | plate_set_sys_name | num_plates | plate_format_id | plate_type_id | project_id 
    // well: plate_id id  well_name
    // sample: id
    // well_sample:  well_id  sample_id
    // well_type: id  name
    // well_numbers: format  well_name  by_col 
    // plate_plate_set: plate_set_id | plate_id | plate_order 


20 plates 96 well format into
5 plates 384 well format

plate_set.id = 21   2 plates
plate_set.id = 31   2 plates


--DialogReformatPlateSet provides  dmf,  name, description new_plate_format_id, type_id, layout_id
			   --old_plate_set_id, old_num_plates

SELECT * FROM plate_set WHERE plate_set.id = 21;
SELECT * FROM well LIMIT 5;

SELECT well.plate_id, well.well_name, well.ID, sample.id FROM plate_plate_set, well, well_sample, sample  WHERE plate_plate_set.plate_set_id = 21 AND plate_plate_set.plate_id = well.plate_id AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.id ORDER BY plate_plate_set.plate_order, well.ID;

select datname,datacl from pg_database where datname = 'pmdb';
GRANT TEMPORARY on DATABASE pmdb TO pm_admin;
​
SELECT well.plate_id, well.well_name, well.id INTO mytemp2 FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = 21 AND plate_plate_set.plate_id = well.plate_id   ORDER BY plate_plate_set.plate_order, well.ID;

CREATE TEMP TABLE temp1 AS SELECT well_name, by_col, quad FROM well_numbers WHERE plate_format=384;



CREATE TEMP TABLE sources(plate_id INT, well_name VARCHAR(10), well_id INT);

FOR i IN 1..n_reps_source loop
INSERT INTO sources select well.plate_id, well.well_name, well.id  FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = source_plate_set_id AND plate_plate_set.plate_id = well.plate_id   ORDER BY plate_plate_set.plate_order, well.ID;
END LOOP;

--------------------------------------

--CREATE OR REPLACE FUNCTION new_plate_set(_descr VARCHAR(30),_plate_set_name VARCHAR(30), _num_plates INTEGER, _plate_format_id INTEGER, _plate_type_id INTEGER, _project_id INTEGER, _plate_layout_name_id INTEGER, _with_samples boolean)
 -- RETURNS integer AS



DROP FUNCTION IF exists reformat_plate_set(source_plate_set_id INTEGER, source_num_plates INTEGER, n_reps_source INTEGER, dest_descr VARCHAR(30), dest_plate_set_name VARCHAR(30), dest_num_plates INTEGER, dest_plate_format_id INTEGER, dest_plate_type_id INTEGER, project_id INTEGER, dest_plate_layout_name_id INTEGER );

CREATE OR REPLACE FUNCTION reformat_plate_set(source_plate_set_id INTEGER, source_num_plates INTEGER, n_reps_source INTEGER, dest_descr VARCHAR(30), dest_plate_set_name VARCHAR(30), dest_num_plates INTEGER, dest_plate_format_id INTEGER, dest_plate_type_id INTEGER, project_id INTEGER, dest_plate_layout_name_id INTEGER )
 RETURNS void AS
$BODY$
DECLARE

dest_plate_set_id INTEGER;
all_source_well_ids INTEGER[];
all_dest_well_ids INTEGER[];
 w INTEGER;

BEGIN
--here I am creating the destination plate set, no samples included
SELECT new_plate_set(dest_descr ,dest_plate_set_name, dest_num_plates, dest_plate_format_id, dest_plate_type_id, project_id, dest_plate_layout_name_id, false) INTO dest_plate_set_id;

RAISE notice 'dest_plate_set_id: (%)', dest_plate_set_id;

CREATE TEMP TABLE sources(plate_id INT, well_name VARCHAR(10), well_id INT);

FOR i IN 1..n_reps_source loop
INSERT INTO sources select well.plate_id, well.well_name, well.id AS well_id FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = source_plate_set_id AND plate_plate_set.plate_id = well.plate_id   ORDER BY plate_plate_set.plate_order, well.ID;
END LOOP;

SELECT ARRAY (SELECT well_id FROM sources) INTO all_source_well_ids;

RAISE notice 'all_source_well_ids[0]: (%)', all_source_well_ids[0];
RAISE notice 'all_source_well_ids[1]: (%)', all_source_well_ids[1];
RAISE notice 'all_source_well_ids[2]: (%)', all_source_well_ids[2];
RAISE notice 'all_source_well_ids[3]: (%)', all_source_well_ids[3];


SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = 40  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col) INTO all_dest_well_ids;

RAISE notice 'all_dest_well_ids[0]: (%)', all_dest_well_ids[0];
RAISE notice 'all_dest_well_ids[1]: (%)', all_dest_well_ids[1];
RAISE notice 'all_dest_well_ids[2]: (%)', all_dest_well_ids[2];
RAISE notice 'all_dest_well_ids[3]: (%)', all_dest_well_ids[3];


   FOREACH w  IN ARRAY all_source_well_ids LOOP
INSERT INTO well_sample (well_id, sample_id) VALUES
(all_dest_well_ids[w], (SELECT sample.ID FROM sample, well, well_sample WHERE well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID AND well.ID= all_source_well_ids[w] ));

END LOOP;

DROP TABLE sources;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


------------------------------------

DROP TABLE sources;
--DROP TABLE dest;

SELECT reformat_plate_set(21, 4, 31 );


SELECT * FROM sources LIMIT 5;
SELECT * FROM dest LIMIT 5;

SELECT COUNT(*) FROM well_sample;


SELECT dest.plate_id AS dest_plate_id, dest.well_name AS dest_well_name, dest.well_id AS dest_well_id, by_col, quad FROM dest JOIN temp1 ON(dest.well_name = temp1.well_name) ORDER BY dest.plate_id, temp1.quad, temp1.by_col;


Create TEMP TABLE temp2 as (SELECT dest.plate_id AS dest_plate_id, dest.well_name AS dest_well_name, dest.well_id AS dest_well_id, by_col, quad FROM dest JOIN temp1 ON(dest.well_name = temp1.well_name) ORDER BY dest.plate_id, temp1.quad, temp1.by_col);


SELECT * FROM well WHERE well.plate_id =406;

SELECT new_plate_set('descr','name', 1, 384, 1, 1, 2, FALSE) INTO ps_id;

SELECT reformat_plate_set( 21, 2, 2, 'ertertertert', 'ertertertert', 1, 384, 1, 1, 4);

-------------------

CREATE TEMP TABLE dest(plate_id INT, well_name VARCHAR(10), well_id INT);

INSERT INTO dest  SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = 40  AND plate_plate_set.plate_id = well.plate_id;


CREATE TEMP TABLE temp_w_n(well_name VARCHAR(10), by_col INT, quad INT);

INSERT INTO temp_w_n SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=384;

--get the array of well ids here
SELECT plate_id, well_id, by_col, quad   FROM dest JOIN temp_w_n ON(dest.well_name=temp_w_n.well_name) ORDER BY plate_id, quad, by_col;


--this works
SELECT plate_id, well_id, by_col, quad   FROM dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=384)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col;

--this works
SELECT plate_id, dest.id, by_col, quad   FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = 40  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=384)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col;


