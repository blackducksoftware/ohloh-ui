require Rails.root.join('app/lib/fisbot/fisbot_api')
app_library_path = Rails.root.join('app/lib')
Dir[app_library_path.join('**/*.rb')].each { |file| require file }

Rails.configuration.eager_load_paths.delete(app_library_path.to_s)
