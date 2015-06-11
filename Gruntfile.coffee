module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig(
    pkg:
      grunt.file.readJSON('package.json')
    coffeeify:
      options:
        browserifyOptions:
          extensions: ['.coffee']
        debug: true
      game:
        src: 'src/client.coffee'
        dest: 'js/bundle.js'
    browserify:
      options:
        browserifyOptions:
          extensions: ['.coffee']
        debug: true
        transform: ['coffeeify']
      dist:
        src: 'src/client.coffee'
        dest: 'js/bundle.js'
    watch:
      files: ['src/**/*.coffee', 'server.coffee']
      ###
      files: ['src/*.coffee',
              'src/scripts/skills/*.coffee',
              'src/scripts/*.coffee',
              'src/scripts/patterns/*.coffee',
              'src/lib/*.coffee']
      ###
      tasks: ['browserify:dist']
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-coffeeify')

  # Default task(s).
  grunt.registerTask('default', ['browserify:dist'])
