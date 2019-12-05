# frozen_string_literal: true

## This task correctly sets up the Foreign Database Wrapper that communicates between openhub and fisbot
## The task is intended to be used for staging, development, and test.
## The end result of the task will have the following configuration:

## OpenHub
## Server: fis
## Username: openhub_app_dev
## Foreign data wrapper options: ("user" 'fisbot_app_dev', password 'fisbot_app_dev password')

## Fisbot
## Server: ohloh
## Username: fisbot_app_dev
## Foreign data wrapper options: ("user" 'openhub_app_dev', password 'openhub_app_dev password')

## Note: The above configuration is an example for development.

desc 'Change FDW server and user credentails according to dot env file'
task fix_fdw_credentials: :environment do
  fix_primary_server_fdw_credentials
  fix_remote_server_fdw_credentials
end

def fix_primary_server_fdw_credentials
  config = ActiveRecord::Base.configurations['secondbase'][Rails.env]
  username = ActiveRecord::Base.configurations[Rails.env]['username']
  server = 'fis'
  active_record_execute(alter_fdw_server_query(server, config))
  active_record_execute(drop_user_mapping(server, username))
  active_record_execute(create_user_mapping(server, username, config))
end

def fix_remote_server_fdw_credentials
  config = ActiveRecord::Base.configurations[Rails.env]
  username = ActiveRecord::Base.configurations['secondbase'][Rails.env]['username']
  server = 'ohloh'
  second_base_execute(alter_fdw_server_query(server, config))
  second_base_execute(drop_user_mapping(server, username))
  second_base_execute(create_user_mapping(server, username, config))
end

def alter_fdw_server_query(server_name, config)
  "ALTER SERVER #{server_name} OPTIONS(set host '#{config['host']}',
     set dbname '#{config['database']}', set port '#{config['port']}')"
end

def drop_user_mapping(server_name, username)
  "DROP USER MAPPING IF EXISTS FOR #{username} SERVER #{server_name}"
end

def create_user_mapping(server_name, username, config)
  "CREATE USER MAPPING FOR #{username} SERVER #{server_name}
     OPTIONS(user '#{config['username']}', password '#{config['password']}');"
end

def active_record_execute(cmd)
  ActiveRecord::Base.connection.execute(cmd)
end

def second_base_execute(cmd)
  SecondBase::Base.connection.execute(cmd)
end
