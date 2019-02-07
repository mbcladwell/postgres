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


SELECT sample.id, temp_data.response FROM temp_data,  plate_layout, plate, well, sample, well_sample, plate_plate_set, plate_set, well_numbers  WHERE  plate_layout.plate_layout_name_id = 5 AND plate_set.id = 10 AND well_numbers.plate_format =1536 AND well.plate_id = plate.id AND well_sample.well_id = well.id AND well_sample.sample_id = sample.id AND plate_plate_set.plate_id = plate.id AND plate_plate_set.plate_set_id=plate_set.id;





plate_layout_name.id = plate_layout.plate_layout_name_id
well_type.id = plate_layout.well_type_id
well_number.by_col = plate.
well.well_name = well_number.well_name



 

