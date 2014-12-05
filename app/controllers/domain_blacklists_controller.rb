class DomainBlacklistsController < ApplicationController
  #  layout_params :admin_layout_params

  before_action :admin_session_required
  before_action :set_domain_blacklist, only: [:update, :destroy, :edit]

  def index
    @domain_blacklists = DomainBlacklist.all
    flash[:notice] = t('.notice') unless @domain_blacklists.present?
  end

  def new
    @domain_blacklist = DomainBlacklist.new
  end

  def create
    @domain_blacklist = DomainBlacklist.new(domain_blacklist_params)
    if @domain_blacklist.save
      redirect_to domain_blacklists_path, flash: { success: t('.success') }
    else
      redirect_to new_domain_blacklist_path, flash: { error: t('.error') }
    end
  end

  def update
    if @domain_blacklist.update(domain_blacklist_params)
      redirect_to domain_blacklists_path, flash: { success: t('.success') }
    else
      redirect_to edit_domain_blacklist_path, flash: { error: t('.error') }
    end
  end

  def destroy
    @domain_blacklist.destroy
    redirect_to domain_blacklists_path, notice: t('.success')
  end

  private

  def set_domain_blacklist
    @domain_blacklist = DomainBlacklist.find(params[:id])
  end

  def domain_blacklist_params
    params.require(:domain_blacklist).permit(:domain)
  end
end
