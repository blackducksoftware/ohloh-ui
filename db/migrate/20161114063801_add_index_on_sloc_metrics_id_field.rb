# frozen_string_literal: true

class AddIndexOnSlocMetricsIdField < ActiveRecord::Migration
  def change
    add_index :sloc_metrics, :id
  end
end
