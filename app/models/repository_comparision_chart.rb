module RepositoryComparisionChart
  module_function

  NAME_MAP = {
    SvnRepository: :Subversion,
    HgRepository: :Mercurial,
    BzrRepository: :Bazaar,
    CvsRepository: :CVS,
    GitRepository: :Git
  }.with_indifferent_access

  def build
    YAML.load_file(Rails.root.join('config/charting/repository_comparision_chart.yml')).tap do |chart|
      chart['series'][0]['data'] = chart_data
    end
  end

  def chart_data
    repositories = Repository.select('type, count(type)').group(:type).order(:type)
    data = repositories.map(&:attributes).map(&:with_indifferent_access)
    combined_data = combine_svn_and_svn_sync_count(data)
    combined_data.map do |hsh|
      aliased_type = NAME_MAP.fetch(hsh[:type])
      [aliased_type, hsh[:count]]
    end
  end

  def combine_svn_and_svn_sync_count(data)
    svn_sync_type = -> hsh { hsh[:type] == 'SvnSyncRepository' }
    svn_sync_data = data.find(&svn_sync_type)
    svn_data = data.find { |hsh| hsh[:type] == 'SvnRepository' }
    svn_data[:count] += svn_sync_data[:count]
    data.reject(&svn_sync_type)
  end
end
