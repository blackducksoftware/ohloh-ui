# frozen_string_literal: true

ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do
  def dump_schema_information
    schemas = ENV['DB_SCHEMAS'].split(',')

    insert_queries = []
    schemas.each do |schema_name|
      sm_table = "#{schema_name}.#{ActiveRecord::SchemaMigration.table_name}"
      insert_queries << ActiveRecord::Base.connection.execute("select version from #{sm_table}")
                                          .values.flatten.sort.map do |version|
        "INSERT INTO #{sm_table} (version) VALUES ('#{version}');"
      end
    end
    insert_queries.flatten.join "\n\n"
  end
end
