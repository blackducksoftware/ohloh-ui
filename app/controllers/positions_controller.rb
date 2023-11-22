# frozen_string_literal: true

require 'will_paginate/array'
class PositionsController < ApplicationController
  helper ProjectsHelper
  helper PositionsHelper
  include PositionFilters

  def new
    @position = Position.new
  end

  def update
    Position.transaction do
      @position.language_experiences.delete_all
      @position.update!(position_params)
    end
    redirect_to account_positions_path(@account)
  rescue StandardError => e
    flash.now[:error] = e.message unless e.is_a?(ActiveRecord::RecordInvalid)
    render :edit
  end

  def create
    project = find_project_by_oss
    @position = @account.positions.where(project_id: project).first_or_initialize
    @position.attributes = position_params
    if @position.save
      flash_invite_success_if_needed
      redirect_to account_positions_path(@account)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    if @position.destroy
      redirect_to account_positions_path, notice: t('destroy.success')
    else
      redirect_to_saved_path(flash: { error: t('destroy.failure') })
    end
  end

  def index
    @positions = @account.position_core.ordered.paginate(page: page_param, per_page: 10)
  end

  def commits_compound_spark
    spark_image = Rails.cache.fetch("position/#{@position.id}/commits_compound_spark", expires_in: 4.hours) do
      Spark::CompoundSpark.new(@name_fact.monthly_commits(11), max_value: 50).render.to_blob
    end
    send_data spark_image, type: 'image/png', filename: 'position_commits_compound_spark.png', disposition: 'inline'
  end

  def one_click_create
    pos_or_alias_obj = current_user.position_core.ensure_position_or_alias!(@project, @name)
    return redirect_to_new_position_path unless pos_or_alias_obj

    flash_msg =
      if pos_or_alias_obj.is_a?(Alias)
        t('.alias', name: @name.name, preferred_name: pos_or_alias_obj.preferred_name.name)
      else
        t('.position', name: @name.name)
      end

    redirect_to account_positions_path(current_user), flash: { success: flash_msg }
  end

  private

  def flash_invite_success_if_needed
    flash[:success] = t('.invite_success') if params[:invite].present? && @account.created_at > 1.day.ago
  end

  def redirect_to_new_position_path
    redirect_to new_account_position_path(current_user, committer_name: @name.name,
                                                        project_name: @project.name,
                                                        invite: params[:invite]),
                flash: { success: t('positions.one_click_create.new_position', name: @name.name) }
  end

  def params_id_is_total?
    params[:id].casecmp('total').zero?
  end

  def position_params
    params.require(:position)
          .permit(:project_oss, :committer_name, :title, :organization_id, :organization_name,
                  :affiliation_type, :description, :start_date, :stop_date, :ongoing, :invite,
                  language_exp: [], project_experiences_attributes: %i[project_name _destroy id])
  end

  def find_project_by_oss
    Project.not_deleted.find_by('lower(name) = ? or name = ?', position_params['project_oss'].to_s.downcase,
                                position_params['project_oss'])
  end
end
