# frozen_string_literal: true

BADGE_IMAGE_ROOT = '/images/badges/'

BLOG_LINKS = {
  terms: 'terms',
  additional_terms: 'terms-2',
  contact_form: 'support-2',
  api_getting_started: 'getting_started',
  api_oauth: 'oauth',
  project_languages: 'project_languages',
  project_licenses: 'project_licenses',
  managing_projects: 'managingprojects',
  all_factoids: 'factoid-list',
  no_available_repository: 'no_available_repository',
  repository_not_supported: 'repository_not_supported',
  project_codebase_cost: 'project_codebase_cost',
  mostly_written: 'mostly_written',
  project_codebase_history: 'project_codebase_history',
  stack_faq: 'stack_faq',
  examples: 'examples',
  stack_update_post: '2008/05/stack_update',
  badges: 'about-badges',
  pai_about: 'about-project-activity-icons',
  hotness_score: '2014/01/about-the-ohloh-hotness-score'
}.freeze

ACCOUNT_DESC_LENGTH = 100

TIME_SPANS = { '30 days' => :last_30_days, '12 months' => :last_year }.freeze

GLOBALLY_SEARCHABLE = %w[projects organizations accounts people forums].freeze

UNCLAIMED_TILE_LIMIT = 11
OBJECT_MEMORY_CAP = 20_000
