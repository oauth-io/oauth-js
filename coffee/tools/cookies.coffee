"use strict"

module.exports =
	init: (config, document) ->
		@config = config
		@document = document

	create: (name, value, expires) ->
			@erase name
			date = new Date()
			if expires
				date.setTime date.getTime() + (expires or 1200) * 1000 # def: 20 mins
			else
				date.setFullYear date.getFullYear() + 3
			expires = "; expires=" + date.toGMTString()
			@document.cookie = name + "=" + value + expires + "; path=/"
			return

	read: (name) ->
		nameEQ = name + "="
		ca = @document.cookie.split(";")
		i = 0

		while i < ca.length
			c = ca[i]
			c = c.substring(1, c.length)  while c.charAt(0) is " "
			return c.substring(nameEQ.length, c.length)  if c.indexOf(nameEQ) is 0
			i++
		null

	erase: (name) ->
		date = new Date()
		date.setTime date.getTime() - 86400000
		@document.cookie = name + "=; expires=" + date.toGMTString() + "; path=/"
		return

	eraseFrom: (prefix) ->
		cookies = @document.cookie.split(";")
		for cookie in cookies
			cname = cookie.split("=")[0].trim()
			if cname.substr(0, prefix.length) == prefix
				@erase(cname)
		return