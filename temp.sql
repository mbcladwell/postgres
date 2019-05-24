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

--rearray

DROP FUNCTION rearray_transfer_samples(integer, INTEGER, integer);
CREATE OR REPLACE FUNCTION rearray_transfer_samples(source_plate_set_id INTEGER, dest_plate_set_id INTEGER, hit_list_id integer)
 RETURNS void AS
$BODY$
DECLARE
   i INTEGER;
all_hit_sample_ids INTEGER[];
dest_wells INTEGER[];
num_hits INTEGER;
rp_id INTEGER;


BEGIN
--select get in plate, well order, not necessarily sample order 
SELECT ARRAY (SELECT  sample.id FROM plate_set, plate_plate_set, plate, well, well_sample, sample WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=source_plate_set_id AND sample.ID  IN  (SELECT hit_sample.sample_id FROM hit_sample WHERE hit_sample.hitlist_id = hit_list_id) ORDER BY plate.ID, well.ID) INTO all_hit_sample_ids;

num_hits := array_length(all_hit_sample_ids, 1);
--raise NOTice 'num_hits: (%)', num_hits;

SELECT ARRAY (SELECT well.ID FROM plate_set, plate_plate_set, plate, well, plate_layout WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND plate_set.plate_layout_name_id=plate_layout.plate_layout_name_id AND plate_layout.well_by_col= well.by_col AND plate_set.id=dest_plate_set_id AND plate_layout.well_type_id=1 ORDER BY well.ID) INTO dest_wells;


  for i IN 1..num_hits
  loop
  INSERT INTO well_sample (well_id, sample_id) VALUES ( dest_wells[i], all_hit_sample_ids[i]);   
raise NOTice 'dest_well: (%)', dest_wells[i];
raise NOTice 'sample: (%)', all_hit_sample_ids[i];


END LOOP;

INSERT INTO rearray_pairs (src, dest) VALUES (source_plate_set_id, dest_plate_set_id)  returning id INTO rp_id;

CREATE TEMP TABLE temp1 (plate_sys_name VARCHAR(10), by_col INTEGER, sample_id INTEGER);

INSERT INTO temp1 SELECT  plate.plate_sys_name, well.by_col, sample.ID AS "sample_id"  FROM plate_set, plate_plate_set, plate, well, well_sample, sample  WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=source_plate_set_id  AND sample.ID IN  (SELECT hit_sample.sample_id FROM hit_sample WHERE hit_sample.hitlist_id = hit_list_id ORDER BY sample.ID);

CREATE TEMP TABLE temp2 (plate_sys_name VARCHAR(10), by_col INTEGER, sample_id INTEGER);

INSERT INTO temp2 SELECT  plate.plate_sys_name, well.by_col, sample.ID AS "sample_id" FROM plate_set, plate_plate_set, plate, well, well_sample, sample  WHERE plate_plate_set.plate_set_id=plate_set.ID AND plate_plate_set.plate_id=plate.id AND well.plate_id=plate.ID AND well_sample.well_id=well.ID AND well_sample.sample_id=sample.ID and plate_set.id=dest_plate_set_id  ORDER BY sample.ID;

INSERT INTO worklists ( rearray_pairs_id, sample_id, source_plate, source_well, dest_plate, dest_well) SELECT rp_id, temp1.sample_id, temp1.plate_sys_name, temp1.by_col, temp2.plate_sys_name, temp2.by_col FROM temp1, temp2 WHERE temp1.sample_id = temp2.sample_id;

DROP TABLE temp1, temp2;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--rearray_transfer_samples(source_plate_set_id INTEGER, dest_plate_set_id INTEGER, hit_list_id integer)

SELECT rearray_transfer_samples(21, 26, 22);

SELECT * FROM worklists;
SELECT * FROM rearray_pairs;


