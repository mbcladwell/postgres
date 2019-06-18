TRUNCATE project, plate_set, plate, hit_sample, hit_list, assay_run, assay_result, sample, well, lnsession RESTART IDENTITY CASCADE;

INSERT INTO lnsession (lnuser_id) VALUES (1);

SELECT new_project('3 plate sets with 2 96 well plates each', 'With AR, HL', 1 );

SELECT new_plate_set('with AR (low values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);
SELECT new_plate_set('with AR (low values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);
SELECT new_plate_set('with AR (high values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);

select new_assay_run( 'assay_run1', 'PS-1 LYT-1;96;4in12', 1, 1, 1,1);
select new_assay_run( 'assay_run2', 'PS-2 LYT-1;96;4in12', 1, 2, 1,1);
select new_assay_run( 'assay_run3', 'PS-3 LYT-1;96;4in12', 5, 3, 1,1);



SELECT new_project('3 plate sets with 2 384 well plates each', 'With AR', 1 );
SELECT new_plate_set('with AR (low values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);
SELECT new_plate_set('with AR (low values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);
SELECT new_plate_set('with AR (high values), HL','2 96 well plates',2,96,1,1,1,1,TRUE);





SELECT new_project('1 plate sets with 1 1536 well plate', 'With AR', 1 );




SELECT new_project('description 4', 'MyTestProj4', 1 );
SELECT new_project('description 5', 'MyTestProj5', 1 );
SELECT new_project('description 6', 'MyTestProj6', 1 );
SELECT new_project('description 7', 'MyTestProj7', 1 );
SELECT new_project('description 8', 'MyTestProj8', 1 );
SELECT new_project('description 9', 'MyTestProj9', 1 );

SELECT new_project('1 plate set with 20 96 well plates', 'Plates only, no data', 1 );
SELECT new_plate_set('using LYT-1;96;4in12','ps-name-by-user2',20,96,1,10,1,1,TRUE);




SELECT new_plate_set('for data import','2 96 well plates',2,96,1,1,1,1,TRUE);


\i /home/mbc/projects/postgres/assay_data_for_elephantsql.sql

SELECT process_assay_run_data(1);
SELECT process_assay_run_data(2);
SELECT process_assay_run_data(3);

SELECT new_hit_list('hit list 1', 'descr1', 10, 1,  ARRAY[3663, 3678, 3618, 3670, 3631, 3610, 3652, 3647, 3656, 3649]);
SELECT new_hit_list('hit list 2', 'descr2', 20, 1,  ARRAY[3725, 3707, 3709, 3739, 3719, 3718, 3764, 3756, 3770, 3700, 3714, 3773, 3755, 3742, 3768, 3771, 3750, 3732, 3777, 3743]);
SELECT new_hit_list('hit list 3', 'descr3', 10, 2,  ARRAY[3798, 3868, 3827, 3804, 3796, 3862, 3817, 3870, 3814, 3810]);
SELECT new_hit_list('hit list 4', 'descr4', 20, 2,  ARRAY[3924, 3938, 3953, 3880, 3919, 3881, 3907, 3933, 3877, 3883, 3963, 3914, 3879, 3965, 3952, 3961, 3891, 3962, 3902, 3955]);
SELECT new_hit_list('hit list 5', 'descr5', 10, 3,  ARRAY[4017, 4030, 4055, 4027, 4045, 3985, 3976, 3993, 3987, 4048]);
SELECT new_hit_list('hit list 6', 'descr6', 20, 3,  ARRAY[4151, 4090, 4130, 4097, 4126, 4072, 4137, 4108, 4096, 4088, 4091, 4112, 4139, 4111, 4082, 4136, 4098, 4134, 4092, 4138]);



