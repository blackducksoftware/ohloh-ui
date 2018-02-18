class OhAdmin::DashboardController < ApplicationController
  before_action :admin_session_required
  layout 'admin'
  helper DashboardHelper
end
