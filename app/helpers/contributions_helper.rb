# frozen_string_literal: true

module ContributionsHelper
  def claim_position_url_options(contribution)
    { controller: :positions, action: :one_click_create,
      account_id: 'me', project_name: contribution.project.name,
      committer_name: contribution.contributor_fact.name.name, invite: params[:invite] }
  end

  def link_to_claim_position(contribution, text)
    css_class = 'btn btn-primary'
    css_class += ' invite' if params[:invite]
    id = "invite_#{params[:invite]}"
    link_to text, claim_position_url_options(contribution), class: css_class, id: id
  end

  def months_or_years(months)
    case months
    when 0..11
      "#{months}m"
    else
      "#{(months / 12).to_i}y #{months % 12}m"
    end
  end
end
