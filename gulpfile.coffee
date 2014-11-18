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


gulp.task 'devel', ->
  sourceFiles = [
    '_config.yml'
    'data/**/*'
    'gallery/**/*'
  ]
  gulp.watch(sourceFiles, ['jekyll'])
  gulp.start('jekyll')
  gulp.start('serve')


gulp.task 'default', ['jekyll']
