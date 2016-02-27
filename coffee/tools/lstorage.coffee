"use strict"

useCache = (callback) ->
	cacheobj = localStorage.getItem('oauthio_cache')
	if cacheobj
		cacheobj = JSON.parse(cacheobj)
	else
		cacheobj = {}
	return callback cacheobj, ->
		localStorage.setItem('oauthio_cache', JSON.stringify(cacheobj))


module.exports =
	init: (config, document) ->
		@config = config
		@document = document

	active: -> localStorage?

	create: (name, value, expires) ->
			@erase name
			date = new Date()
			localStorage.setItem(name, value)
			useCache (cacheobj, cacheupdate) ->
				cacheobj[name] = if expires then date.getTime() + (expires or 1200) * 1000 else false
				cacheupdate()
			return

	read: (name) ->
		return useCache (cacheobj, cacheupdate) ->
			if ! cacheobj[name]?
				return null
			if cacheobj[name] == false
				return localStorage.getItem(name)
			else if (new Date()).getTime() > cacheobj[name]
				localStorage.removeItem(name)
				delete cacheobj[name]
				cacheupdate()
				return null
			else
				return localStorage.getItem(name)

	erase: (name) ->
		useCache (cacheobj, cacheupdate) ->
			localStorage.removeItem(name)
			delete cacheobj[name]
			cacheupdate()

	eraseFrom: (prefix) ->
		useCache (cacheobj, cacheupdate) ->
			cachenames = Object.keys(cacheobj)
			for name in cachenames
				if name.substr(0, prefix.length) == prefix
					localStorage.removeItem(name)
					delete cacheobj[name]
			cacheupdate()
		return
