# frozen_string_literal: true

module SiteFeaturesHelper
  # rubocop:disable Metrics/MethodLength

  def features_hash
    {
      'OpenHub' => [
        "you can subscribe to e-mail newsletters to receive update from the <a href='http://blog.openhub.net/'
         target='_blank'>Open Hub blog</a>",
        "data presented on the Open Hub is available through our
         <a href='https://github.com/blackducksoftware/ohloh_api#ohloh-api-documentation' target='_blank'>API</a>",
        "you can embed <a href=#{project_widgets_path(project_id: @project.to_param)}
         target='_self'>statistics from Open Hub</a> on your site",
        'by exploring contributors within projects, you can view details on every commit
         they have made to that project',
        "<a href=#{tags_path} target='_self'>search</a> using multiple tags to find exactly what you need",
        "<a href=#{compare_projects_path} target='_self'>compare</a> projects before you chose one to use",
        "check out <a href=#{projects_explores_path} target='_self'>hot projects</a> on the Open Hub",
        "anyone with an Open Hub account can update a project's tags",
        "learn about Open Hub updates and features on the <a href='http://blog.openhub.net/' target='_blank'>
         Open Hub blog</a>"
      ],

      'Security' => [
        'there are over 3,000 projects on the Open Hub with security vulnerabilities reported against them',
        'use of OSS increased in 65% of companies in 2016',
        '65% of companies leverage OSS to speed application development in 2016',
        '55% of companies leverage OSS for production infrastructure',
        'nearly 1 in 3 companies have no process for identifying, tracking,
         or remediating known open source vulnerabilities',
        'in 2016, 47% of companies did not have formal process in place to track OS code'
      ]
    }.freeze
  end

  def random_site_features
    (features_hash.keys - ['OpenHub']).map do |key|
      features_hash[key].sample(2)
    end.flatten.zip(features_hash['OpenHub'].sample(2)).flatten
  end
  # rubocop:enable Metrics/MethodLength
end
