module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig(
		pkg:
			grunt.file.readJSON('package.json')
		coffee:
			options:
				sourceMap: false
			compile:
				files:
					'js/core.js': 'src/core.coffee'
					'js/game.js': 'src/game.coffee'
					'server.js': 'server.coffee'
		browserify:
			js:
				src: 'js/game.js'
				dest: 'js/bundle.js'
		watch:
			files: ['src/*.coffee', 'server.coffee']
			tasks: ['coffee', 'browserify']
	)

	# Load the plugin that provides the "uglify" task.
	# grunt.loadNpmTasks('grunt-contrib-uglify')

	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-browserify');
	grunt.loadNpmTasks('grunt-contrib-watch')

	# Default task(s).
	grunt.registerTask('default', ['coffee', 'browserify'])
