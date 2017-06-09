create function commits_id_seq_view() returns int as 'select id from commits_id_seq_view' language sql;
create function diffs_id_seq_view() returns int as 'select id from diffs_id_seq_view' language sql;
create function fyles_id_seq_view() returns int as 'select id from fyles_id_seq_view' language sql;
create function sloc_metrics_id_seq_view() returns int as 'select id from sloc_metrics_id_seq_view' language sql;
