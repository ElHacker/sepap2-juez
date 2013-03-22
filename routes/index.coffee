fs = require 'fs'
Evaluator = require '../lib/Evaluator'

json = {
  command: (context) -> "gcc -x c -o #{context.executable} #{context.source}",
  source:"\"#include<stdio.h>\\n\\nmain()\\n{\\n    printf(\\\"Hello World\\\\n\\\");\\n \\n    printf(\\\"Bye World\\\\n\\\");\\n return 0;\\n}\\n\"",
  lang:"C",
  attempt_id:"1",
  casos:{
    caso1:{in:"in",out:"Hello World"},
    caso2:{in:"in",out:"Hello World\nBye World"},
    caso3:{in:"in",out:"Hello World"}
  }
}

module.exports = 
  index: (req, res) ->
    res.render "index", title: "Express"

  evaluate: (req, res) ->
    fs.writeFile "./main.c", JSON.parse(json.source), (err) ->
      if err
        console.log err
      else
        console.log "The file was saved"
        execute_cb = (error, stdout, stderr) ->
          if error?
            console.log error
          else
            console.log "STDOUT-E: #{stdout}"
            console.log "STDERR-E: #{stderr}"
            res.send("STDOUT: #{stdout}")

        compile_cb = (error, stdout, stderr) ->
          if error?
            console.log error
          else
            console.log "STDOUT: #{stdout}"
            console.log "STDERR: #{stderr}"
            Evaluator.execute("./main", execute_cb)

        Evaluator.compile((json.command executable: 'main', source: 'main.c'), compile_cb)
