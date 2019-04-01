TRUNCATE project, plate_set, plate, hits, hit_list, assay_run, assay_result, sample, well, pmsession RESTART IDENTITY CASCADE;


SELECT new_project('One plate set with 2 96 well plates', 'MyTestProj1', 1 );
SELECT new_project('description 2', 'MyTestProj2', 1 );
SELECT new_project('description 3', 'MyTestProj3', 1 );
SELECT new_project('description 4', 'MyTestProj4', 1 );
SELECT new_project('description 5', 'MyTestProj5', 1 );
SELECT new_project('description 6', 'MyTestProj6', 1 );
SELECT new_project('description 7', 'MyTestProj7', 1 );
SELECT new_project('description 8', 'MyTestProj8', 1 );
SELECT new_project('10 plate sets with 20 plates each', 'MyTestProj9', 1 );
SELECT new_project('10 plate sets with 20 plates each', 'MyTestProj10 with data', 1 );

--SELECT * FROM project;


SELECT new_plate_set('using LYT-8;96;8in12','ps-name-by-user1',20,96,1,10,8,TRUE);
SELECT new_plate_set('using LYT-1;96;4in12','ps-name-by-user2',20,96,1,10,1,TRUE);
SELECT new_plate_set('using LYT-1;96;4in12','ps-name-by-user3',20,384,1,10,1,TRUE);
SELECT new_plate_set('using LYT-15;384;16in24','ps-name-by-user4',20,384,1,10,22,TRUE);
SELECT new_plate_set('using LYT-15;384;16in24','ps-name-by-user5',20,384,1,10,22,TRUE);
SELECT new_plate_set('using LYT-15;384;8in24','ps-name-by-user5',20,384,2,10,15,TRUE);
SELECT new_plate_set('using LYT-15;384;8in24','ps-name-by-user5',20,384,2,10,15,TRUE);
SELECT new_plate_set('using LYT-43;1536;8in47,48','ps-name-by-user5',20,1536,1,10,43,TRUE);
SELECT new_plate_set('using LYT-43;1536;8in47,48','ps-name-by-user5',20,1536,1,10,43,TRUE);
SELECT new_plate_set('using LYT-43;1536;8in47,48','ps-name-by-user5',20,1536,1,10,43,TRUE);

SELECT new_plate_set('using loop1','ps-name-by-user1',20,96,1,9,1,TRUE);
SELECT new_plate_set('using loop2','ps-name-by-user2',20,96,1,9,1,TRUE);
SELECT new_plate_set('using loop3','ps-name-by-user3',20,384,1,9,15,TRUE);
SELECT new_plate_set('using loop4','ps-name-by-user4',20,384,1,9,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,1,9,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,2,9,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,2,9,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,9,43,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,9,43,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,9,43,TRUE);

SELECT new_plate_set('for data import','ps-name-96 well',2,96,1,1,1,TRUE);


-- new_assay_run( _name VARCHAR(30), _descr VARCHAR(30), _assay_type_id INTEGER, _plate_set_id INTEGER, _plate_layout_name_id INTEGER)
select new_assay_run( 'assay_run1', 'PS-1 LYT-1;96;4in12', 1, 1, 1);
select new_assay_run( 'assay_run2', 'PS-2 LYT-1;96;4in12', 5, 2, 1);
select new_assay_run( 'assay_run3', 'PS-3 LYT-15;384;8in24', 1, 3, 15);
select new_assay_run( 'assay_run4', 'PS-4 LYT-15;384;8in24', 1, 4, 15);
select new_assay_run( 'assay_run4', 'PS-5 LYT-15;384;8in24', 5, 5, 15);
select new_assay_run( 'assay_run4', 'PS-6 LYT-15;384;8in24', 1, 6, 15);
select new_assay_run( 'assay_run4', 'PS-7 LYT-15;384;8in24', 5, 7, 15);
select new_assay_run( 'assay_run4', 'PS-8 LYT-43;1536;8in47,48', 1, 8, 43);
select new_assay_run( 'assay_run4', 'PS-9 LYT-43;1536;8in47,48', 1, 9, 43);
select new_assay_run( 'assay_run4', 'PS-10 LYT-43;1536;8in47,48', 5, 10, 43);

\i /home/mbc/projects/data/assay_data_for_import.sql

SELECT process_assay_run_data(1);
SELECT process_assay_run_data(2);
SELECT process_assay_run_data(3);
SELECT process_assay_run_data(4);
SELECT process_assay_run_data(5);
SELECT process_assay_run_data(6);
SELECT process_assay_run_data(7);
SELECT process_assay_run_data(8);
SELECT process_assay_run_data(9);
SELECT process_assay_run_data(10);

-- assay_name descr assay_type_id plate_set_id plate_layout_name_id
SELECT new_assay_run('assay run 1', 'PS-1 LYT-1;96;4in12' , 1, 1, 1);
SELECT new_assay_run('assay run 2', 'PS-2 LYT-1;96;4in12' , 5, 2, 1);
SELECT new_assay_run('assay run 3', 'PS-3 LYT-15;96;4in12' , 1, 3, 15);
SELECT new_assay_run('assay run 4', 'PS-4 LYT-15;96;4in12' , 1, 4, 15);
SELECT new_assay_run('assay run 5', 'PS-5 LYT-15;96;4in12' , 5, 5, 15);
SELECT new_assay_run('assay run 6', 'PS-6 LYT-15;96;4in12' , 1, 6, 15);
SELECT new_assay_run('assay run 7', 'PS-7 LYT-15;96;4in12' , 5, 7, 15);
SELECT new_assay_run('assay run 8', 'PS-8 LYT-43;96;4in12' , 1, 8, 43);
SELECT new_assay_run('assay run 9', 'PS-9 LYT-43;96;4in12' , 1, 9, 43);
SELECT new_assay_run('assay run 10', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);
SELECT new_assay_run('assay run 11', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);
SELECT new_assay_run('assay run 12', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);
SELECT new_assay_run('assay run 13', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);
SELECT new_assay_run('assay run 14', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);
SELECT new_assay_run('assay run 15', 'PS-10 LYT-43;96;4in12' , 5, 10, 43);


SELECT new_hit_list('hit list 1', 'descr1', 3, 1, ARRAY [125435, 125436, 125437]);
