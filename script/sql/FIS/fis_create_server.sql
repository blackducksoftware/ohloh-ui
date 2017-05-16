CREATE EXTENSION postgres_fdw schema public;
CREATE server openhub foreign data wrapper postgres_fdw options(host 'oh-db01.dc1.lan', dbname 'openhub_development', port '5432');
CREATE USER MAPPING FOR openhub_dev_stage SERVER openhub OPTIONS (user 'openhub_dev_stage', password 'MaTfrXVjcqf3z889');
