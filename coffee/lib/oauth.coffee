"use strict"

cookies = require("../tools/cookies")
oauthio_requests = require("./request")
sha1 = require("../tools/sha1")

module.exports = (Materia) ->
	Url = Materia.getUrl()
	config = Materia.getConfig()
	document = Materia.getDocument()
	window = Materia.getWindow()
	$ = Materia.getJquery()
	cache = Materia.getCache()

	providers_api = require('./providers') Materia

	config.oauthd_base = Url.getAbsUrl(config.oauthd_url).match(/^.{2,5}:\/\/[^/]+/)[0]

	client_states = []
	oauth_result = undefined

	(parse_urlfragment = ->
		results = /[\\#&]oauthio=([^&]*)/.exec(document.location.hash)
		if results
			document.location.hash = document.location.hash.replace(/&?oauthio=[^&]*/, "")
			oauth_result = decodeURIComponent(results[1].replace(/\+/g, " "))
			cookie_state = cookies.readCookie("oauthio_state")
			if cookie_state
				client_states.push cookie_state
				cookies.eraseCookie "oauthio_state"
		return
	)()

	location_operations = Materia.getLocationOperations()
	oauthio = request: oauthio_requests(Materia, client_states, providers_api)

	oauth = {
		initialize: (public_key, options) -> return Materia.initialize public_key, options
		setOAuthdURL: (url) ->
			config.oauthd_url = url
			config.oauthd_base = Url.getAbsUrl(config.oauthd_url).match(/^.{2,5}:\/\/[^/]+/)[0]
			return
		create: (provider, tokens, request) ->
			return cache.tryCache(oauth, provider, true)  unless tokens
			providers_api.fetchDescription provider  if typeof request isnt "object"
			make_res = (method) ->
				oauthio.request.mkHttp provider, tokens, request, method

			make_res_endpoint = (method, url) ->
				oauthio.request.mkHttpEndpoint provider, tokens, request, method, url

			res = {}
			for i of tokens
				res[i] = tokens[i]
			res.get = make_res("GET")
			res.post = make_res("POST")
			res.put = make_res("PUT")
			res.patch = make_res("PATCH")
			res.del = make_res("DELETE")
			res.me = oauthio.request.mkHttpMe provider, tokens, request, "GET"

			res

		popup: (provider, opts, callback) ->
			gotmessage = false
			getMessage = (e) ->
				if not gotmessage
					return  if e.origin isnt config.oauthd_base
					try
						wnd.close()
					opts.data = e.data
					oauthio.request.sendCallback opts, defer
					gotmessage = true
			wnd = undefined
			frm = undefined
			wndTimeout = undefined
			defer = $.Deferred()
			opts = opts or {}
			unless config.key
				defer?.reject new Error("OAuth object must be initialized")
				if not callback?
					return defer.promise()
				else
					return callback(new Error("OAuth object must be initialized"))
			if arguments.length is 2 and typeof opts == 'function'
				callback = opts
				opts = {}
			if cache.cacheEnabled(opts.cache)
				res = cache.tryCache(oauth, provider, opts.cache)
				if res
					defer?.resolve res
					if callback
						return callback(null, res)
					else
						return defer.promise()
			unless opts.state
				opts.state = sha1.create_hash()
				opts.state_type = "client"
			client_states.push opts.state
			url = config.oauthd_url + "/auth/" + provider + "?k=" + config.key
			url += "&d=" + encodeURIComponent(Url.getAbsUrl("/"))
			url += "&opts=" + encodeURIComponent(JSON.stringify(opts))  if opts

			if opts.wnd_settings
				wnd_settings = opts.wnd_settings
				delete opts.wnd_settings
			else
				wnd_settings =
					width: Math.floor(window.outerWidth * 0.8)
					height: Math.floor(window.outerHeight * 0.5)
			wnd_settings.width = 1000 if wnd_settings.width < 1000
			wnd_settings.height = 630 if wnd_settings.height < 630
			wnd_settings.left = Math.floor(window.screenX + (window.outerWidth - wnd_settings.width) / 2)
			wnd_settings.top = Math.floor(window.screenY + (window.outerHeight - wnd_settings.height) / 8)
			wnd_options = "width=" + wnd_settings.width + ",height=" + wnd_settings.height
			wnd_options += ",toolbar=0,scrollbars=1,status=1,resizable=1,location=1,menuBar=0"
			wnd_options += ",left=" + wnd_settings.left + ",top=" + wnd_settings.top
			opts =
				provider: provider
				cache: opts.cache

			opts.callback = (e, r) ->
				if window.removeEventListener
					window.removeEventListener "message", getMessage, false
				else if window.detachEvent
					window.detachEvent "onmessage", getMessage
				else document.detachEvent "onmessage", getMessage  if document.detachEvent
				opts.callback = ->

				if wndTimeout
					clearTimeout wndTimeout
					wndTimeout = `undefined`
				(if callback then callback(e, r) else `undefined`)

			if window.attachEvent
				window.attachEvent "onmessage", getMessage
			else if document.attachEvent
				document.attachEvent "onmessage", getMessage
			else window.addEventListener "message", getMessage, false  if window.addEventListener
			if typeof chrome isnt "undefined" and chrome.runtime and chrome.runtime.onMessageExternal
				chrome.runtime.onMessageExternal.addListener (request, sender, sendResponse) ->
					request.origin = sender.url.match(/^.{2,5}:\/\/[^/]+/)[0]
					getMessage request

			if not frm and (navigator.userAgent.indexOf("MSIE") isnt -1 or navigator.appVersion.indexOf("Trident/") > 0)
				frm = document.createElement("iframe")
				frm.src = config.oauthd_url + "/auth/iframe?d=" + encodeURIComponent(Url.getAbsUrl("/"))
				frm.width = 0
				frm.height = 0
				frm.frameBorder = 0
				frm.style.visibility = "hidden"
				document.body.appendChild frm
			wndTimeout = setTimeout(->
				defer?.reject new Error("Authorization timed out")
				if opts.callback and typeof opts.callback == "function"
					opts.callback new Error("Authorization timed out")
				try
					wnd.close()
				return
			, 1200 * 1000)

			wnd = window.open(url, "Authorization", wnd_options)
			if wnd
				wnd.focus()
				interval = window.setInterval () ->
					if wnd == null || wnd.closed
						window.clearInterval interval
						if not gotmessage
							defer?.reject new Error("The popup was closed")
							opts.callback new Error("The popup was closed")  if opts.callback and typeof opts.callback == "function"
				, 500
			else
				defer?.reject new Error("Could not open a popup")
				opts.callback new Error("Could not open a popup")  if opts.callback and typeof opts.callback == "function"
			return defer?.promise()

		redirect: (provider, opts, url) ->
			if arguments.length is 2
				url = opts
				opts = {}
			if cache.cacheEnabled(opts.cache)
				res = cache.tryCache(oauth, provider, opts.cache)
				if res
					url = Url.getAbsUrl(url) + ((if (url.indexOf("#") is -1) then "#" else "&")) + "oauthio=cache"
					location_operations.changeHref url
					location_operations.reload()
					return
			unless opts.state
				opts.state = sha1.create_hash()
				opts.state_type = "client"
			cookies.createCookie "oauthio_state", opts.state
			redirect_uri = encodeURIComponent(Url.getAbsUrl(url))
			url = config.oauthd_url + "/auth/" + provider + "?k=" + config.key
			url += "&redirect_uri=" + redirect_uri
			url += "&opts=" + encodeURIComponent(JSON.stringify(opts))  if opts
			location_operations.changeHref url
			return

		callback: (provider, opts, callback) ->
			defer = $.Deferred()
			if arguments.length is 1 and typeof provider == "function"
				callback = provider
				provider = `undefined`
				opts = {}
			if arguments.length is 1 and typeof provider == "string"
				opts = {}
			if arguments.length is 2 and typeof opts == "function"
				callback = opts
				opts = {}
			if cache.cacheEnabled(opts.cache) or oauth_result is "cache"
				res = cache.tryCache(oauth, provider, opts.cache)
				if oauth_result is "cache" and (typeof provider isnt "string" or not provider)
					defer?.reject new Error("You must set a provider when using the cache")
					if callback
						return callback(new Error("You must set a provider when using the cache"))
					else
						return defer?.promise()
				if res
					if callback
						return callback(null, res)  if res
					else
						defer?.resolve res
						return defer?.promise()
			return  unless oauth_result
			oauthio.request.sendCallback {
				data: oauth_result
				provider: provider
				cache: opts.cache
				callback: callback }, defer

			return defer?.promise()

		clearCache: (provider) ->
			cookies.eraseCookie "oauthio_provider_" + provider
			return

		http_me: (opts) ->
			oauthio.request.http_me opts  if oauthio.request.http_me
			return

		http: (opts) ->
			oauthio.request.http opts  if oauthio.request.http
			return
		getVersion: () ->
			Materia.getVersion.apply this
	}
	return oauth
