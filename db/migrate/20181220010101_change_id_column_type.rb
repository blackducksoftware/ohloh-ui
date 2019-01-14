# rubocop:disable all
class ChangeIdColumnType < ActiveRecord::Migration
  def up
    # Change fisbot sequences
    change_column :slave_logs, :id, :bigint
    change_column :fyles, :id, :bigint
    change_column :commits, :id, :bigint
    change_column :analysis_aliases, :id, :bigint
    change_column :jobs, :id, :bigint

    change_column :slave_logs_id_seq_view, :id, :bigint
    change_column :fyles_id_seq_view, :id, :bigint
    change_column :commits_id_seq_view, :id, :bigint
    change_column :analysis_aliases_id_seq_view, :id, :bigint
    change_column :jobs_id_seq_view, :id, :bigint

    execute 'alter table slave_logs alter id drop default'
    execute 'alter table fyles alter id drop default'
    execute 'alter table commits alter id drop default'
    execute 'alter table analysis_aliases alter id drop default'
    execute 'alter table jobs alter id drop default'
    execute 'drop function slave_logs_id_seq_view()'
    execute 'drop function fyles_id_seq_view()'
    execute 'drop function commits_id_seq_view()'
    execute 'drop function analysis_aliases_id_seq_view()'
    execute 'drop function jobs_id_seq_view()'

    execute "create function slave_logs_id_seq_view() returns bigint as 'select id from slave_logs_id_seq_view' language sql"
    execute "create function fyles_id_seq_view() returns bigint as 'select id from fyles_id_seq_view' language sql"
    execute "create function commits_id_seq_view() returns bigint as 'select id from commits_id_seq_view' language sql"
    execute "create function analysis_aliases_id_seq_view() returns bigint as 'select id from analysis_aliases_id_seq_view' language sql"
    execute "create function jobs_id_seq_view() returns bigint as 'select id from jobs_id_seq_view' language sql"
    execute 'alter table slave_logs alter id set default slave_logs_id_seq_view()'
    execute 'alter table fyles alter id set default fyles_id_seq_view()'
    execute 'alter table commits alter id set default commits_id_seq_view()'
    execute 'alter table analysis_aliases alter id set default analysis_aliases_id_seq_view()'
    execute 'alter table jobs alter id set default jobs_id_seq_view()'

    # Change openhub sequences
    change_column :name_language_facts, :id, :bigint
    change_column :recommend_entries, :id, :bigint
    change_column :vita_analyses, :id, :bigint
    change_column :name_language_facts, :id, :bigint

    execute 'drop view name_language_facts_id_seq_view'
    execute 'drop view recommend_entries_id_seq_view'
    execute 'drop view vita_analyses_id_seq_view'
    execute 'drop view name_facts_id_seq_view'
    execute "create view name_language_facts_id_seq_view as SELECT nextval('name_language_facts_id_seq'::regclass)::bigint AS id"
    execute "create view recommend_entries_id_seq_view as SELECT nextval('recommend_entries_id_seq'::regclass)::bigint AS id"
    execute "create view vita_analyses_id_seq_view as SELECT nextval('vita_analyses_id_seq'::regclass)::bigint AS id"
    execute "create view name_facts_id_seq_view as SELECT nextval('name_facts_id_seq'::regclass)::bigint AS id"
  end

  def down
    change_column :slave_logs, :id, :int
    change_column :fyles, :id, :int
    change_column :commits, :id, :int
    change_column :analysis_aliases, :id, :int
    change_column :jobs, :id, :int

    change_column :slave_logs_id_seq_view, :id, :int
    change_column :fyles_id_seq_view, :id, :int
    change_column :commits_id_seq_view, :id, :int
    change_column :analysis_aliases_id_seq_view, :id, :int
    change_column :jobs_id_seq_view, :id, :int

    change_column :name_language_facts, :id, :int
    change_column :recommend_entries, :id, :int
    change_column :vita_analyses, :id, :int
    change_column :name_language_facts, :id, :int

    execute 'drop view name_language_facts_id_seq_view'
    execute 'drop view recommend_entries_id_seq_view'
    execute 'drop view vita_analyses_id_seq_view'
    execute 'drop view name_facts_id_seq_view'
    execute "create view name_language_facts_id_seq_view as SELECT nextval('name_language_facts_id_seq'::regclass)::int AS id"
    execute "create view recommend_entries_id_seq_view as SELECT nextval('recommend_entries_id_seq'::regclass)::int AS id"
    execute "create view vita_analyses_id_seq_view as SELECT nextval('vita_analyses_id_seq'::regclass)::int AS id"
    execute "create view name_facts_id_seq_view as SELECT nextval('name_facts_id_seq'::regclass)::int AS id"

    execute 'alter table slave_logs alter id drop default'
    execute 'alter table fyles alter id drop default'
    execute 'alter table commits alter id drop default'
    execute 'alter table analysis_aliases alter id drop default'
    execute 'alter table jobs alter id drop default'

    execute 'drop function slave_logs_id_seq_view()'
    execute 'drop function fyles_id_seq_view()'
    execute 'drop function commits_id_seq_view()'
    execute 'drop function analysis_aliases_id_seq_view()'
    execute 'drop function jobs_id_seq_view()'

    execute "create function slave_logs_id_seq_view() returns int as 'select id from slave_logs_id_seq_view' language sql"
    execute "create function fyles_id_seq_view() returns int as 'select id from fyles_id_seq_view' language sql"
    execute "create function commits_id_seq_view() returns int as 'select id from commits_id_seq_view' language sql"
    execute "create function analysis_aliases_id_seq_view() returns int as 'select id from analysis_aliases_id_seq_view' language sql"
    execute "create function jobs_id_seq_view() returns int as 'select id from jobs_id_seq_view' language sql"

    execute 'alter table slave_logs alter id set default slave_logs_id_seq_view()'
    execute 'alter table fyles alter id set default fyles_id_seq_view()'
    execute 'alter table commits alter id set default commits_id_seq_view()'
    execute 'alter table analysis_aliases alter id set default analysis_aliases_id_seq_view()'
    execute 'alter table jobs alter id set default jobs_id_seq_view()'
  end
end
# rubocop:enable all
