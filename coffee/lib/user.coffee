"use strict"

module.exports = (oio) ->
	$ = oio.getJquery()
	config = oio.getConfig()
	cookieStore = oio.getCookies()

	class UserObject
		constructor: (@data) ->
			console.log @data

		save: () ->

		select: (provider) ->
			OAuthResult = null
			return OAuthResult

		###
		oio.OAuth.popup('facebook').then(function(res) {
			res.provider = 'facebook'
			return oio.User.signin(res)
		}).then(function(user) {
			return user.select('google')
		}).then(function(google) {
			return google.me()
		}).done(function(me) {
			...
		}).fail(function(err) {
			todo_with_err()
		})
		###

		getProviders: () ->
			return oio.API.get '/api/usermanagement/providers?k=' + config.key + '&token=' + @token

		addProvider: (oauthRes) ->
			return oio.API.post '/api/usermanagement/providers?k=' + config.key + '&token=' + @token

		changePassword: (oldPassword, newPassword) ->
			return oio.API.post '/api/usermanagement/user/passwordk=' + config.key + '&token=' + @token,
				password: newPassword
				#oldPassword ?

		isLoggued: () ->
			return oio.User.isLogged()

		logout: () ->
			defer = $.Defered()
			oio.API.post('/api/usermanagement/user/logout?k=' + config.key + '&token=' + @token).done (->
				cookieStore.eraseCookie 'oio_auth'
				defer.resolve()
			).fail (err)->
				defer.fail err
			return defer.promise()
	return {
		signup: (email, password, firstname, lastname, data) ->
			defer = $.Defered()
			if typeof email != 'string'
				# signup(OAuthRes[, email])
				oio.API.post('/api/usermanagement/signup?k=' + config.key,
					access_token: email.access_token
					provider: email.provider
					email: if password then password else null
				).done ((res) ->
					cookieStore.createCookie 'oio_auth', res.data.token, res.data.expire_in
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.fail err
			else
				# signup(email, password, firstname, lastname, data)
				oio.API.post('/api/usermanagement/signup?k=' + config.key,
					email: email
					password: password
					firstname: firstname
					lastname: lastname
					data: data
				).done ((res) ->
					cookieStore.createCookie 'oio_auth', res.data.token, res.data.expire_in
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.fail err

		signin: (email, password) ->
			defer = $.Defered()
			if typeof email != "string" and not password
				# signin(OAuthRes)
				oio.API.post('/api/usermanagement/signin?k=' + config.key,
					access_token: email.access_token
					provider: email.provider
				).done ((res) ->
					cookieStore.createCookie 'oio_auth', res.data.token, res.data.expire_in
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.fail err
			else
				# signin(email, password)
				oio.API.post('/api/usermanagement/signin?k=' + config.key,
					email: email
					password: password
				).done ((res) ->
					cookieStore.createCookie 'oio_auth', res.data.token, res.data.expire_in
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.fail err
			return defere.promise()

		resetPassword: (email, callback) ->
			oio.API.post '/api/usermanagement/password/reset?k=' + config.key, email: email

		getIdentity: () ->
			defer = $.Defered()
			oio.API.get('/api/usermanagement/user?k=' + config.key)
				.done (res) ->
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.reject err
			return defer.promise()

		isLogged: () ->
			a = cookieStore.readCookie 'oio_auth'
			return true if a
			return false
	}