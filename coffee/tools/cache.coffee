"use strict"

module.exports =
	init: (cookies_module, config) ->
		@config = config
		@cookies = cookies_module
	tryCache: (OAuth, provider, cache) ->
			if @cacheEnabled(cache)
				cache = @cookies.readCookie("oauthio_provider_" + provider)
				return false  unless cache
				cache = decodeURIComponent(cache)
			if typeof cache is "string"
				try cache = JSON.parse(cache)
				catch e
					return false
			if typeof cache is "object"
				res = {}
				for i of cache
  					res[i] = cache[i]  if i isnt "request" and typeof cache[i] isnt "function"
				return OAuth.create(provider, res, cache.request)
			false

	storeCache: (provider, cache) ->
		expires = 3600
		if cache.expires_in
			expires = cache.expires_in
		else if @config.options.expires || @config.options.expires == false
			expires = @config.options.expires

		@cookies.createCookie "oauthio_provider_" + provider, encodeURIComponent(JSON.stringify(cache)), expires
		return

	cacheEnabled: (cache) ->
		return @config.options.cache  if typeof cache is "undefined"
		cache