"use strict"

module.exports = (Materia) ->
	$ = Materia.getJquery()
	config = Materia.getConfig()
	cookieStore = Materia.getCookies()

	lastSave = null

	oauthResToObject = (res) ->
		a = {}
		a.access_token = res.access_token if res.access_token?
		a.oauth_token = res.oauth_token if res.oauth_token?
		a.oauth_token_secret = res.oauth_token_secret if res.oauth_token_secret?
		a.expires_in = res.expires_in if res.expires_in?
		a.token_type = res.token_type if res.token_type?
		a.id_token = res.id_token if res.id_token?
		a.provider = res.provider if res.provider?
		a.email = res.email if res.email?
		return a

	class UserObject
		constructor: (data) ->
			@token = data.token
			@data = data.user
			@providers = data.providers
			lastSave = @getEditableData()

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
			for d in lastSave
				dataToSave[d.key] = @data[d.key] if @data[d.key] != d.value
				delete @data[d.key] if @data[d.key] == null
			keyIsInLastSave = (key) ->
				for o in lastSave
					return true if o.key == key
				return false

			for d in @getEditableData()
				if !keyIsInLastSave d.key
					dataToSave[d.key] = @data[d.key]
			@saveLocal()
			return Materia.API.put '/api/usermanagement/user?k=' + config.key + '&token=' + @token, dataToSave

		## todo select(provider)
		select: (provider) ->
			OAuthResult = null
			return OAuthResult

		saveLocal: () ->
			copy = token: @token, user: @data, providers: @providers
			cookieStore.eraseCookie 'oio_auth'
			cookieStore.createCookie 'oio_auth', JSON.stringify(copy), 21600

		hasProvider: (provider) ->
			return @providers?.indexOf(provider) != -1

		getProviders: () ->
			defer = $.Deferred()
			Materia.API.get '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token
				.done (providers) =>
					@providers = providers.data
					@saveLocal()
					defer.resolve @providers
				.fail (err) ->
					defer.reject err
			return defer.promise()

		addProvider: (oauthRes) ->
			defer = $.Deferred()
			oauthRes = oauthResToObject(oauthRes)
			oauthRes.email = @data.email
			@providers.push oauthRes.provider
			Materia.API.post '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token, oauthRes
				.done (res) =>
					@data = res.data
					@saveLocal()
					defer.resolve()
				.fail (err) =>
					@providers.splice @providers.indexOf(oauthRes.provider), 1
					defer.reject err
			return defer.promise()

		removeProvider: (provider) ->
			defer = $.Deferred()
			@providers.splice @providers.indexOf(provider), 1
			Materia.API.del '/api/usermanagement/user/providers/' + provider + '?k=' + config.key + '&token=' + @token
				.done (res) =>
					@saveLocal()
					defer.resolve res
				.fail (err) =>
					@providers.push provider
					defer.reject err
			return defer.promise()

		# todo - not working
		changePassword: (oldPassword, newPassword) ->
			return Materia.API.post '/api/usermanagement/user/password?k=' + config.key + '&token=' + @token,
				password: newPassword
				#oldPassword ?

		#### 0.5.0 => remove this method
		isLoggued: () ->
			return Materia.User.isLogged()
		###########

		isLogged: () ->
			return Materia.User.isLogged()

		logout: () ->
			defer = $.Deferred()
			cookieStore.eraseCookie 'oio_auth'
			Materia.API.post('/api/usermanagement/user/logout?k=' + config.key + '&token=' + @token)
				.done ->
					defer.resolve()
				.fail (err)->
					defer.reject err

			return defer.promise()
	return {
		initialize: (public_key, options) -> return Materia.initialize public_key, options
		setOAuthdURL: (url) -> return Materia.setOAuthdURL url
		signup: (data) ->
			defer = $.Deferred()
			data = oauthResToObject(data)
			Materia.API.post '/api/usermanagement/signup?k=' + config.key, data
				.done (res) ->
					cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.reject err

			return defer.promise()

		signin: (email, password) ->
			defer = $.Deferred()
			if typeof email != "string" and not password
				# signin(OAuthRes)
				signinData = email
				signinData = oauthResToObject(signinData)
				Materia.API.post '/api/usermanagement/signin?k=' + config.key, signinData
					.done (res) ->
						cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
						defer.resolve new UserObject(res.data)
					.fail (err) ->
						defer.reject err
			else
				# signin(email, password)
				Materia.API.post('/api/usermanagement/signin?k=' + config.key,
					email: email
					password: password
				).done((res) ->
					cookieStore.createCookie 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.reject err
			return defer.promise()

		confirmResetPassword: (newPassword, key) ->
			return Materia.API.post '/api/usermanagement/user/password?k=' + config.key + '&token=' + @token,
				password: newPassword
				passwordKey: key

		resetPassword: (email, callback) ->
			Materia.API.post '/api/usermanagement/password/reset?k=' + config.key, email: email

		refreshIdentity: () ->
			defer = $.Deferred()
			Materia.API.get('/api/usermanagement/user?k=' + config.key + '&token=' + JSON.parse(cookieStore.readCookie('oio_auth')).token)
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
