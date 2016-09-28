"use strict"

config = require('../config')
Url = require("../tools/url")
Location = require('../tools/location_operations')
cookies = require("../tools/cookies")
lstorage = require("../tools/lstorage")
cache = require("../tools/cache")

module.exports = (window, document, jquery, navigator) ->
	Url = Url(document)
	location_operations = Location document
	storage = lstorage.active() && lstorage || cookies

	cookies.init config, document
	cache.init storage, config

	OAuthio =
		initialize: (public_key, options) ->
			config.key = public_key
			if options
				for i of options
					config.options[i] = options[i]
			return

		setOAuthdURL: (url) ->
			config.oauthd_url = url
			config.oauthd_base = Url.getAbsUrl(config.oauthd_url).match(/^.{2,5}:\/\/[^/]+/)[0]
			return

		getOAuthdURL: () -> return config.oauthd_url
		getVersion: () -> return config.version

		extend: (name, module) ->
			@[name] = module @

		# private
		getConfig: () -> return config
		getWindow: () -> return window
		getDocument: () -> return document
		getNavigator: () -> return navigator
		getJquery: () -> return jquery
		getUrl: () -> return Url
		getCache: () -> return cache
		getStorage: () -> return storage
		getLocationOperations: () -> return location_operations

	return OAuthio
