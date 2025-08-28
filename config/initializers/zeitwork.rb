# frozen_string_literal: true

Rails.autoloaders.main.ignore(Rails.root.join('app/core_extensions'))
Rails.autoloaders.main.ignore(Rails.root.join('app/core'))
Rails.autoloaders.main.ignore(Rails.root.join('app/lib'))
