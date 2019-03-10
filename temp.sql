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

plate_set.id = 21   2 plates

--DialogReformatPlateSet provides  dmf,  name, description new_plate_format_id, type_id, layout_id
			   --old_plate_set_id, old_num_plates
   
BEGIN

sql_statement := 'SELECT ARRAY(SELECT sample.id FROM plate, plate_plate_set, well, sample, well_sample WHERE plate_plate_set.plate_set_id = ' || old_psid || ' AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id ORDER BY plate_plate_set.plate_id, plate_plate_set.plate_order, well.id)';

    RAISE notice 'sql_statement: (%)', sql_statement;

     EXECUTE sql_statement INTO all_sample_ids;
     num_plates := ceiling( array_length(all_sample_ids ,1)/384); 
    RAISE notice 'ids: (%)', all_sample_ids;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
