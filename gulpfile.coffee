express = require('express')
gulp = require('gulp')
child_process = require('child_process')


gulp.task 'jekyll', ->
  return child_process.spawn('jekyll', ['build'], stdio: [0, 1, 'pipe']).stderr


gulp.task 'serve', ->
  server = express()
  server.use(express.static('_site'))
  server.listen(5000)
  return require('q').defer().promise


gulp.task 'data', ->
  require('./src/compile.coffee').run()


gulp.task 'data_subprocess', ->
  return child_process.spawn('gulp', ['data'], stdio: [0, 1, 'pipe']).stderr


gulp.task 'update', ->
  return child_process.spawn('scripts/update_eurostat_data.sh',
      ['data'],  stdio: [0, 1, 'pipe']).stderr

gulp.task 'devel', ->
  gulp.watch([
      '_config.yml'
      'index.html'
      'data/**/*'
      'web/**/*'
    ], ['jekyll'])

  gulp.watch([
      'src/**/*'
    ], ['data_subprocess'])

  gulp.start('data')
  gulp.start('jekyll')
  gulp.start('serve')


gulp.task 'default', ['jekyll']
