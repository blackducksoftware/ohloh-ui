desc 'Change FDW server and user credentails according to dot env file'
task fix_fdw_credentials: :environment do
  fix_primary_server_fdw_credentials
  fix_remote_server_fdw_credentials
end

def fix_primary_server_fdw_credentials
  config = ActiveRecord::Base.configurations['secondbase'][Rails.env]
  server = 'fis'
  active_record_execute(alter_fdw_server_query(server, config))
  active_record_execute(drop_user_mapping(server))
  active_record_execute(create_user_mapping(server, config))
end

def fix_remote_server_fdw_credentials
  config = ActiveRecord::Base.configurations[Rails.env]
  server = 'ohloh'
  second_base_execute(alter_fdw_server_query(server, config))
  second_base_execute(drop_user_mapping(server))
  second_base_execute(create_user_mapping(server, config))
end

def alter_fdw_server_query(server_name, config)
  "ALTER SERVER #{server_name} OPTIONS(set host '#{config['host']}',
     set dbname '#{config['database']}', set port '#{config['port']}')"
end

def drop_user_mapping(server_name)
  "DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER #{server_name}"
end

def create_user_mapping(server_name, config)
  "CREATE USER MAPPING FOR CURRENT_USER SERVER #{server_name}
     OPTIONS(user '#{config['username']}', password '#{config['password']}');"
end

def active_record_execute(cmd)
  ActiveRecord::Base.connection.execute(cmd)
end

def second_base_execute(cmd)
  SecondBase::Base.connection.execute(cmd)
end
