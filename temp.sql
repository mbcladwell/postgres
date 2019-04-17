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
 RETURNS table AS
$BODY$

BEGIN

SELECT plate_set.plate_set_sys_name, MAX(plate_type.plate_type_name), COUNT(sample.ID) FROM plate_set, plate_plate_set, plate_type, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND plate_set.plate_type_id = plate_type.id   and well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id= sample.ID  AND sample.id  IN (SELECT  sample.id FROM hit_list, hit_sample, plate_set, assay_run, sample WHERE hit_sample.hitlist_id=hit_list.id  AND hit_sample.sample_id=sample.id  and assay_run.plate_set_id=plate_set.id AND   hit_list.assay_run_id=assay_run.id   AND  hit_sample.hitlist_id IN (SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID AND hit_list.id=1 and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10)))) GROUP BY plate_set.plate_set_sys_name;


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

--all samples from a project
SELECT plate_set.ID, plate.ID, well.ID, sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.project_id=10;





SELECT plate_set.ID, plate.ID, well.ID, sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=1;

--get all hit lists in a project

SELECT plate_set.plate_set_sys_name, COUNT(sample.id) FROM hit_list, hit_sample, plate_set, assay_run, sample WHERE hit_sample.hitlist_id=hit_list.id  AND hit_sample.sample_id=sample.id  and assay_run.plate_set_id=plate_set.id AND   hit_list.assay_run_id=assay_run.id   AND  hit_sample.hitlist_id IN (SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=10))) GROUP BY plate_set.ID;



--this gets all samples in project
SELECT plate_set.plate_set_sys_name,  sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.project_id=10;



--get all samples in a hit list
SELECT hit_sample.hitlist_id AS "Hit List", sample.ID AS "Sample", sample.sample_sys_name AS "Sample Name", sample.accs_id AS "Accession" FROM hit_sample, sample WHERE hit_sample.hitlist_id=1 AND hit_sample.sample_id=sample.id;




SELECT * FROM hit_list LIMIT 5;
SELECT * FROM assay_run LIMIT 5;
SELECT * FROM assay_result LIMIT 5;
SELECT * FROM hit_sample LIMIT 5;
SELECT * FROM sample LIMIT 5;
SELECT * FROM plate_set LIMIT 5;
SELECT * FROM plate_plate_set LIMIT 5;
SELECT * FROM well LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM plate_layout LIMIT 5;

----make layouts


SELECT * FROM import_plate_layout;
SELECT * FROM plate_layout_name;

--insert the layout_name record
--insert the source layout; it is waiting in the temp
--create destination layouts for a source layout
--link source and destinations
DROP FUNCTION create_layout_records(VARCHAR, varchar);
CREATE OR REPLACE FUNCTION create_layout_records(source_name VARCHAR, source_description varchar)
 RETURNS void AS
$BODY$
DECLARE
   i INTEGER;
all_hit_sample_ids INTEGER[];
dest_wells INTEGER[];
num_hits INTEGER;
rp_id INTEGER;


BEGIN

INSERT INTO 




END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




------bug no wells in viewer
SELECT * FROM hit_list LIMIT 5;
SELECT * FROM assay_run LIMIT 5;
SELECT * FROM assay_result LIMIT 5;
SELECT * FROM hit_sample LIMIT 5;
SELECT * FROM sample LIMIT 5;
SELECT * FROM plate_set LIMIT 5;
SELECT * FROM plate_plate_set LIMIT 5;
SELECT * FROM well LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM plate_layout LIMIT 5;

--query that doesnot work:    403 works, 409 doesn't
      SELECT plate.plate_sys_name AS "PlateID", well_numbers.well_name AS "Well", well.by_col AS "Well_NUM", sample.sample_sys_name AS "Sample", sample.accs_id as "Accession" FROM  plate, sample, well_sample, well JOIN well_numbers ON ( well.by_col= well_numbers.by_col)  WHERE plate.id = well.plate_id AND well_sample.well_id=well.id AND well_sample.sample_id=sample.id AND well.plate_id = (SELECT plate.id FROM plate WHERE plate.plate_sys_name = 'PLT-409') AND  well_numbers.plate_format = (SELECT plate_format_id  FROM plate_set WHERE plate_set.ID =  (SELECT plate_set_id FROM plate_plate_set WHERE plate_id = 409 LIMIT 1) ) ORDER BY well.by_col DESC;

SELECT plate.id FROM plate WHERE plate.plate_sys_name = 'PLT-403';  --works for both

--works for both
SELECT plate_format_id  FROM plate_set WHERE plate_set.ID =  (SELECT plate_set_id FROM plate_plate_set WHERE plate_id = 403 LIMIT 1);


--reduced selection
 SELECT plate.plate_sys_name AS "PlateID", well_numbers.well_name AS "Well", well.by_col AS "Well_NUM", sample.sample_sys_name AS "Sample", sample.accs_id as "Accession" FROM  plate, sample, well_sample, well JOIN well_numbers ON ( well.by_col= well_numbers.by_col)  WHERE
 plate.id = well.plate_id AND
 well_sample.well_id=well.id AND
 well_sample.sample_id=sample.id AND
 well.plate_id = 403 AND
 well_numbers.plate_format = (SELECT plate_format_id  FROM plate_set WHERE plate_set.ID =  (SELECT plate_set_id FROM plate_plate_set WHERE plate_id = well.plate_id) )
 ORDER BY well.by_col DESC;



SELECT plate_format_id  FROM plate_set WHERE plate_set.ID =  (SELECT plate_set_id FROM plate_plate_set WHERE plate_id = 409);


 SELECT plate.plate_sys_name AS "PlateID", well.by_col AS "Well_NUM", sample.sample_sys_name  FROM  plate, sample, well_sample, well   WHERE
 plate.id = well.plate_id AND
 well_sample.well_id=well.id AND
 well_sample.sample_id=sample.id AND
 well.plate_id = 409;


 SELECT * FROM well WHERE plate_id = 403 LIMIT 5; --well is populated  well_ids are 268993 - 269088
 SELECT * FROM well_sample WHERE well_id = 269087;  --well_sample not populated!!!!

--the rearray function is rearray_transfer_samples(source_plate_set_id INTEGER, dest_plate_set_id INTEGER, hit_list_id integer)
SELECT rearray_transfer_samples(22,24  ,25);
 


--looking got counts in plate sets
--https://medium.com/@riccardoodone/the-love-hate-relationship-between-select-and-group-by-in-sql-4957b2a70229

MAX(plate_type.plate_type_name) as "TYPE",
plate_set.id as "ID",


SELECT  MAX(plate_set.plate_set_sys_name) as "Plate Set",  string_agg(plate_set.format_name, ',') as "Format", COUNT(sample.id) as "Count" FROM plate_set, plate_plate_set, plate_type, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND plate_set.plate_type_id = plate_type.id   and well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id= sample.ID  AND sample.id  IN (SELECT  sample.id FROM hit_list, hit_sample, plate_set, assay_run, sample WHERE hit_sample.hitlist_id=hit_list.id  AND hit_sample.sample_id=sample.id  and assay_run.plate_set_id=plate_set.id AND   hit_list.assay_run_id=assay_run.id   AND  hit_sample.hitlist_id IN (SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID AND hit_list.id= 25 and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=18)))) GROUP BY plate_set.plate_set_sys_name;

SELECT  sample.id FROM hit_list, hit_sample, plate_set, assay_run, sample WHERE hit_sample.hitlist_id=hit_list.id  AND hit_sample.sample_id=sample.id  and assay_run.plate_set_id=plate_set.id AND   hit_list.assay_run_id=assay_run.id   AND  hit_sample.hitlist_id=25;

SELECT hit_list.ID FROM hit_list, assay_run WHERE hit_list.assay_run_id=assay_run.ID AND hit_list.id= 25 and assay_run.ID IN (SELECT assay_run.ID FROM assay_run WHERE assay_run.plate_set_id IN (SELECT plate_set.ID FROM plate_set WHERE plate_set.project_id=18));
