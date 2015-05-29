module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig(
		pkg:
			grunt.file.readJSON('package.json')
		coffee:
			core:
				src: 'src/core.coffee'
				dest: 'js/core.js'
			server:
				src: 'server.coffee'
				dest: 'server.js'
			client:
				src: 'src/game.coffee'
				dest: 'js/game.js'
		coffeeify:
			options:
				debug: true
			game:
				src: 'src/game.coffee'
				dest: 'js/bundle.js'
		watch:
			files: ['src/*.coffee']
			tasks: ['coffeeify']
	)

	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-coffeeify')

	# Default task(s).
	grunt.registerTask('default', ['coffeeify'])
