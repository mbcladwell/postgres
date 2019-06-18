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
---------------------------




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

SELECT plate_set.plate_set_sys_name as "Plate SET", plate.plate_sys_name as "Plate", assay_result.well, assay_result.response, assay_result.bkgrnd_sub,   assay_result.norm,  assay_result.norm_pos  FROM assay_result, assay_run, plate_plate_set, plate_set, plate WHERE assay_run.plate_set_id=plate_plate_set.plate_set_id and assay_result.assay_run_id=assay_run.id AND plate_plate_set.plate_order=assay_result.plate_order AND plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and assay_run.id = 13;


SELECT password = 'welcome', password FROM lnuser WHERE lnuser_name = 'ln_admn';

SELECT * FROM lnuser;


SELECT * FROM lnsession;


SELECT plate_set.plate_set_sys_name , plate.plate_sys_name as "Plate", assay_result.well, sample.sample_sys_name, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos  FROM assay_result, assay_run, plate_plate_set, plate_set, plate, well_sample, sample, well LEFT OUTER JOIN well_numbers ON (well.by_col = well_numbers.by_col) WHERE assay_run.plate_set_id=plate_plate_set.plate_set_id and assay_result.assay_run_id=assay_run.id AND plate_plate_set.plate_order=assay_result.plate_order AND assay_result.well=well.by_col   and plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and plate.id=well.plate_id AND well.id=well_sample.well_id AND sample.ID = well_sample.sample_id AND plate_set.plate_format_id=well_numbers.plate_format AND assay_run.id IN (3 ,2 ,1) ORDER BY plate.plate_sys_name, assay_result.well desc;   LIMIT 5;


SELECT * FROM well_numbers LIMIT 5;
SELECT * FROM plate_set WHERE plate_set.id=5;  LIMIT 5;
SELECT * FROM plate LIMIT 5;
SELECT * FROM well LIMIT 5;
SELECT * FROM well_sample LIMIT 5;
SELECT * FROM sample LIMIT 5;
SELECT * FROM assay_run WHERE assay_run.ID = 3;  LIMIT 5;
SELECT * FROM assay_result WHERE assay_result.assay_run_ID = 3;   5;

SELECT *  FROM assay_result, assay_run WHERE assay_result.assay_run_id=assay_run.ID and assay_run.ID IN (3) LIMIT 5;
