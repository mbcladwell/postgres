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

RAISE notice 'dest_plate_set_id: (%)', dest_plate_set_id;

CREATE TEMP TABLE temp1(plate_id INT, well_name VARCHAR(10), well_id INT);

FOR i IN 1..n_reps_source LOOP
INSERT INTO temp1 select well.plate_id, well.well_name, well.id AS well_id FROM plate_plate_set, well  WHERE plate_plate_set.plate_set_id = source_plate_set_id AND plate_plate_set.plate_id = well.plate_id   ORDER BY plate_plate_set.plate_order, well.ID;
END LOOP;

SELECT ARRAY (SELECT well_id FROM temp1) INTO all_source_well_ids;


SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = dest_plate_set_id  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col) INTO all_dest_well_ids;


FOR w IN 1..array_length(all_source_well_ids,1)  LOOP
SELECT sample.id FROM sample, well, well_sample WHERE well_sample.well_id=well.id AND well_sample.sample_id=sample.id AND well.id= all_source_well_ids[w] INTO holder;
INSERT INTO well_sample (well_id, sample_id) VALUES (all_dest_well_ids[w], holder );


RAISE notice  'w: (%)', w;
RAISE notice  'all_source_well_ids[w]: (%)', all_source_well_ids[w];
RAISE notice  'all_dest_well_ids[w]: (%)', all_dest_well_ids[w];

END LOOP;

DROP TABLE temp1;

RETURN dest_plate_set_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


------------------------------------

SELECT reformat_plate_set( 21, 2, 2, 'ertertertert', 'ertertertert', 1, 384, 1, 1, 4);





--this works
SELECT plate_id, well_id, by_col, quad   FROM dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=384)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col;

--this works
SELECT plate_id, dest.id, by_col, quad   FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = 40  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=384)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col;


 SELECT * FROM plate_plate_set WHERE plate_plate_set.plate_set_id = 23;

 SELECT * FROM plate WHERE plate.ID = 405;
 
SELECT * FROM well WHERE well.plate_id =405;

SELECT * FROM well_sample, well, sample WHERE well.plate_id =405 AND well.ID = well_sample.well_id AND sample.ID = well_sample.sample_id;

SELECT * FROM well_sample WHERE well_sample.sample_id = 263110;

  FOREACH w  IN ARRAY all_source_well_ids LOOP
INSERT INTO well_sample (well_id, sample_id) VALUES
(all_dest_well_ids[w], (SELECT sample.ID FROM sample, well, well_sample WHERE well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID AND well.ID= all_source_well_ids[w] ));

SELECT sample.ID FROM sample, well, well_sample WHERE well_sample.well_id=well.id AND well_sample.sample_id=sample.ID AND well.ID= 268801;


INSERT INTO well_sample (well_id, sample_id) VALUES (274849, 263041);

SELECT plate.id FROM plate WHERE plate.plate_sys_name = 'PLT-401';

SELECT * FROM well WHERE well.plate_id=403;


SELECT * FROM well_sample, well WHERE well.plate_id=403 AND well.ID = well_sample.well_id;


SELECT new_plate_set('descr','name', 1, 384, 1, 1, 2, FALSE) INTO ps_id2;
SELECT * FROM sample;
