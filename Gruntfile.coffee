module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig(
		pkg:
			grunt.file.readJSON('package.json')
		coffee:
			options:
				sourceMap: true
			compile:
				files:
					'server.js': 'server.coffee'
					'js/game.js': 'js/game.coffee'
	)

	# Load the plugin that provides the "uglify" task.
	# grunt.loadNpmTasks('grunt-contrib-uglify')

	# Default task(s).
	# grunt.registerTask('default', ['uglify'])

	grunt.loadNpmTasks('grunt-contrib-coffee')