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


---------------------------

DROP FUNCTION IF exists get_scatter_plot_data(_assay_run_id integer);

CREATE OR REPLACE FUNCTION get_scatter_plot_data(_assay_run_id INTEGER)
  RETURNS TABLE( plate2 INTEGER, plate INTEGER, well INTEGER, response REAL, bkgrnd_sub REAL,   norm REAL,   norm_pos REAL,  well_type_id INTEGER,  replicates VARCHAR(2), target VARCHAR(2) ) AS
$BODY$
BEGIN

RETURN query
 SELECT assay_result.plate, assay_result.plate, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result JOIN plate_layout  ON assay_result.well = plate_layout.well_by_col  WHERE assay_result.assay_run_id = _assay_run_id AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = _assay_run_id);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


SELECT get_scatter_plot_data(9);



SELECT assay_result.assay_run_id, assay_result.plate,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9) LIMIT 5;


SELECT assay_result.plate, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_type_id, plate_layout.replicates FROM assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9) LIMIT 5;


--working on this
SELECT assay_result.assay_run_id, assay_result.plate,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample, assay_run, assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9)  AND assay_run.ID = 9 AND assay_run.plate_set_id = plate_set.ID AND assay_result.plate = plate_plate_set.plate_order AND plate_layout.plate_layout_name_id= assay_run.plate_layout_name_id  AND  well_sample.well_id = well.ID AND well.plate_id = plate.id AND plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID  LIMIT 5;


SELECT assay_result.assay_run_id, assay_result.plate,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target
FROM  plate_plate_set, plate_set, plate, plate_layout_name, well,  well_sample, assay_run, assay_result
JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)
WHERE assay_result.assay_run_id = 9 AND
--plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9)  AND
plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id AND
assay_run.ID = 9 AND
plate_set.ID = assay_run.plate_set_id AND
assay_result.plate = plate_plate_set.plate_order AND
plate_layout.plate_layout_name_id= assay_run.plate_layout_name_id  AND

well_sample.well_id = well.ID AND
well.plate_id = plate.id AND
plate_plate_set.plate_set_id = plate_set.ID AND
plate_plate_set.plate_id = plate.ID AND
--plate_plate_set.plate_id = well.plate_id
plate_layout.plate_layout_name_id = plate_layout_name.ID 

LIMIT 5;





need well_by_col!!

SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.well_name,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = dest_plate_set_id  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT well_numbers.well_name, well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.well_name=foo.well_name) ORDER BY plate_id, quad, by_col) INTO all_dest_well_ids;


-------------plate 404

SELECT * FROM plate WHERE plate.id=40;

SELECT well_by_col  FROM plate_layout, plate_layout_name  WHERE plate_layout.plate_layout_name_id = plate_layout_name.id AND plate_layout.well_type_id = 1 AND plate_layout.plate_layout_name_id = _plate_layout_name_id;
