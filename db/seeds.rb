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

config = ActiveRecord::Base.configurations['secondbase'][Rails.env]
host = config['host']
name = config['database']
port = config['port']
user = config['username']
password = config['password']

puts 'Alter foreign server'
cmd = "ALTER SERVER fis OPTIONS(set host '#{host}', set dbname '#{name}', set port '#{port}')"
ActiveRecord::Base.connection.execute(cmd)

puts 'Alter foreign user mapping'
cmd = "ALTER USER MAPPING FOR #{user} SERVER fis OPTIONS(SET password '#{password}')"
ActiveRecord::Base.connection.execute(cmd)
