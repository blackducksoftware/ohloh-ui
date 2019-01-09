class OhAdmin::BrokenLinksController < ApplicationController
  before_action :admin_session_required
  layout 'admin'

  def index
    @broken_links = BrokenLink.includes(link: :project)
                              .filter_by(params[:query])
                              .paginate(page: page_param, per_page: 20)
  end

  def destroy
    @broken_link = BrokenLink.find(params[:id])
    flash[:notice] = @broken_link.destroy ? t('.success') : t('.error')
    redirect_to oh_admin_broken_links_path
  end
end
