module RepositoryComparisionChart
  module_function

  NAME_MAP = {
    svn: :Subversion,
    hg: :Mercurial,
    bzr: :Bazaar,
    cvs: :CVS,
    git: :Git
  }.stringify_keys

  def build
    YAML.load_file(Rails.root.join('config/charting/repository_comparision_chart.yml')).tap do |chart|
      chart['series'][0]['data'] = chart_data
    end
  end

  def chart_data
    data = CodeLocation.scm_type_count.map(&:symbolize_keys)
    combined_data = combine_svn_count(data)
    combined_data.map do |hsh|
      aliased_type = NAME_MAP.fetch(hsh[:type])
      [aliased_type, hsh[:count]]
    end
  end

  def combine_svn_count(data)
    other_svn_type = -> (hsh) { %w(git_svn svn_sync).include?(hsh[:type]) }
    other_svn_count = data.select(&other_svn_type).sum { |hsh| hsh[:count] }
    svn_data = data.find { |hsh| hsh[:type] == 'svn' }
    svn_data[:count] += other_svn_count
    data.reject(&other_svn_type)
  end
end
