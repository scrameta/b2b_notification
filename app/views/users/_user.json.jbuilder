json.(user, :id, :username)
json.token user.generate_jwt
