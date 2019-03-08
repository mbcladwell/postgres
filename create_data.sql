TRUNCATE project, plate_set, plate, hits, hit_list, assay_run, assay_result, sample, well, pmsession RESTART IDENTITY CASCADE;


SELECT new_project('description 1', 'MyTestProj1', 1 );
SELECT new_project('description 2', 'MyTestProj2', 1 );
SELECT new_project('description 3', 'MyTestProj3', 1 );
SELECT new_project('description 4', 'MyTestProj4', 1 );
SELECT new_project('description 5', 'MyTestProj5', 1 );
SELECT new_project('description 6', 'MyTestProj6', 1 );
SELECT new_project('description 7', 'MyTestProj7', 1 );
SELECT new_project('description 8', 'MyTestProj8', 1 );
SELECT new_project('description 9', 'MyTestProj9', 1 );
SELECT new_project('description 10', 'MyTestProj10', 1 );

SELECT * FROM project;


SELECT new_plate_set('using loop1','ps-name-by-user1',20,96,1,10,1,TRUE);
SELECT new_plate_set('using loop2','ps-name-by-user2',20,96,1,10,1,TRUE);
SELECT new_plate_set('using loop3','ps-name-by-user3',20,384,1,10,15,TRUE);
SELECT new_plate_set('using loop4','ps-name-by-user4',20,384,1,10,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,1,10,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,2,10,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,384,2,10,15,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,10,43,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,10,43,TRUE);
SELECT new_plate_set('using loop5','ps-name-by-user5',20,1536,1,10,43,TRUE);

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


--SELECT * FROM plate_set;
--select COUNT(*) FROM plate;
--SELECT COUNT(*) FROM sample;
--SELECT COUNT(*) FROM well;


INSERT INTO hit_list ( descr, project_id) VALUES ('description 1', 10 );
INSERT INTO hit_list ( descr, project_id) VALUES ('description 2', 10 );
INSERT INTO hit_list ( descr, project_id) VALUES ('description 3', 10 );
INSERT INTO hit_list ( descr, project_id) VALUES ('description 4', 10 );
INSERT INTO hit_list ( descr, project_id) VALUES ('description 5', 10 );


INSERT INTO hits ( hitlist_id, sample_id) VALUES ( 1, 1 );
INSERT INTO hits ( hitlist_id, sample_id) VALUES ( 1, 2 );
INSERT INTO hits ( hitlist_id, sample_id) VALUES ( 1, 3 );
INSERT INTO hits ( hitlist_id, sample_id) VALUES ( 1, 4 );
INSERT INTO hits ( hitlist_id, sample_id) VALUES ( 1, 5 );

-- new_assay_run( _name VARCHAR(30), _descr VARCHAR(30), _assay_type_id INTEGER, _plate_set_id INTEGER)
select new_assay_run( 'assay_run1', 'descr for assay run 1', 1, 2, 1);
select new_assay_run( 'assay_run2', 'descr for assay run 2', 1, 2, 1);
select new_assay_run( 'assay_run3', 'descr for assay run 3', 1, 2, 1);
select new_assay_run( 'assay_run4', 'descr for assay run 4', 1, 2, 1);
select new_assay_run( 'assay_run5', 'descr for assay run 5', 1, 2, 1);



INSERT INTO assay_result ( sample_id,  response, assay_run_id) VALUES ( 1,  0.2345,1 );
INSERT INTO assay_result ( sample_id,  response, assay_run_id) VALUES ( 1,  0.345, 1);
INSERT INTO assay_result ( sample_id, response, assay_run_id) VALUES ( 1,  0.457, 1);
INSERT INTO assay_result ( sample_id, response, assay_run_id) VALUES ( 1,  0.9345, 1);
INSERT INTO assay_result ( sample_id, response, assay_run_id) VALUES ( 1,  0.25, 1);
