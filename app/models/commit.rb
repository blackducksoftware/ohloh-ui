class Commit < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :name
  belongs_to :email_address
  has_many :fyle, primary_key: :code_set_id, foreign_key: :code_set_id
  has_many :diffs, dependent: :destroy
  has_many :analysis_aliases, foreign_key: :commit_name_id, primary_key: :name_id

  include EmailObfuscation

  scope :for_project, lambda { |project|
    joins(code_set: { repository: { enlistments: :project } })
      .where(enlistments: { deleted: false })
      .where(projects: { id: project.id })
  }

  scope :for_contributor_fact, lambda { |contributor_fact|
    joins([[code_set: [sloc_sets: :analysis_sloc_sets]], :analysis_aliases])
      .where(analysis_aliases: { analysis_id: contributor_fact.analysis_id })
      .where(analysis_sloc_sets: { analysis_id: contributor_fact.analysis_id })
      .where(analysis_aliases: { preferred_name_id: contributor_fact.name_id })
  }

  def lines_added_and_removed(analysis_id)
    summaries = SlocMetric.commit_summaries(self, analysis_id)
    lines_added = lines_removed = 0
    summaries.each do |summary|
      lines_added += summary.code_added + summary.comments_added + summary.blanks_added
      lines_removed += summary.code_removed + summary.comments_removed + summary.blanks_removed
    end
    [lines_added, lines_removed]
  end

  def nice_id(params = {})
    case code_set.repository
    when SvnSyncRepository
      "r#{sha1}"
    when GitRepository
      params[:short] ? sha1.to_s.truncate(8, omission: '') : sha1
    when HgRepository
      params[:short] ? sha1.to_s.truncate(12, omission: '') : sha1
    end
  end
end
