"use strict"

module.exports =
	init: (storage, config) ->
		@config = config
		@storage = storage
	tryCache: (OAuth, provider, cache) ->
			if @cacheEnabled(cache)
				cache = @storage.read("oauthio_provider_" + provider)
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

		@storage.create "oauthio_provider_" + provider, encodeURIComponent(JSON.stringify(cache)), expires
		return

	cacheEnabled: (cache) ->
		return @config.options.cache  if typeof cache is "undefined"
		cache
	
	clearCache: (provider) ->
		if provider
			@storage.erase "oauthio_provider_" + provider
		else
			@storage.eraseFrom "oauthio_provider_"
		return
		