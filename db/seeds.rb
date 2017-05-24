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

test_env = Rails.env == 'test'
host = test_env ? ENV['FOREIGN_TEST_DB_HOST'] : ENV['FOREIGN_DB_HOST']
name = test_env ? ENV['FOREIGN_TEST_DB_NAME'] : ENV['FOREIGN_DB_NAME']
port = test_env ? ENV['FOREIGN_TEST_DB_PORT'] : ENV['FOREIGN_DB_PORT']
user = test_env ? ENV['FOREIGN_TEST_DB_USERNAME'] : ENV['FOREIGN_DB_USERNAME']
password = test_env ? ENV['FOREIGN_TEST_DB_PASSWORD'] : ENV['FOREIGN_DB_PASSWORD']

puts 'Alter foreign server'
ActiveRecord::Base.connection.execute("ALTER SERVER fis OPTIONS(set host '#{host}',
                                      set dbname '#{name}', set port '#{port}')")

puts 'Alter foreign user mapping'
ActiveRecord::Base.connection.execute("ALTER USER MAPPING FOR #{user} SERVER fis OPTIONS(SET password '#{password}')")
