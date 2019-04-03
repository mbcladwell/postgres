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

SELECT * FROM assay_result LIMIT 5;
SELECT * FROM assay_run LIMIT 5;
SELECT * FROM plate_layout LIMIT 5;
SELECT * FROM plate_layout_name LIMIT 5;
SELECT * FROM well_numbers LIMIT 5;


SELECT * FROM plate_set WHERE plate_set.ID = 10;
SELECT * FROM plate_plate_set WHERE plate_plate_set.plate_set_ID = 10 LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM well LIMIT 5;

--https://stackoverflow.com/questions/17864911/return-setof-rows-from-postgresql-function
---------------------------

--get assay runs for project

SELECT * FROM assay_run;
SELECT * FROM plate_set LIMIT 5;
SELECT * FROM assay_type LIMIT 5;


SELECT assay_run.assay_run_sys_name AS "Sys-NAME", assay_run.assay_run_name AS "NAME", assay_run.descr AS "Description", assay_type.assay_type_name AS "Assay TYPE", plate_set.plate_set_sys_name  FROM assay_run, plate_set, assay_type WHERE assay_run.assay_type_id=assay_type.id AND assay_run.plate_set_id= plate_set.ID AND plate_set.project_id=10;


SELECT * FROM hit_list LIMIT 5;
SELECT * FROM hit_sample LIMIT 5;


SELECT hit_list.hitlist_sys_name AS "Sys-NAME", hit_list.hitlist_name AS "NAME", hit_list.descr AS "Description", assay_run.assay_run_sys_name AS "Assay Run ID", plate_set.plate_set_sys_name  FROM assay_run, plate_set, hit_list WHERE hit_list.assay_run_id= assay_run.id AND assay_run.plate_set_id= plate_set.ID AND plate_set.project_id=10;


-- get hit counts for plate set

-- input poject id and hit list id

SELECT sample_id FROM hit_sample, hit_list WHERE hit_list.ID= hit_sample.hitlist_id AND hit_list.id=1;


SELECT * FROM plate_set WHERE plate_set.project_id=10;
-- use plateset ids 1 through 10
-- get all the sample ids from plate_set 10
SELECT * FROM well_sample LIMIT 5;


SELECT plate_plate_set.plate_id, well.id FROM plate_plate_set, well WHERE plate_plate_set.plate_id=well.plate_id and plate_plate_set.plate_set_id=10;

-----

DROP FUNCTION get_hit_counts_for_plate_sets(integer,INTEGER);
CREATE OR REPLACE FUNCTION get_hit_counts_for_plate_sets(project_id INTEGER, hit_list_id INTEGER)
 RETURNS INTEGER[][] AS
$BODY$
DECLARE
plate_sets INTEGER[];
i INTEGER;
results INTEGER[][];
temp_count INTEGER;
BEGIN

--get all the plate sets within a given project
SELECT ARRAY (SELECT plate_set.ID FROM project, plate_set WHERE plate_set.project_id = project.id) INTO plate_sets;

FOR i IN 1..array_length(plate_sets,1) loop
select COUNT(*) FROM plate_plate_set, plate, hit_list, hit_sample, well_sample, well, sample, assay_run where plate_plate_set.plate_id=plate.id and plate_plate_set.plate_set_id=plate_sets[i] AND  well.plate_id=plate.ID AND  well_sample.well_id=well.ID AND well_sample.sample_id = sample.ID and  hit_sample.sample_id = sample.id  and hit_list.ID= hit_sample.hitlist_id AND hit_list.id=hit_list_id AND  INTO temp_count;

RAISE notice 'results[i]: (%)', results[i];
--RAISE notice 'temp_count: (%)', temp_count;

END LOOP;

RETURN results;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT get_hit_counts_for_plate_sets(10, 1);



SELECT * FROM plate_plate_set;
SELECT * FROM plate_set LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM well  LIMIT 5;
SELECT * FROM plate_well LIMIT 5;
SELECT * FROM hit_list;
SELECT * FROM assay_run LIMIT 5;


SELECT plate_set.ID, sample.id FROM plate_set, plate_plate_set, plate, hit_list, hit_sample, well_sample, well, sample, assay_run WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id  AND  well.plate_id=plate.ID AND  well_sample.well_id=well.ID AND well_sample.sample_id = sample.ID and  hit_sample.sample_id = sample.ID   and hit_list.ID= hit_sample.hitlist_id AND assay_run.plate_set_id=plate_set.ID AND hit_list.assay_run_id=assay_run.ID AND  plate_set.project_id=10 limit 20;

SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10;

-- get all plate sets in a project
SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10;

--this gets all samples from a plate set
SELECT plate_set.ID, plate.ID, well.ID, sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=1;


--get all samples in a hit list
SELECT sample_id FROM hit_sample WHERE hit_sample.hitlist_id=1;


SELECT plate_set.ID, plate.ID, well.ID, sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=1;

--get all hit lists in a project

SELECT plate_set.plate_set_sys_name, COUNT(sample.id) FROM hit_list, hit_sample, plate_set, assay_run, sample WHERE hit_sample.hitlist_id=hit_list.id  AND hit_sample.sample_id=sample.id  and assay_run.plate_set_id=plate_set.id AND   hit_list.assay_run_id=assay_run.id   AND  hit_sample.hitlist_id IN (SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10))) GROUP BY plate_set.ID;

SELECT * FROM hit_list LIMIT 5;
SELECT * FROM assay_run LIMIT 5;
SELECT * FROM assay_result LIMIT 5;
SELECT * FROM hit_sample LIMIT 5;



















--save this
SELECT plate_set.plate_set_sys_name, COUNT(sample_id) FROM hit_list, hit_sample, plate_set WHERE hit_sample.hitlist_id IN (SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10))) GROUP BY plate_set.id;
