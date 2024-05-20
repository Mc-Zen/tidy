#import "/src/tidy.typ": *
#import "wiggly.typ"

#let docs = parse-module(
  read("/examples/wiggly.typ"), 
  name: "wiggly", 
  scope: (wiggly: wiggly),
  preamble: "import wiggly: *;"
)
#show-module(docs, style: styles.minimal)
