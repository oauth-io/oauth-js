"use strict"

module.exports = (oio) ->
	$ = oio.getJquery()
	config = oio.getConfig()
	cookieStore = oio.getCookies()

	class UserObject
		constructor: (data) ->
			@token = data.token
			@data = data.user
			@providers = data.providers
			@lastSave = @getEditableData()

		getEditableData: () ->
			data = []
			for key of @data
				if ['id', 'email'].indexOf(key) == -1
					data.push
						key: key
						value: @data[key]
			return data

		save: () ->
			#call to save on stormpath
			dataToSave = {}
			for d in @lastSave
				console.log d
				dataToSave[d.key] = @data[d.key] if @data[d.key] != d.value
				delete @data[d.key] if @data[d.key] == null
			@saveLocal()
			return oio.API.put '/api/usermanagement/user?k=' + config.key + '&token=' + @token, dataToSave

		## todo select(provider)
		select: (provider) ->
			OAuthResult = null
			return OAuthResult

		saveLocal: () ->
			copy = token: @token, user: @data, providers: @providers
			cookieStore.eraseCookie 'oio_auth'
			cookieStore.createCookie 'oio_auth', JSON.stringify(copy), 21600

		hasProvider: (provider) ->
			return @providers.indexOf(provider) != -1

		getProviders: () ->
			defer = $.Deferred()
			oio.API.get '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token
				.done (providers) =>
					@providers = providers.data
					@saveLocal()
					defer.resolve @providers
				.fail (err) ->
					defer.fail err
			return defer.promise()

		addProvider: (oauthRes) ->
			defer = $.Deferred()
			oauthRes = oauthRes.toJson() if typeof oauthRes.toJson == 'function'
			oauthRes.email = @data.email
			@providers.push oauthRes.provider
			oio.API.post '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token, oauthRes
				.done (res) =>
					@saveLocal()
					defer.resolve res
				.fail (err) =>
					@provider.splice @providers.indexOf(oauthRes.provider), 1
					defer.fail err
			return defer.promise()

		removeProvider: (provider) ->
			defer = $.Deferred()
			@providers.splice @providers.indexOf(provider), 1
			oio.API.del '/api/usermanagement/user/providers/' + provider + '?k=' + config.key + '&token=' + @token
				.done (res) =>
					@saveLocal()
					defer.resolve res
				.fail (err) =>
					@providers.push provider
					defer.fail err
			return defer.promise()

		# todo - not working
		changePassword: (oldPassword, newPassword) ->
			return oio.API.post '/api/usermanagement/user/password?k=' + config.key + '&token=' + @token,
				password: newPassword
				#oldPassword ?

		isLoggued: () ->
			return oio.User.isLogged()

		logout: () ->
			defer = $.Deferred()
			oio.API.post('/api/usermanagement/user/logout?k=' + config.key + '&token=' + @token)
				.done ->
					cookieStore.eraseCookie 'oio_auth'
					defer.resolve()
				.fail (err)->
					defer.fail err

			return defer.promise()
	return {
		initialize: (public_key, options) -> return oio.initialize public_key, options

		signup: (data) ->
			defer = $.Deferred()
			data = data.toJson() if typeof data.toJson == 'function'
			console.log data
			oio.API.post '/api/usermanagement/signup?k=' + config.key, data
				.done (res) ->
					cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.fail err

			return defer.promise()

		signin: (email, password) ->
			defer = $.Deferred()
			if typeof email != "string" and not password
				# signin(OAuthRes)
				signinData = email
				signinData = signinData.toJson() if typeof signinData.toJson == 'function'
				oio.API.post '/api/usermanagement/signin?k=' + config.key, signinData
					.done (res) ->
						console.log 'signed in', res
						cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
						defer.resolve new UserObject(res.data)
					.fail (err) ->
						defer.fail err
			else
				# signin(email, password)
				oio.API.post('/api/usermanagement/signin?k=' + config.key,
					email: email
					password: password
				).done((res) ->
					cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.fail err
			return defer.promise()

		confirmResetPassword: (newPassword, key) ->
			return oio.API.post '/api/usermanagement/user/password?k=' + config.key + '&token=' + @token,
				password: newPassword
				passwordKey: key

		resetPassword: (email, callback) ->
			oio.API.post '/api/usermanagement/password/reset?k=' + config.key, email: email

		refreshIdentity: () ->
			defer = $.Deferred()
			oio.API.get('/api/usermanagement/user?k=' + config.key + '&token=' + cookieStore.readCookie('oio_auth'))
				.done (res) ->
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.reject err
			return defer.promise()

		getIdentity: () ->
			return new UserObject(JSON.parse(cookieStore.readCookie('oio_auth')))

		isLogged: () ->
			a = cookieStore.readCookie 'oio_auth'
			return true if a
			return false
	}