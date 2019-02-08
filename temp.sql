  // table assay_result: sample_id, response, assay_run_id
    // table temp_data: plate, well, response
    // table assay_run: id, plate_set_id, plate_layout_name_id
    // plate_layout:  plate_layout_name_id, well_by_col, well_type_id
    // plate:  id
    // well: plate_id id  well_name
    // sample: id
    // well_sample:  well_id  sample_id
    // well_type: id  name
    // well_numbers: format  well_name  by_col 

plate_set_id = 10


SELECT sample.id, temp_data.response FROM temp_data, plate, well, sample, well_sample, plate_plate_set, plate_set  WHERE  plate_set.id = 10 AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND plate_plate_set.plate_id = plate.id AND plate_plate_set.plate_set_id=plate_set.id AND plate_plate_set.plate_order = temp_data.plate;

plate_layout_name.id = plate_layout.plate_layout_name_id
well_type.id = plate_layout.well_type_id
well_number.by_col = plate.
well.well_name = well_number.well_name



this worked
SELECT temp_data.plate, temp_data.response, sample.id FROM temp_data, plate_plate_set, plate, well,sample, well_sample WHERE plate_plate_set.plate_set_id = 10 AND temp_data.plate = plate_plate_set.plate_order AND well.plate_id = plate.id AND plate_plate_set.plate_id = plate.id AND plate_plate_set.plate_set_id = plate_set_id AND well_sample.sample_id = sample.id AND well_sample.well_id = well.id;



SELECT * FROM temp_data, plate_plate_set, plate_set, plate, well,sample, well_sample WHERE temp_data.plate = plate_plate_set.plate_order AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND plate_plate_set.plate_set_id = plate_set.id AND plate_plate_set.plate_set_id = 21;


 
 H12       |      401 | 268896 | SPL-268896   



SELECT well.well_name, plate.id, sample.id FROM plate, well, sample, well_sample WHERE well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND well.plate_id = plate.id AND plate.id=401 AND well.well_name = 'H12'; 


temp_data:   response   well   plate(order)

plate_plate_set:   id(plate_set)   id(plate)   order

well:  id(plate)   id  

well_sample:  well_id   sample_id

 plate | well | response  | plate_set_id | plate_id | plate_order | id | plate_set_name  |      descr      | plate_set_sys_name | num_plates | plate_format_id | plate_type_id | project_id |            updated            | id  | plate_sys_name | plate_type_id | project_id | plate_format_id |            updated            |   id   | well_name | plate_id |   id   | sample_sys_name | project_id | accs_id | well_id | sample_id 

SELECT temp_data.plate,  temp_data.well,  temp_data.response ,plate_plate_set.plate_order , plate_set.plate_set_sys_name , plate.plate_sys_name, well.id, well.well_name, sample.sample_sys_name FROM temp_data, plate_plate_set, plate_set, plate, well,sample, well_sample, well_numbers WHERE temp_data.plate = plate_plate_set.plate_order AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND plate_plate_set.plate_set_id = plate_set.id AND plate_plate_set.plate_set_id = 21 AND temp_data.well = well_numbers.by_col AND well_numbers.well_name = well.well_name AND well_numbers.plate_format = 96 ORDER BY plate_plate_set.plate_order, well_numbers.by_col;


INSERT INTO assay_result  SELECT sample.id, temp_data.response, 1  FROM temp_data, plate_plate_set, plate_set, plate, well,sample, well_sample, well_numbers WHERE temp_data.plate = plate_plate_set.plate_order AND plate_plate_set.plate_id = plate.id AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND plate_plate_set.plate_set_id = plate_set.id AND plate_plate_set.plate_set_id = 21 AND temp_data.well = well_numbers.by_col AND well_numbers.well_name = well.well_name AND well_numbers.plate_format = 96 ORDER BY plate_plate_set.plate_order, well_numbers.by_col;


















