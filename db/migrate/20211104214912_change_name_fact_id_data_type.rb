class ChangeNameFactIdDataType < ActiveRecord::Migration
  def up
    add_column :name_facts, :new_id, :bigint
    change_field

  end

  def down
    add_column :name_facts, :new_id, :integer
    change_field
  end

  private

  def change_field
    add_index :name_facts, :new_id, unique: true

    execute 'alter table name_facts drop constraint name_facts_pkey'
    execute "alter table name_facts alter new_id set default nextval('name_facts_id_seq'::regclass)";
    execute 'update name_facts set new_id = id where new_id is null'
    execute 'alter table name_facts add constraint name_facts_pkey primary key using index my_table_pk_idx'
    execute 'alter table name_facts drop column id'
    execute 'alter table name_facts rename column new_id to id'
    execute 'alter table only oh.people add constraint people_name_fact_id_fkey foreign key (name_fact_id) references oh.name_facts(id) on delete cascade'
  end
end
