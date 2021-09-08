# frozen_string_literal: true

class Api::V1Controller < ApplicationController
    include JWTHelper
    skip_before_action :verify_authenticity_token

    def jwt
        params[:login] = {"login"=>params[:username], "password"=>params[:password], "remember_me"=>"0"}
        account_or_nil = authenticate(params)

        sign_in(account_or_nil) do |status|
            if status.success?
              test = build_jwt(params[:username])
              render json: test
            else
              render json: "Bad login info"
            end
          end        
    end   

    def unsubscribe

        account = decode_jwt(params[:JWT])
        if account.is_a? String
            render json: account and return
        end

        clearance_session.sign_in(account)
        puts account

        if account.present? and current_user_is_admin? 
            join_string = 'join code_locations on code_location_id = code_locations.id join repositories on code_locations.repository_id = repositories.id'
            filter_string = params[:url] + ' ' + params[:branch]
            enlistments = Enlistment.joins(:project).joins(join_string).filter_by(filter_string)

            for e in enlistments
                puts e.project
                #edit = e.create_edit
            end

            render json: enlistments and return    
        end

    
    end
end