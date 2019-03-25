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
RETURNS TABLE(  plate INTEGER, well INTEGER, response REAL, bkgrnd_sub REAL,   norm REAL,   norm_pos REAL,  well_type_id INTEGER,  replicates VARCHAR(2), target VARCHAR(2), sample_id integer ) AS
$BODY$

BEGIN

--CREATE TEMPORARY TABLE temp1 AS (SELECT plate_order INTEGER, well integer, response real, bkgrnd_sub real, norm REAL , norm_pos real, plate_set_id integer, plate_layout_name_id integer, well_type_id integer, replicates integer, target VARCHAR(2));

CREATE TEMPORARY TABLE temp1 AS SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result JOIN plate_layout ON ( assay_result.well = plate_layout.well_by_col) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = _assay_run_id AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id;

--CREATE TEMPORARY TABLE temp2(plate_order integer, by_col integer, sample_id INTEGER);

CREATE TEMPORARY TABLE temp2 AS SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21;

RETURN query
SELECT  temp1.plate_order,temp1.well, temp1.response, temp1.bkgrnd_sub, temp1.norm, temp1.norm_pos, temp1.well_type_id, temp1.replicates, temp1.target, temp2.sample_id FROM temp1 JOIN temp2 on (temp1.plate_order=temp2.plate_order AND temp1.well= temp2.by_col);

DROP TABLE temp1;
DROP TABLE temp2;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



SELECT get_scatter_plot_data(10);



SELECT assay_result.assay_run_id, assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9) LIMIT 5;


SELECT assay_result.plate, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_type_id, plate_layout.replicates FROM assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9) LIMIT 5;


--working on this
SELECT assay_result.assay_run_id, assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample, assay_run, assay_result JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)  WHERE assay_result.assay_run_id = 9 AND  plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9)  AND assay_run.ID = 9 AND assay_run.plate_set_id = plate_set.ID AND assay_result.plate_order = plate_plate_set.plate_order AND plate_layout.plate_layout_name_id= assay_run.plate_layout_name_id  AND  well_sample.well_id = well.ID AND well.plate_id = plate.id AND plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID  LIMIT 5;


SELECT assay_result.assay_run_id, assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target
FROM  plate_plate_set, plate_set, plate, plate_layout_name, well,  well_sample, assay_run, assay_result
JOIN plate_layout  ON (assay_result.well = plate_layout.well_by_col)
WHERE assay_result.assay_run_id = 9 AND
--plate_layout.plate_layout_name_id = (SELECT plate_layout_name_id FROM assay_run WHERE assay_run.ID = 9)  AND
plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id AND
assay_run.ID = 9 AND
plate_set.ID = assay_run.plate_set_id AND
assay_result.plate_order = plate_plate_set.plate_order AND
plate_layout.plate_layout_name_id= assay_run.plate_layout_name_id  AND

well_sample.well_id = well.ID AND
well.plate_id = plate.id AND
plate_plate_set.plate_set_id = plate_set.ID AND
plate_plate_set.plate_id = plate.ID AND
--plate_plate_set.plate_id = well.plate_id
plate_layout.plate_layout_name_id = plate_layout_name.ID 

LIMIT 5;





need well_by_col!!

SELECT ARRAY (SELECT  dest.id  FROM ( SELECT plate_plate_set.plate_ID, well.by_col,  well.id  FROM well, plate_plate_set  WHERE plate_plate_set.plate_set_id = dest_plate_set_id  AND plate_plate_set.plate_id = well.plate_id) AS dest JOIN (SELECT  well_numbers.by_col, well_numbers.quad FROM well_numbers WHERE well_numbers.plate_format=dest_plate_format_id)  AS foo ON (dest.by_col=foo.by_col) ORDER BY plate_id, quad, by_col) INTO all_dest_well_ids;


-------------plate 404

SELECT * FROM plate WHERE plate.id=40;
SELECT * FROM plate_set;
SELECT * FROM plate_layout_name;
SELECT * FROM plate_layout LIMIT 2;
SELECT * FROM assay_result LIMIT 2;
SELECT * FROM assay_run LIMIT 2;

assay_result.assay_run_id = 10

SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result JOIN plate_layout  ON ( assay_result.well = plate_layout.well_by_col  ) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = 10 AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id LIMIT 20;

--SELECT plate_layout.well_by_col, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM plate_layout WHERE plate_layout.plate_layout_name_id =  LIMIT 2;

--SELECT  assay_run.plate_set_id, assay_run.plate_layout_name_id FROM assay_run WHERE assay_run.ID = 10 LIMIT 2;

plate_set_id = 21  -- 2 96 well plates, 192 samples
SELECT * FROM plate_set WHERE plate_set.ID = 21;   assay_run.plate_set_id

SELECT * FROM plate WHERE plate.id=40;
SELECT * FROM plate_set;
SELECT * FROM plate_plate_set LIMIT 5;
SELECT * FROM well LIMIT 5;

SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21;

(SELECT  assay_result.plate_order, assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result  JOIN plate_layout  ON ( assay_result.well = plate_layout.well_by_col  ) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = 10 AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id)  foo LEFT OUTER JOIN (SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21) bar ON (foo.plate_order=bar.plate_order AND foo.well = bar.by_col);

 

SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result JOIN plate_layout  ON ( assay_result.well = plate_layout.well_by_col  ) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = 10 AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id;

SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21;


-------

(SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = 10 AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id JOIN plate_layout ON ( assay_result.well = plate_layout.well_by_col) as foo LEFT OUTER JOIN (SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21) AS bar ON (foo.plate_order=bar.plate_order AND foo.well = bar.by_col);



(SELECT  assay_result.plate_order,assay_result.well, assay_result.response, assay_result.bkgrnd_sub, assay_result.norm, assay_result.norm_pos, assay_run.plate_set_id, assay_run.plate_layout_name_id, plate_layout.well_type_id, plate_layout.replicates, plate_layout.target FROM assay_run, assay_result  JOIN plate_layout ON ( assay_result.well = plate_layout.well_by_col) WHERE assay_result.assay_run_id = assay_run.id  AND assay_run.ID = 10 AND plate_layout.plate_layout_name_id = assay_run.plate_layout_name_id) LEFT OUTER JOIN (SELECT plate_plate_set.plate_order, well.by_col, well_sample.sample_id FROM  plate_plate_set, plate_set, plate,  well,  well_sample WHERE plate_plate_set.plate_set_id = plate_set.ID AND plate_plate_set.plate_id = plate.ID AND well.plate_id = plate.id  and well_sample.well_id=well.ID  AND plate_plate_set.plate_set_id = 21) on (assay_result.plate_order=plate_plate_set.plate_order AND assay_result.well= well.by_col);






) AS bar ON (foo.plate_order=bar.plate_order AND foo.well = bar.by_col);

