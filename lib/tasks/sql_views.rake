namespace :db do
  desc "Update and create SQL views"
  task :views => :environment do
    Dir["#{Rails.root}/db/sql_views/*.sql"].each do |file_name|
      STDERR.puts "Applying the SQL view at #{file_name}"
      source_file = File.new(file_name, 'r')

      if source_file and (sql_content = source_file.read)
        ActiveRecord::Base.transaction do
          # Each statement ends with a semicolon followed by a newline.
          sql_lines = sql_content.split(/;[ \t]*$/)
          if sql_lines.respond_to?(:each)
            sql_lines.each do |line|
              ActiveRecord::Base.connection.execute "#{line};"
            end
          end
        end # transaction
      end

    end # Dir.each
  end # task
end
