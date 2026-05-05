# frozen_string_literal: true

class ProjectTagsController < SettingsController
  helper ProjectsHelper
  helper TagsHelper

  before_action :session_required, :redirect_unverified_account, only: %i[create destroy]
  before_action :set_project_or_fail, :set_project_editor_account_to_current_user
  before_action :check_project_authorization, only: %i[create destroy]
  before_action :find_related_projects, only: %i[index related]
  before_action :find_tagging, only: [:destroy]
  before_action :project_context

  def index; end

  def create
    tag_name = params[:tag_name].to_s.strip
    return render plain: custom_description_error, status: :unprocessable_entity if duplicate_tag?(tag_name)

    @project.update!(tag_list: "#{@project.tag_list} #{tag_name}")
    render plain: ERB::Util.html_escape(@project.tag_list).split.sort.join("\n")
  rescue StandardError
    render_create_error
  end

  def destroy
    @tagging.destroy
    remaining = Tag::MAX_ALLOWED_PER_PROJECT - @project.tags.length
    render layout: false, json: [remaining, view_context.tags_left(remaining)]
  end

  def related
    render partial: 'related_projects'
  end

  def status
    remaining = Tag::MAX_ALLOWED_PER_PROJECT - @project.tags.length
    render layout: false, json: [remaining, view_context.tags_left(remaining)]
  end

  private

  def duplicate_tag?(tag_name)
    @project.tag_list.split.include?(tag_name)
  end

  def find_tagging
    tag = Tag.find_by(name: params[:id])
    raise ParamRecordNotFound if tag.nil?

    @tagging = Tagging.find_by(taggable: @project, tag_id: tag.id)
    raise ParamRecordNotFound if @tagging.nil?
  end

  def find_related_projects
    @related_projects = @project.related_by_tags.limit(5)
  end

  def render_create_error
    if @project.errors[:description].present?
      error_msg = @project.errors.full_messages
                          .map { |msg| ERB::Util.html_escape(msg) }
                          .join('<br/>')
    end
    error_msg ||= custom_description_error
    render plain: error_msg, status: :unprocessable_entity
  end
end
