"use strict"

config = require("../config")

module.exports = (Materia) ->
	$ = Materia.getJquery()

	providers_desc = {}
	providers_cb = {}
	providers_api =
		execProvidersCb: (provider, e, r) ->
			if providers_cb[provider]
				cbs = providers_cb[provider]
				delete providers_cb[provider]

				for i of cbs
					cbs[i] e, r
			return

		fetchDescription: (provider) ->
			return if providers_desc[provider]
			providers_desc[provider] = true
			$.ajax(
				url: config.oauthd_api + "/providers/" + provider
				data:
					extend: true

				dataType: "json"
			).done((data) ->
				providers_desc[provider] = data.data
				providers_api.execProvidersCb provider, null, data.data
				return
			).always ->
				if typeof providers_desc[provider] isnt "object"
					delete providers_desc[provider]

					providers_api.execProvidersCb provider, new Error("Unable to fetch request description")
				return

			return

		getDescription: (provider, opts, callback) ->
			opts = opts or {}
			return callback(null, providers_desc[provider])  if typeof providers_desc[provider] is "object"
			providers_api.fetchDescription provider  unless providers_desc[provider]
			return callback(null, {})  unless opts.wait
			providers_cb[provider] = providers_cb[provider] or []
			providers_cb[provider].push callback
			return

	return providers_api
