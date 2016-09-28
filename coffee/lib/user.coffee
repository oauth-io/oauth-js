"use strict"

module.exports = (OAuthio) ->
	$ = OAuthio.getJquery()
	config = OAuthio.getConfig()
	storage = OAuthio.getStorage()

	lastSave = null

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
			return OAuthio.API.put '/api/usermanagement/user?k=' + config.key + '&token=' + @token, dataToSave

		## todo select(provider)
		select: (provider) ->
			OAuthResult = null
			return OAuthResult

		saveLocal: () ->
			copy = token: @token, user: @data, providers: @providers
			storage.erase 'oio_auth'
			storage.create 'oio_auth', JSON.stringify(copy), 21600

		hasProvider: (provider) ->
			return @providers?.indexOf(provider) != -1

		getProviders: () ->
			defer = $.Deferred()
			OAuthio.API.get '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token
				.done (providers) =>
					@providers = providers.data
					@saveLocal()
					defer.resolve @providers
				.fail (err) ->
					defer.reject err
			return defer.promise()

		addProvider: (oauthRes) ->
			defer = $.Deferred()
			oauthRes = oauthRes.toJson() if typeof oauthRes.toJson == 'function'
			oauthRes.email = @data.email
			@providers.push oauthRes.provider
			OAuthio.API.post '/api/usermanagement/user/providers?k=' + config.key + '&token=' + @token, oauthRes
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
			OAuthio.API.del '/api/usermanagement/user/providers/' + provider + '?k=' + config.key + '&token=' + @token
				.done (res) =>
					@saveLocal()
					defer.resolve res
				.fail (err) =>
					@providers.push provider
					defer.reject err
			return defer.promise()

		# todo - not working
		changePassword: (oldPassword, newPassword) ->
			return OAuthio.API.post '/api/usermanagement/user/password?k=' + config.key + '&token=' + @token,
				password: newPassword
				#oldPassword ?

		#### 0.5.0 => remove this method
		isLoggued: () ->
			return OAuthio.User.isLogged()
		###########

		isLogged: () ->
			return OAuthio.User.isLogged()

		logout: () ->
			defer = $.Deferred()
			storage.erase 'oio_auth'
			OAuthio.API.post('/api/usermanagement/user/logout?k=' + config.key + '&token=' + @token)
				.done ->
					defer.resolve()
				.fail (err)->
					defer.reject err

			return defer.promise()
	return {
		initialize: (public_key, options) -> return OAuthio.initialize public_key, options
		setOAuthdURL: (url) -> return OAuthio.setOAuthdURL url
		signup: (data) ->
			defer = $.Deferred()
			data = data.toJson() if typeof data.toJson == 'function'
			OAuthio.API.post '/api/usermanagement/signup?k=' + config.key, data
				.done (res) ->
					storage.create 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.reject err

			return defer.promise()

		signin: (email, password) ->
			defer = $.Deferred()
			if typeof email != "string" and not password
				# signin(OAuthRes)
				signinData = email
				signinData = signinData.toJson() if typeof signinData.toJson == 'function'
				OAuthio.API.post '/api/usermanagement/signin?k=' + config.key, signinData
					.done (res) ->
						storage.create 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
						defer.resolve new UserObject(res.data)
					.fail (err) ->
						defer.reject err
			else
				# signin(email, password)
				OAuthio.API.post('/api/usermanagement/signin?k=' + config.key,
					email: email
					password: password
				).done((res) ->
					storage.create 'oio_auth', JSON.stringify(res.data), res.data.expires_in || 21600
					defer.resolve new UserObject(res.data)
				).fail (err) ->
					defer.reject err
			return defer.promise()

		confirmResetPassword: (newPassword, sptoken) ->
			return OAuthio.API.post '/api/usermanagement/user/password?k=' + config.key,
				password: newPassword
				token: sptoken

		resetPassword: (email, callback) ->
			OAuthio.API.post '/api/usermanagement/user/password/reset?k=' + config.key, email: email

		refreshIdentity: () ->
			defer = $.Deferred()
			OAuthio.API.get('/api/usermanagement/user?k=' + config.key + '&token=' + JSON.parse(storage.read('oio_auth')).token)
				.done (res) ->
					defer.resolve new UserObject(res.data)
				.fail (err) ->
					defer.reject err
			return defer.promise()

		getIdentity: () ->
			user = storage.read 'oio_auth'
			return null if not user
			return new UserObject(JSON.parse(user))

		isLogged: () ->
			a = storage.read 'oio_auth'
			return true if a
			return false
	}
