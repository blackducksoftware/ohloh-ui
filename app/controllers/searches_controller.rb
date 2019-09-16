# frozen_string_literal: true

class SearchesController < ApplicationController
  def account
    if request.xhr?
      accounts = Account.simple_search(params[:term])
      render json: accounts.map { |a| { id: a.to_param, value: a.login } }
    else
      redirect_to people_path(q: params[:term])
    end
  end
end
