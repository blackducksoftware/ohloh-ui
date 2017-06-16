#! /usr/bin/env ruby

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../../config/environment'

class SetCodeLocationStatus
  def initialize
    @conn = ActiveRecord::Base.connection
  end

  def execute
    load_temp_table
    index_temp_table
    update_code_location_status
    drop_temp_table
  end

  private

  def load_temp_table
    puts '  loading temp table..'
    @conn.execute("CREATE temp table kbLocations
        (id integer);")

    rc = @conn.raw_connection
    rc.exec('COPY kbLocations (id) FROM STDIN WITH CSV')

    file = File.open('tmp/oh-code-locations.csv', 'r')
    # Add each row to copy data
    rc.put_copy_data(file.readline) until file.eof?

    # We are done adding copy data
    rc.put_copy_end
  end

  def index_temp_table
    puts '    indexing temp table....'
    @conn.execute('CREATE INDEX ON kbLocations (id)')
  end

  def get_possible_selection
    code_location_count = @conn.select_value("SELECT count(*)
                        FROM code_locations cl
                        WHERE status != #{CodeLocation::STATUS_DELETED} AND
                        NOT EXISTS
                        (SELECT id FROM kbLocations kb WHERE kb.id = cl.id)")
    message = "   updating #{code_location_count} code location records..."
    puts message
  end

  def update_code_location_status
    print '      updating code location status.....'
    get_possible_selection
    @conn.execute("UPDATE Code_Locations cl SET status = NULL
      WHERE status !=  #{CodeLocation::STATUS_DELETED} AND
      NOT EXISTS
      (SELECT id FROM kbLocations kb WHERE kb.id = cl.id)")
  end

  def drop_temp_table
    puts '          dropping temp table.......'
    @conn.execute('DROP table kbLocations')
  end

end

puts 'starting script'
SetCodeLocationStatus.new.execute
puts 'finished script'
