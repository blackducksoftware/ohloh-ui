# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[application.js application.css permissions.js admin/admin.css
<<<<<<< OTWO-7546
                                                 api/vulnerability.sass api/vulnerability.js
                                                 project_swimlanes.js]
=======
                                                 api/vulnerability.sass api/vulnerability.js rotating_stats.js]
>>>>>>> ui-redesign
Rails.application.config.assets.precompile += %w[*.svg *.eot *.woff *.ttf]
