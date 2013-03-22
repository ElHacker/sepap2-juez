fs = require 'fs'
asyncblock = require 'asyncblock'
Evaluator = require '../lib/Evaluator'

json = {
  command: (context) -> "gcc -x c -o #{context.executable} #{context.source}",
  source:"\"#include<stdio.h>\\n\\nmain()\\n{\\n    printf(\\\"Hello World\\\\n\\\");\\n \\n    printf(\\\"Bye World\\\\n\\\");\\n return 0;\\n}\\n\"",
  lang:"C",
  attempt_id:"1",
  cases: {
    "1" : { "input":"in", "output" : "Hello World"} ,
    "2" : { "input":"in", "output" : "Hello World\nBye World\n"} ,
    "3" : { "input":"in", "output" : "Hello World"} 
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

        compile_cb = (error, stdout, stderr) =>
          if error?
            res.json(500, {error})
          else
            console.log "STDOUT: #{stdout}"
            console.log "STDERR: #{stderr}"
            asyncblock( (flow) ->
              console.log json.casos
              for key, value of json.cases
                Evaluator.execute("./main", flow.add(key))
              stdout_results = flow.wait()
              results = {}
              for key, value of json.cases
                results[key] = 
                  "expected" : json.cases[key].output
                  "obtained" : stdout_results[key]
                  "passed" : json.cases[key].output == stdout_results[key]
              res.json(200, results)
            )
        Evaluator.compile((json.command executable: 'main', source: 'main.c'), compile_cb)
