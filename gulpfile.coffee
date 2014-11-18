gulp = require('gulp')
child_process = require('child_process')


gulp.task 'jekyll', ->
  return child_process.spawn('jekyll', ['build'], stdio: [0, 1, 'pipe']).stderr


gulp.task 'default', ['jekyll']
