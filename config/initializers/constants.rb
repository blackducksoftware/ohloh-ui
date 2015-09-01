BADGE_IMAGE_ROOT = '/images/badges/'

BLOG_LINKS = {
  terms:                    'terms',
  additional_terms:         'terms-2',
  contact_form:             'support-2',
  api_getting_started:      'getting_started',
  api_oauth:                'oauth',
  project_languages:        'project_languages',
  project_licenses:         'project_licenses',
  managing_projects:        'managingprojects',
  all_factoids:             'factoid-list',
  no_available_repository:  'no_available_repository',
  repository_not_supported: 'repository_not_supported',
  project_codebase_cost:    'project_codebase_cost',
  mostly_written:           'mostly_written',
  project_codebase_history: 'project_codebase_history',
  stack_faq:                'stack_faq',
  examples:                 'examples',
  stack_update_post:        '2008/05/stack_update',
  badges:                   'about-badges',
  pai_about:                'about-project-activity-icons',
  hotness_score:            '2014/01/about-the-ohloh-hotness-score'
}

ACCOUNT_DESC_LENGTH = 100

BACKUP_CLUMPS = 0

DAEMONIZATION_OPTIONS = {
  app_name: 'slave',
  dir_mode: :normal,                         # read `dir` value as an absolute path.
  dir: Rails.root.join('tmp/pids'),
  log_dir: Rails.root.join('log'),           # needs absolute path, see Daemonize#daemonize.
  log_output: true
}
