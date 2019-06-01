class AlterSlaveAndJobsTable < ActiveRecord::Migration
  def change
    add_column :slaves, :queue_name, :string
    add_column :jobs, :is_expensive, :boolean, default: false, index: true
  end
end
