CREATE EXTENSION postgres_fdw schema public;
CREATE server fis foreign data wrapper postgres_fdw options(host 'oh-fis-db01.dc1.lan', dbname 'fis_development', port '5432');
CREATE USER MAPPING FOR openhub_dev_stage SERVER fis OPTIONS (user 'openhub_dev_stage', password 'MaTfrXVjcqf3z889');
