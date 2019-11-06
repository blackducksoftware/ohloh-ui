# frozen_string_literal: true

# rubocop: disable InverseOf

class Action < ActiveRecord::Base
  attr_reader :payload_required

  belongs_to :account
  belongs_to :claim, class_name: 'Person', foreign_key: 'claim_person_id'
  belongs_to :stack_project, class_name: 'Project', foreign_key: 'stack_project_id'

  validates :account, presence: true
  validate :action_payload_present
  validate :claim_is_claimable, on: :create

  STATUSES = { completed: 'completed',
               after_activation: 'after_activation',
               nag_once: 'remind_once',
               remind: 'remind' }.freeze

  def initialize(attributes = {})
    attributes ||= {}
    super attributes.merge(parse_action(attributes.delete(:_action)))
  end

  def run
    return if !stack_project || account.stacks.count > 1

    account.stack_core.default.projects << stack_project
    update status: STATUSES[:remind]
  end

  private

  def parse_action(action_and_id)
    action, id = (action_and_id || '').split('_')
    case action
    when 'stack'
      projects = Project.arel_table
      { stack_project: Project.find_by(projects[:id].eq(id).or(projects[:vanity_url].eq(id))) }
    when 'claim'
      { claim: Person.find(id) }
    else
      {}
    end
  end

  def action_payload_present
    return unless claim.nil? && stack_project.nil?

    errors.add :payload_required
  end

  def claim_is_claimable
    return if !claim || (claim.project && claim.name)

    errors.add :claim, I18n.t('actions.account_never_contributed')
  end
end

# rubocop: enable InverseOf
