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


SELECT * FROM hit_list;

SELECT hit_list.hitlist_sys_name AS "Sys-NAME", hit_list.hitlist_name AS "NAME", hit_list.descr AS "Description", assay_run.assay_run_sys_name AS "Assay Run ID", plate_set.plate_set_sys_name  FROM assay_run, plate_set, hit_list WHERE hit_list.assay_run_id= assay_run.id AND assay_run.plate_set_id= plate_set.ID AND plate_set.project_id=10;



---------------get layout sources

select sys_name AS "ID",plate_format_id AS "Format", NAME AS "Description", descr AS "Reps",   use_edge AS "Edge", num_controls AS "Controls", control_loc AS "Location" from plate_layout_name where source_dest = 'source';


src_id

select plate_layout_name.sys_name AS "ID",plate_layout_name.plate_format_id AS "Format", plate_layout_name.name AS "Description", plate_layout_name.descr AS "Reps",   plate_layout_name.use_edge AS "Edge", plate_layout_name.num_controls AS "Controls", plate_layout_name.control_loc AS "Location" from plate_layout_name, layout_source_dest WHERE layout_source_dest.src= 1 AND layout_source_dest.dest = plate_layout_name.id;


SELECT * FROM plate_layout_name;
SELECT * FROM layout_source_dest;
