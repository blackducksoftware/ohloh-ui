# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
module KudosHelper
  def kudos_laurel_link_for(person)
    path = person.nil? ? '#' : rankings_people_path(show: person.id)
    link_to(avatar_laurels(person && person.kudo_rank), path, class: 'laurel')
  end

  def kudo_position_for_person(person_id, kudo_position = 0)
    if person_id && kudo_position
      link = link_to(kudo_position, rankings_people_path(show: person_id))
      I18n.t('kudos.position_for_person', link: link, total: Person::Count.total)
    else
      I18n.t('kudos.not_yet_ranked')
    end
  end

  def kudo_button(target)
    target = target.account || target.contributions.first if target.is_a?(Person)
    return nil if !logged_in? || current_user == kudo_button_target_account(target)

    kudo = Kudo.find_for_sender_and_target(current_user, target)
    kudo ? remove_kudos_button(kudo) : give_kudos_button(target)
  end

  def kudo_is_new?(account_id, created_at)
    return (session[:last_active] && (created_at > session[:last_active])) if account_id == current_user.id

    created_at > Time.current - 24.hours
  end

  def kudo_delete_link_confirm(kudo)
    case current_user.id
    when kudo.sender_id
      I18n.t('kudos.undo_sender', to: kudo.person_name)
    when kudo.account_id
      I18n.t('kudos.undo_account', from: kudo.sender.name)
    end
  end

  def kudo_delete_link(kudo)
    confirm = kudo_delete_link_confirm(kudo)
    return nil unless confirm

    haml_tag :a, href: kudo_path(kudo), class: 'command btn btn-minier btn-primary',
                 data: { method: :delete, confirm: confirm } do
      haml_tag :i, '', class: 'icon-undo rescind-kudos'
      haml_tag :span, I18n.t('kudos.undo')
    end
  end

  def kudos_grouped_sent(sent_kudos)
    sent_kudos.group_by { |k| k.account_id || ((k.project_id << 32) + k.name_id) }.map { |a| a[1] }
  end

  def kudo_person_link(kudo)
    kudo.account ? kudo_account_link(kudo) : kudo_contribution_link(kudo)
  end

  def kudos_aka_name(kudo)
    pos = Position.find_by(project_id: kudo.project_id, name_id: kudo.name_id)
    contribution_id = pos && Contribution.generate_id_from_project_id_and_account_id(kudo.project_id, pos.account_id)
    if pos && contribution_id
      path = project_contributor_path(kudo.project, contribution_id)
      "<div class='aka_name'><a href='#{path}'>#{kudo.name.name} (#{kudo.project.name})</a></div>"
    else
      ''
    end
  end

  def kudo_rank_from_kudo(kudo)
    if kudo.account
      kudo.account.kudo_rank
    else
      contributor_fact = ContributorFact.first_for_name_id_and_project_id(kudo.name_id, kudo.project_id)
      contributor_fact&.kudo_rank
    end
  end

  private

  def kudo_button_target_account(target)
    case target
    when Account
      target
    when Contribution
      target.person.account
    end
  end

  def kudo_target_name(target)
    case target
    when Account
      target.name
    when Contribution
      obfuscate_email(target.person.name.try(:name))
    end
  end

  def remove_kudos_button(kudo)
    haml_tag :div do
      kudo_delete_link(kudo)
    end
  end

  def give_kudos_button(target)
    label = I18n.t('kudos.give_kudos_to', name: kudo_target_name(target))
    path = if target.is_a?(Account)
             new_kudo_path(account_id: target.to_param)
           else
             new_kudo_path(contribution_id: target.id)
           end
    haml_tag :div do
      haml_tag :a, I18n.t('kudos.give_kudos'), href: '#', class: 'btn kudo-btn btn-primary btn-mini',
                                               onclick: "tb_show('#{label}', '#{path}', false); return false;"
    end
  end

  def kudo_account_link(kudo)
    id = kudo.account.nil? ? '' : "kudo_given_link_#{kudo.account.login}"
    link_to h(kudo.account.name), account_path(kudo.account), id: id
  end

  def kudo_contribution_link(kudo)
    contrib = Contribution.generate_id_from_project_id_and_name_id(kudo.project_id, kudo.name_id)
    path = project_contributor_path(kudo.project, contrib)
    link_to("#{h(kudo.name.name)} (#{h(kudo.project.name)})", path, id: "kudo_given_link_#{kudo.sender.login}")
  end
end
# rubocop: enable Metrics/ModuleLength
