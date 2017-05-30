puts '***** Seeding Data Start *****'
puts '***** Alter Foreign Data Wrapper configurations of local DB server based on ENV file *****'

config = ActiveRecord::Base.configurations[Rails.env]
foreign_db_config = ActiveRecord::Base.configurations['secondbase'][Rails.env]
host = foreign_db_config['host']
name = foreign_db_config['database']
port = foreign_db_config['port']
user = foreign_db_config['username']
password = foreign_db_config['password']

conn = ActiveRecord::Base.connection

conn.execute("ALTER SERVER fis OPTIONS(set host '#{host}', set dbname '#{name}', set port '#{port}');")

conn.execute("DROP USER MAPPING IF EXISTS for #{config['username']} server fis;")

conn.execute("CREATE USER MAPPING for #{config['username']} server fis OPTIONS(user '#{user}',
              password '#{password}');")

puts '***** Alter Foreign Data Wrapper configurations of foreign DB server *****'

conn = SecondBase::Base.connection
conn.execute("ALTER SERVER ohloh OPTIONS(set host '#{config['host']}',
              set dbname '#{config['database']}', set port '#{config['port']}');")

conn.execute("DROP USER MAPPING IF EXISTS for #{user} server ohloh;")

conn.execute("CREATE USER MAPPING for #{user} server ohloh OPTIONS(user '#{config['username']}',
              password '#{config['password']}');")
