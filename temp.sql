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

plate_set.id = 1

SELECT plate_plate_set.plate_id, plate_plate_set.plate_order, well.well_name, well.id, sample.id FROM plate, plate_plate_set, well, sample, well_sample WHERE plate_plate_set.plate_set_id = 1  AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id ORDER BY plate_plate_set.plate_id, plate_plate_set.plate_order, well.id;

DECLARE sample_ids VARCHAR[] := (SELECT sample.id FROM plate, plate_plate_set, well, sample, well_sample WHERE plate_plate_set.plate_set_id = 1  AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id ORDER BY plate_plate_set.plate_id, plate_plate_set.plate_order, well.id);

DO
$$
DECLARE
    rec   record;
    nbrow bigint;
BEGIN
   FOR rec IN
      SELECT *
      FROM   pg_tables
      WHERE  tablename NOT LIKE 'pg\_%'
      ORDER  BY tablename
   LOOP
      EXECUTE 'SELECT count(*) FROM '
        || quote_ident(rec.schemaname) || '.'
        || quote_ident(rec.tablename)
      INTO nbrow;
      -- Do something with nbrow
   END LOOP;
END
$$;


DROP FUNCTION IF exists test( _old_plate_set_id INTEGER, _new_plate_set_id INTEGER);
CREATE OR REPLACE FUNCTION test(_old_plate_set_id INTEGER, _new_plate_set_id INTEGER)
  RETURNS void AS
$BODY$
DECLARE
   old_psid int := _old_plate_set_id;
   new_psid int := _new_plate_set_id;
   counter INTEGER;
   sql_statement VARCHAR;
all_sample_ids VARCHAR[];
num_plates INTEGER;

   
BEGIN

sql_statement := 'SELECT ARRAY(SELECT sample.id FROM plate, plate_plate_set, well, sample, well_sample WHERE plate_plate_set.plate_set_id = ' || old_psid || ' AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id ORDER BY plate_plate_set.plate_id, plate_plate_set.plate_order, well.id)';

    RAISE notice 'sql_statement: (%)', sql_statement;

     EXECUTE sql_statement INTO all_sample_ids;
     num_plates := ceiling( array_length(all_sample_ids ,1)/384); 
    RAISE notice 'ids: (%)', all_sample_ids;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

SELECT test(1,1);

SELECT new_plate_set( 'descr rearray','A test PS', 5, 2, 1, 10, FALSE);


EXECUTE 'SELECT ARRAY(SELECT mycolumn FROM mytable)' INTO avar; o

counter := 1;
SELECT sort(_plate_ids) INTO plate_ids;
sql_statement := 'INSERT INTO plate_plate_set (plate_set_id, plate_id, plate_order) VALUES ';

  FOREACH pid IN ARRAY plate_ids
     LOOP
     sql_statement := sql_statement || '(' || _plate_set_id || ', '  ||  pid || ', ' || counter || '),';
     counter = counter + 1;
    END LOOP;

     sql_statement := SUBSTRING(sql_statement, 1, CHAR_LENGTH(sql_statement)-1) || ';';
     --RAISE notice 'sqlstatement: (%)', sql_statement;
     EXECUTE sql_statement;



SELECT well_by_col  FROM plate_layout, plate_layout_name  WHERE plate_layout.plate_layout_name_id = plate_layout_name.id AND plate_layout.well_type_id = 1 AND plate_layout.plate_layout_name_id = 1 ;


select well.well_name, sample.sample_sys_name from plate, well, well_sample, sample where plate.id = 418 AND well_sample.well_id= well.id and well_sample.sample_id=sample.id and well.plate_id=418;