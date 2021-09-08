# frozen_string_literal: true

module JWTHelper

    def build_jwt(user, valid_for_hours = 48)
        exp = Time.now.to_i + (valid_for_hours*60*60)
        payload = { "expiration": exp,
                    "user": user
        }
        JWT.encode( payload, ENV["JWT_SECRET"], 'HS256')
    end

    def decode_jwt(jwt)

        begin
            decoded_token = JWT.decode( params[:JWT], ENV["JWT_SECRET"], true)
            user = decoded_token[0]["user"]
            expiration = decoded_token[0]["expiration"]

            if Time.now > Time.at(expiration)
                return "JWT is expired, please generate a new one."
            end

            return Account.find_by(login: user)
        rescue JWT::DecodeError
            return "JWT::DecodeError"
        end
    end

    
end