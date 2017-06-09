ALTER FOREIGN TABLE commits ALTER COLUMN id SET DEFAULT commits_id_seq_view();
ALTER FOREIGN TABLE diffs ALTER COLUMN id SET DEFAULT diffs_id_seq_view();
ALTER FOREIGN TABLE fyles ALTER COLUMN id SET DEFAULT fyles_id_seq_view();
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN id SET DEFAULT sloc_metrics_id_seq_view();
