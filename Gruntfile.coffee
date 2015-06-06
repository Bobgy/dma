module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig(
		pkg:
			grunt.file.readJSON('package.json')
		coffeeify:
			options:
				debug: true
			game:
				src: 'src/client.coffee'
				dest: 'js/bundle.js'
		watch:
			files: ['src/*.coffee', 'src/scripts/skills/*.coffee', 'src/scripts/*.coffee']
			tasks: ['coffeeify']
	)

	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-coffeeify')

	# Default task(s).
	grunt.registerTask('default', ['coffeeify'])
