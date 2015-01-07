class AccountsController < ApplicationController
  helper BadgesHelper

  def index
    @accounts = find_claimed_persons
    preload_claimed_persons(@accounts)
  end
end
