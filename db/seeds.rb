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

puts 'Alter foreign server'
ActiveRecord::Base.connection.execute("ALTER SERVER fis OPTIONS(set host '#{ENV['FOREIGN_DB_HOST']}',
                                      set dbname '#{ENV['FOREIGN_DB_NAME']}', set port '#{ENV['FOREIGN_DB_PORT']}')")

puts 'Alter foreign user mapping'
ActiveRecord::Base.connection.execute("ALTER USER MAPPING FOR #{ENV['FOREIGN_DB_USERNAME']} \
                                       SERVER fis OPTIONS(SET password '#{ENV['FOREIGN_DB_PASSWORD']}')")
