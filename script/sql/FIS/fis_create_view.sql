create view commits_id_seq_view as select nextval('commits_id_seq')::int as id;
create view diffs_id_seq_view as select nextval('diffs_id_seq')::int as id;
create view fyles_id_seq_view as select nextval('fyles_id_seq')::int as id;
create view sloc_metrics_id_seq_view as select nextval('sloc_metrics_id_seq')::int as id;
