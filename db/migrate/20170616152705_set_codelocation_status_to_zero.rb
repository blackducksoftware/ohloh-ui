# frozen_string_literal: true

class SetCodelocationStatusToZero < ActiveRecord::Migration[4.2]
  def up
    SetCodeLocationStatus.new.execute
  end

  def down
    SetCodeLocationStatus.new.rollback
  end
end

class SetCodeLocationStatus
  def initialize
    @conn = ActiveRecord::Base.connection
    @rollback = false
  end

  def execute
    setup_temp_table
    update_code_location_status
    drop_temp_table
  end

  def rollback
    @rollback = true
    setup_temp_table
    rollback_code_location_status
    drop_temp_table
  end

  private

  def setup_temp_table
    load_temp_table_data
    index_temp_table
  end

  def load_temp_table_data
    puts '  loading temp table..'
    @conn.execute("CREATE temp table kbLocations
        (id integer);")

    rc = @conn.raw_connection
    rc.exec('COPY kbLocations (id) FROM STDIN WITH CSV')

    file = File.open('vendor/oh-code-locations.csv', 'r')
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
    condition = @rollback ? "status = #{CodeLocation::STATUS_UNDEFINED}" : "status != #{CodeLocation::STATUS_DELETED}"

    code_location_count = @conn.select_value("SELECT count(*)
                        FROM code_locations cl
                        WHERE #{condition} AND
                        NOT EXISTS
                        (SELECT id FROM kbLocations kb WHERE kb.id = cl.id);")
    message = "   updating #{code_location_count} code location records"
    puts message
  end

  def update_code_location_status
    print '      updating code location status.....'
    get_possible_selection
    @conn.execute("UPDATE Code_Locations cl SET status = #{CodeLocation::STATUS_UNDEFINED}
      WHERE status !=  #{CodeLocation::STATUS_DELETED} AND
      NOT EXISTS
      (SELECT id FROM kbLocations kb WHERE kb.id = cl.id);")
  end

  def rollback_code_location_status
    print '      rolling back code location status.....'
    get_possible_selection
    @conn.execute("UPDATE Code_Locations cl SET status = #{CodeLocation::STATUS_ACTIVE}
      WHERE status = #{CodeLocation::STATUS_UNDEFINED} AND
      NOT EXISTS
      (SELECT id FROM kbLocations kb WHERE kb.id = cl.id);")
  end

  def drop_temp_table
    puts '    dropping temp table.......'
    @conn.execute('DROP table kbLocations;')
    puts 'completed'
  end
end
