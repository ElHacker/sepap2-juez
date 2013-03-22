fs = require 'fs'
exec = require('child_process').exec

class Evaluator
  @compile: (command, callback) ->
    child_compile = exec command, callback

  @execute: (executable_name, callback) ->
    child_execute = exec (executable_name), callback

module.exports = Evaluator
