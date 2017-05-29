# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db
# with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts '***** Seeding Data Start *****'
puts '***** Alter Foreign Data Wrapper configurations based on ENV file *****'

config = ActiveRecord::Base.configurations[Rails.env]
foreign_db_config = ActiveRecord::Base.configurations['secondbase'][Rails.env]
host = foreign_db_config['host']
name = foreign_db_config['database']
port = foreign_db_config['port']
user = foreign_db_config['username']
password = foreign_db_config['password']

conn = ActiveRecord::Base.connection

puts 'Alter foreign server'
conn.execute("ALTER SERVER fis OPTIONS(set host '#{host}', set dbname '#{name}', set port '#{port}')")

puts 'Alter foreign user mapping'
conn.execute("DROP USER MAPPING IF EXISTS for #{config['username']} server fis;")

cmd = "CREATE USER MAPPING for #{config['username']} server fis OPTIONS(user '#{user}', password '#{password}');"
conn.execute(cmd)
