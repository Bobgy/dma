module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig(
		pkg:
			grunt.file.readJSON('package.json')
		coffee:
			options:
				sourceMap: true
			server:
				files:
					'server.js': 'server.coffee'
			client:
				files:
					'js/core.js': 'src/core.coffee'
					'js/game.js': 'src/game.coffee'
		coffeeify:
			options:
				debug: true
			game:
				src: 'src/game.coffee'
				dest: 'js/bundle.js'
		watch:
			files: ['coffee/*.coffee', 'server.coffee']
			tasks: ['coffee', 'browserify']
	)

	# Load the plugin that provides the "uglify" task.
	# grunt.loadNpmTasks('grunt-contrib-uglify')

	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-coffeeify')
	# Default task(s).
	grunt.registerTask('default', ['coffeeify'])
