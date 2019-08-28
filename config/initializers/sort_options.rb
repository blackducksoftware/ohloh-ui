# frozen_string_literal: true

SORT_OPTIONS = YAML.load_file(Rails.root + 'config/shared/sort_options.yml').with_indifferent_access
