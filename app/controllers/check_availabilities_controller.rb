class CheckAvailabilitiesController < ApplicationController
  # NOTE: Replaces accounts#resolve_login.
  def account
    q = params[:q].to_s
    account = Account.resolve_login(params[:q])
    render json: account ? account.attributes.merge(q: q) : { id: nil, q: q }
  end
end
