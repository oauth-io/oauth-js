"use strict"

module.exports = (oio) ->
	signup: (email, username, password, firstname, lastname, data, callback) ->
		if typeof email != 'string' and (typeof username == 'function' or typeof password == 'function')
			cb = if typeof username == 'function' then username else password
			oio.API.post '/signup?public_key=' + @pubKey, (
				access_token: email.access_token
				provider: email.provider
				k: @pubKey
				email: if typeof username != 'function' then username else null
			), cb
		else
			oio.API.post '/signup?public_key=' + @pubKey, (
				username: username
				email: email
				password: password
				firstname: firstname
				lastname: lastname
				data: data
			), callback

	signin: (email, password, callback) ->
		if typeof email != "string" and typeof password == 'function' and typeof callback == undefined
			callback = password
			oio.API.post '/signin?public_key=' + @pubKey, (
				access_token: email.access_token
				provider: email.provider
				k: @pubKey
			), callback

			#oauth email == {access_token: 'fdsfds', expires_in......}
		else
			oio.API.post '/signin?public_key=' + @pubKey, (
				email: email
				password: password
			), callback

			#email password

	resetPassword: (email, callback) ->
		oio.API.post '/usermanagement/password/reset?public_key=' + @pubKey, email: email, callback

	getIdentity: () ->
		oio.API.get '/usermanagement/user?public_key=' + @pubKey, null, (err, data) ->
			return new UserObject(data)

	isLogged: () ->