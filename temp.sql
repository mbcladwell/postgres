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

--select data from a plate set

SELECT assay_result.sample_id, assay_result.response, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result, assay_run, plate_layout WHERE assay_result.assay_run_id = 6 AND assay_run.plate_layout_name_id = plate_layout.plate_layout_name_id  LIMIT 5;


SELECT assay_result.sample_id, assay_result.response, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result, assay_run, plate_layout WHERE assay_result.assay_run_id = 6 AND assay_run.plate_layout_name_id = plate_layout.plate_layout_name_id AND plate_layout.well_type_id = 2;


SELECT assay_result.sample_id, assay_result.response  FROM assay_result  WHERE assay_result.assay_run_id = 6;


SELECT  plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM  plate_layout WHERE  plate_layout.plate_layout_name_id =  (SELECT plate_layout_name_id FROM plate_layout WHERE plate_layout.ID = );



SELECT *
    FROM weather INNER JOIN cities ON (weather.city = cities.NAME);


SELECT * FROM assay_result LIMIT 5;
SELECT * FROM assay_run LIMIT 5;
SELECT * FROM plate_layout LIMIT 5;
SELECT * FROM plate_layout_name LIMIT 5;
SELECT * FROM well_numbers LIMIT 5;


SELECT * FROM plate_set WHERE plate_set.ID = 10;

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
