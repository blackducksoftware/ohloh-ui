# frozen_string_literal: true

class AddIndexOnSlocMetricsIdField < ActiveRecord::Migration[4.2]
  def change
    add_index :sloc_metrics, :id
  end
end
