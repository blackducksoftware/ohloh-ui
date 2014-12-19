class Account::ProjectExtension < OhDelegator::Base
  parent_scope do
    has_many :projects, -> { where { deleted.eq(false) } }, through: :manages, source: :target, source_type: 'Project'
  end

	# TODO Replace stacked_project? with this
	def stacked?(project_id)
    stack = stacks.detect {|s| s.stacked_project?(project_id) }
    stack.present?
  end

  # TODO Replace i_use_these with this
  def used
    @used_projects ||= Project.active.joins { stacks }
                              .where { stacks.account_id.eq my{id} }
                              .order { [user_count, name] }.limit(15).distinct

    logo_ids = @used_projects.collect(&:logo_id).compact
    @used_proj_logos ||= logo_ids.any? ? Logo.find(logo_ids) : []
    [@used_projects, @used_proj_logos.index_by(&:id)]
  end

  # TODO Replace stacked_projects_count with this
  def stacked_count
    @stacked_projects_count ||= Project.active.joins { stacks }
                                       .where { stacks.account_id.eq my{id} }
                                       .distinct.count

  end
end