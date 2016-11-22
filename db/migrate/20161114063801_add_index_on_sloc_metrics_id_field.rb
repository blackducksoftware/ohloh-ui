class AddIndexOnSlocMetricsIdField < ActiveRecord::Migration
  def change
    add_index :sloc_metrics, :id
  end
end
