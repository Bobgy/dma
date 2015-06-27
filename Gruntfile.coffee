module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig(
    pkg:
      grunt.file.readJSON('package.json')
    coffee:
      options:
        sourceMap: true
      compile:
        expand: true
        ext: '.js'
        cwd: 'src/'
        src: '**/*.coffee'
        dest: 'lib/'
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
      client:
        src: 'src/Client.coffee'
        dest: 'js/client.js'
    watch:
      files: ['src/**/*.coffee']
      tasks: ['coffee', 'browserify']
  )

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-coffeeify')

  # Default task(s).
  grunt.registerTask('default', ['coffee', 'browserify'])
