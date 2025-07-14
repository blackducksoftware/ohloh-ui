# frozen_string_literal: true

class KudosController < ApplicationController
  before_action :session_required, :redirect_unverified_account, except: %i[index sent]
  before_action :verify_api_access_for_xml_request, only: %i[index sent]
  before_action :find_account, only: %i[index sent]
  before_action :find_account_or_contribution, only: %i[new create]
  before_action :find_kudo, only: [:destroy]
  before_action :make_new_kudo, only: %i[new create]

  before_action :account_context, only: [:index]

  def index
    @person = @account.person || Person.new(account_id: @account.id, effective_name: @account.name)
    @received_kudos = @account.kudos.includes(sender: :person).sort_by_created_at
    @sent_kudos = @account.sent_kudos.includes(:project, :name, sender: :person, account: :person).sort_by_created_at
  end

  def sent
    @sent_kudos = @account.sent_kudos
  end

  def new
    render layout: false
  end

  def create
    if @kudo.save
      flash[:success] = kudos_creation_success_flash_msg
    else
      flash[:error] = @kudo.errors.full_messages.first
    end
    redirect_to_saved_path
  end

  def destroy
    if current_user == @kudo.sender || current_user == @kudo.account
      @kudo.destroy
      flash[:success] = t('.success')
    else
      flash[:error] = t('.error')
    end
    redirect_to_saved_path
  end

  private

  def find_account
    @account = Account.from_param(params[:account_id]).take
    raise ParamRecordNotFound unless @account
  end

  def find_account_or_contribution
    p = params[:kudo] || params
    @account = Account.from_param(p[:account_id]).take
    @contribution = Contribution.find_by(id: p[:contribution_id])
    raise ParamRecordNotFound unless @account || @contribution
  end

  def find_kudo
    @kudo = Kudo.find_by(id: params[:id])
    raise ParamRecordNotFound if @kudo.nil?
  end

  def make_new_kudo
    @kudo = Kudo.new(message: params[:kudo] && params[:kudo][:message], sender: current_user, account: @account)
    @kudo.assign_attributes(project: @contribution.project, name: @contribution.name_fact.name) if @contribution
  end

  def kudos_creation_success_flash_msg
    if @account
      t('.success_account', name: @account.name)
    else
      t('.success_contribution', name: @kudo.name.name, project: @kudo.project.name)
    end
  end
end
