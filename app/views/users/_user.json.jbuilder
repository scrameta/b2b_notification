# frozen_string_literal: true

json.call(user, :id, :username)
json.token user.generate_jwt
