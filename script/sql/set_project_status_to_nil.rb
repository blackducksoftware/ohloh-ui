#! /usr/bin/env ruby

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../../config/environment'

class SetCodeLocationStatus
  def initialize
    @conn = ActiveRecord::Base.connection
  end

  def execute
    load_temp_table
    update_project_status
    drop_temp_table
  end
  
  private 

  def load_temp_table
    @conn.execute("CREATE temp table kbLocations 
        (id integer);")
        
    rc = @conn.raw_connection
    rc.exec("COPY kbLocations (id) FROM STDIN WITH CSV")
  
    file = File.open('tmp/oh-code-locations.csv', 'r')
    while !file.eof?
      # Add row to copy data
      rc.put_copy_data(file.readline)
    end
  
    # We are done adding copy data
    rc.put_copy_end
      
    @conn.execute("CREATE INDEX ON kbLocations (id)")
  end 
  
  def update_project_status
    conn.execute("UPDATE projects p SET status = nil WHERE NOT EXISTS (select id from kbLocations kb where kb.id = p.id)")
  end
  
  def drop_temp_table
    @conn.execute("DROP table kbLocations")
  end

end

puts 'starting script'
SetCodeLocationStatus.new.execute
puts 'finished script'