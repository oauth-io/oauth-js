"use strict"

Url = require('../tools/url')()

module.exports = (Materia, client_states, providers_api) ->
	$ = Materia.getJquery()
	config = Materia.getConfig()
	cache = Materia.getCache()
	extended_methods = []

	fetched_methods = false
	retrieveMethods: () ->
		defer = $.Deferred()
		if not fetched_methods
			$.ajax(config.oauthd_url + '/api/extended-endpoints')
				.then (data) ->
					extended_methods = data.data
					fetched_methods = true
					defer.resolve()
				.fail (e) ->
					fetched_methods = true
					defer.reject(e)
		else
			defer.resolve extended_methods
		return defer.promise()

	generateMethods: (request_object, tokens, provider) ->
		if extended_methods?
			for v, k in extended_methods
				# v is a method to add
				name_array = v.name.split '.'
				pt = request_object
				for vv, kk in name_array
					if kk < name_array.length - 1
						if not pt[vv]?
							pt[vv] = {}
						pt = pt[vv]
					else
						pt[vv] = @mkHttpAll provider, tokens, v, arguments

	http: (opts) ->
		doRequest = ->
			request = options.oauthio.request or {}
			unless request.cors
				options.url = encodeURIComponent(options.url)
				options.url = "/" + options.url  unless options.url[0] is "/"
				options.url = config.oauthd_url + "/request/" + options.oauthio.provider + options.url
				options.headers = options.headers or {}
				options.headers.oauthio = "k=" + config.key
				options.headers.oauthio += "&oauthv=1"  if options.oauthio.tokens.oauth_token and options.oauthio.tokens.oauth_token_secret # make sure to use oauth 1
				for k of options.oauthio.tokens
					options.headers.oauthio += "&" + encodeURIComponent(k) + "=" + encodeURIComponent(options.oauthio.tokens[k])
				delete options.oauthio

				return $.ajax(options)
			if options.oauthio.tokens
				#Fetching the url if a common endpoint is called
				options.oauthio.tokens.token = options.oauthio.tokens.access_token  if options.oauthio.tokens.access_token
				unless options.url.match(/^[a-z]{2,16}:\/\//)
					options.url = "/" + options.url  if options.url[0] isnt "/"
					options.url = request.url + options.url
				options.url = Url.replaceParam(options.url, options.oauthio.tokens, request.parameters)
				if request.query
					qs = []
					for i of request.query
  						qs.push encodeURIComponent(i) + "=" + encodeURIComponent(Url.replaceParam(request.query[i], options.oauthio.tokens, request.parameters))
					if "?" in options.url
						options.url += "&" + qs
					else
						options.url += "?" + qs
				if request.headers
					options.headers = options.headers or {}
					for i of request.headers
						options.headers[i] = Url.replaceParam(request.headers[i], options.oauthio.tokens, request.parameters)
				delete options.oauthio
				$.ajax options
		options = {}
		i = undefined
		for i of opts
			options[i] = opts[i]
		if not options.oauthio.request or options.oauthio.request is true
			desc_opts = wait: !!options.oauthio.request
			defer = $.Deferred()
			providers_api.getDescription options.oauthio.provider, desc_opts, (e, desc) ->
				return defer.reject(e)  if e
				if options.oauthio.tokens.oauth_token and options.oauthio.tokens.oauth_token_secret
					options.oauthio.request = desc.oauth1 and desc.oauth1.request
				else
					options.oauthio.request = desc.oauth2 and desc.oauth2.request
				defer.resolve()
				return

			return defer.then(doRequest)
		else
			return doRequest()
		return

	http_me: (opts) ->
		doRequest = ->
			defer = $.Deferred()
			request = options.oauthio.request or {}
			options.url = config.oauthd_url + "/auth/" + options.oauthio.provider + "/me"
			options.headers = options.headers or {}
			options.headers.oauthio = "k=" + config.key
			options.headers.oauthio += "&oauthv=1"  if options.oauthio.tokens.oauth_token and options.oauthio.tokens.oauth_token_secret # make sure to use oauth 1
			for k of options.oauthio.tokens
				options.headers.oauthio += "&" + encodeURIComponent(k) + "=" + encodeURIComponent(options.oauthio.tokens[k])
			delete options.oauthio

			promise = $.ajax(options)
			$.when(promise).done((data) ->
				defer.resolve data.data
				return
			).fail (data) ->
				if data.responseJSON
					defer.reject data.responseJSON.data
				else
					defer.reject new Error("An error occured while trying to access the resource")
				return

			defer.promise()
		options = {}
		for k of opts
			options[k] = opts[k]
		if not options.oauthio.request or options.oauthio.request is true
			desc_opts = wait: !!options.oauthio.request
			defer = $.Deferred()
			providers_api.getDescription options.oauthio.provider, desc_opts, (e, desc) ->
				return defer.reject(e)  if e
				if options.oauthio.tokens.oauth_token and options.oauthio.tokens.oauth_token_secret
					options.oauthio.request = desc.oauth1 and desc.oauth1.request
				else
					options.oauthio.request = desc.oauth2 and desc.oauth2.request
				defer.resolve()
				return

			return defer.then(doRequest)
		else
			return doRequest()
		return

	http_all: (options, endpoint_descriptor, parameters) ->
		doRequest = ->
			defer = $.Deferred()
			request = options.oauthio.request or {}
			options.headers = options.headers or {}
			options.headers.oauthio = "k=" + config.key
			options.headers.oauthio += "&oauthv=1"  if options.oauthio.tokens.oauth_token and options.oauthio.tokens.oauth_token_secret # make sure to use oauth 1
			for k of options.oauthio.tokens
				options.headers.oauthio += "&" + encodeURIComponent(k) + "=" + encodeURIComponent(options.oauthio.tokens[k])
			delete options.oauthio


			promise = $.ajax(options)
			$.when(promise).done((data) ->

				if typeof data.data == 'string'
					try
						data.data = JSON.parse data.data
					catch error
						data.data = data.data
					finally
						defer.resolve data.data
				return
			).fail (data) ->
				if data.responseJSON
					defer.reject data.responseJSON.data
				else
					defer.reject new Error("An error occured while trying to access the resource")
				return

			defer.promise()

		return doRequest()

	mkHttp: (provider, tokens, request, method) ->
		base = this
		(opts, opts2) ->
			options = {}
			if typeof opts is "string"
				if typeof opts2 is "object"
					for i of opts2
						options[i] = opts2[i]
				options.url = opts
			else if typeof opts is "object"
				for i of opts
					options[i] = opts[i]
			options.type = options.type or method
			options.oauthio =
				provider: provider
				tokens: tokens
				request: request

			base.http options

	mkHttpMe: (provider, tokens, request, method) ->
		base = this
		(filter) ->
			options = {}
			options.type = options.type or method
			options.oauthio =
				provider: provider
				tokens: tokens
				request: request

			options.data = options.data or {}
			options.data.filter = filter.join(",") if filter
			base.http_me options

	mkHttpAll: (provider, tokens, endpoint_descriptor) ->
		base = this
		() ->
			options = {}
			options.type = endpoint_descriptor.method
			options.url = config.oauthd_url + endpoint_descriptor.endpoint.replace ':provider', provider
			options.oauthio =
				provider: provider
				tokens: tokens
			options.data = {}
			for k, v of arguments
				th_param = endpoint_descriptor.params[k]
				if th_param?
					options.data[th_param.name] = v

			options.data = options.data or {}
			base.http_all options, endpoint_descriptor, arguments

	sendCallback: (opts, defer) ->
		base = this
		data = undefined
		err = undefined
		try
			data = JSON.parse(opts.data)
		catch e
			defer.reject new Error("Error while parsing result")
			return opts.callback(new Error("Error while parsing result"))
		return  if not data or not data.provider
		if opts.provider and data.provider.toLowerCase() isnt opts.provider.toLowerCase()
			err = new Error("Returned provider name does not match asked provider")
			defer.reject err
			if opts.callback and typeof opts.callback == "function"
				return opts.callback(err)
			else
				return
		if data.status is "error" or data.status is "fail"
			err = new Error(data.message)
			err.body = data.data
			defer.reject err
			if opts.callback and typeof opts.callback == "function"
				return opts.callback(err)
			else
				return
		if data.status isnt "success" or not data.data
			err = new Error()
			err.body = data.data
			defer.reject err
			if opts.callback and typeof opts.callback == "function"
				return opts.callback(err)
			else
				return

		#checking if state is known
		data.state = data.state.replace(/\s+/g,"")
		i = 0
		while i < client_states.length
		  client_states[i] = client_states[i].replace(/\s+/g,"")
		  i++

		if not data.state or client_states.indexOf(data.state) == -1
			defer.reject new Error("State is not matching")
			if opts.callback and typeof opts.callback == "function"
				return opts.callback(new Error("State is not matching"))
			else
				return
		data.data.provider = data.provider  unless opts.provider
		res = data.data
		res.provider = data.provider.toLowerCase()
		if cache.cacheEnabled(opts.cache) and res
			if opts.expires && ! res.expires_in
				res.expires_in = opts.expires
			cache.storeCache data.provider, res
		request = res.request
		delete res.request

		tokens = undefined
		if res.access_token
			tokens = access_token: res.access_token
		else if res.oauth_token and res.oauth_token_secret
			tokens =
				oauth_token: res.oauth_token
				oauth_token_secret: res.oauth_token_secret
		unless request
			defer.resolve res
			if opts.callback and typeof opts.callback == "function"
				return opts.callback(null, res)
			else
				return
		if request.required
			for i of request.required
				tokens[request.required[i]] = res[request.required[i]]
		make_res = (method) ->
			base.mkHttp data.provider, tokens, request, method

		res.toJson = ->
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

		res.get = make_res("GET")
		res.post = make_res("POST")
		res.put = make_res("PUT")
		res.patch = make_res("PATCH")
		res.del = make_res("DELETE")
		res.me = base.mkHttpMe(data.provider, tokens, request, "GET")

		@retrieveMethods()
			.then () =>
				@generateMethods res, tokens, data.provider
				defer.resolve res
				if opts.callback and typeof opts.callback == "function"
					opts.callback null, res
				else
					return
			.fail (e) =>
				console.log 'Could not retrieve methods', e
				defer.resolve res
				if opts.callback and typeof opts.callback == "function"
					opts.callback null, res
				else
					return
