--init db
 
-- https://dba.stackexchange.com/questions/117109/how-to-manage-default-privileges-for-users-on-a-database-vs-schema/117661#117661
-- login initially:   psql -U postgres -h 192.168.1.7


--CREATE USER pm_admin WITH PASSWORD 'welcome';
CREATE USER pm_admin WITH PASSWORD 'welcome' CREATEDB CREATEROLE; -- see below
CREATE USER pm_mgr   WITH PASSWORD 'welcome';
CREATE USER pm_usr   WITH PASSWORD 'welcome';

GRANT pm_usr TO pm_mgr;
GRANT pm_mgr TO pm_admin;

CREATE DATABASE pmdb;
REVOKE ALL ON DATABASE pmdb FROM public;  -- see notes below!

GRANT CONNECT ON DATABASE pmdb TO pm_usr;  -- others inherit

\connect pmdb  -- psql syntax

--I am naming the schema plate_manager (not pmdb which would be confusing). Pick any name. Optionally make pmuser_admin the owner of the schema:

CREATE SCHEMA plate_manager AUTHORIZATION pm_admin;

SET search_path = plate_manager;  -- see notes

ALTER ROLE pm_admin IN DATABASE pmdb SET search_path = plate_manager; -- not inherited
ALTER ROLE pm_mgr   IN DATABASE pmdb SET search_path = plate_manager;
ALTER ROLE pm_usr   IN DATABASE pmdb SET search_path = plate_manager;

GRANT USAGE  ON SCHEMA plate_manager TO pm_usr;
GRANT CREATE ON SCHEMA plate_manager TO pm_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE pm_admin
GRANT SELECT                           ON TABLES TO pm_usr;  -- only read

ALTER DEFAULT PRIVILEGES FOR ROLE pm_admin
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO pm_mgr;  -- + write, TRUNCATE optional

ALTER DEFAULT PRIVILEGES FOR ROLE pm_admin
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO pm_admin;  -- SELECT, UPDATE are optional 

set schema 'plate_manager';
CREATE EXTENSION pgcrypto;

--Once set up:
-- psql -U pm_admin -h 192.168.1.7 -d pmdb
