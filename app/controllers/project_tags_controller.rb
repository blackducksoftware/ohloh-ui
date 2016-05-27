class ProjectTagsController < SettingsController
  helper ProjectsHelper
  helper TagsHelper

  before_action :session_required, :redirect_unverified_account, only: [:create, :destroy]
  before_action :set_project_or_fail, :set_project_editor_account_to_current_user
  before_action :edit_authorized_only!, only: [:create, :destroy]
  before_action :find_related_projects, only: [:index, :related]
  before_action :find_tagging, only: [:destroy]
  before_action :project_context

  def create
    @project.update_attributes(tag_list: "#{@project.tag_list} #{params[:tag_name]}")
    render text: ERB::Util.html_escape(@project.tag_list).split.sort.join("\n")
  rescue
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

  def find_tagging
    tag = Tag.where(name: params[:id]).take
    raise ParamRecordNotFound if tag.nil?
    @tagging = Tagging.where(taggable: @project, tag_id: tag.id).take
    raise ParamRecordNotFound if @tagging.nil?
  end

  def edit_authorized_only!
    render_unauthorized unless @project.edit_authorized?
  end

  def find_related_projects
    @related_projects = @project.related_by_tags
  end

  def render_create_error
    text = @project.errors.full_messages.map { |msg| ERB::Util.html_escape(msg) }.join('<br/>')
    render text: text, status: :unprocessable_entity
  end
end
