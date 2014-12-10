class SessionsController < ApplicationController
  def new
    @login = OpenStruct.new
  end

  def create
    # authenticator = Authenticator.new(login: params[:login], password: params[:password])
  end

  def destroy
  end
end
