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


SELECT plate_set.plate_set_sys_name , plate.plate_sys_name as "Plate", assay_result.well, assay_result.response, assay_result.bkgrnd_sub,   assay_result.norm,  assay_result.norm_pos  FROM assay_result, assay_run, plate_plate_set, plate_set, plate WHERE assay_run.plate_set_id=plate_plate_set.plate_set_id and assay_result.assay_run_id=assay_run.id AND plate_plate_set.plate_order=assay_result.plate_order AND plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_id=plate.ID and assay_run.id IN (3 ,2 ,1);


--init problems

SELECT project_sys_name AS \"ProjectID\", project_name As \"Name\", lnuser_name AS \"Owner\", descr AS \"Description\" FROM project, lnuser WHERE lnuser_id = lnuser.id ORDER BY project.id DESC;";


SELECT project_sys_name , project_name As "Name", lnuser_name, descr AS "Description" FROM project, lnuser, lnsession WHERE project.lnsession_id=lnsession.ID AND lnuser.id=lnsession.lnuser_id ORDER BY project.id DESC;


SELECT lnuser_id FROM lnuser, lnsession, plate_set WHERE plate_set.lnsession_id = lnsession.id AND lnsession.lnuser_id = lnuser.id AND  plate_set.id = 1;
