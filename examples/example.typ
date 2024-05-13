#import "wiggly.typ"
// #import "@preview/tidy:0.1.0":*
#import "/src/tidy.typ":*

#set text(size: 10pt, font: "Calibri")

#show heading.where(level: 1): set text(size: 3em)
#show heading.where(level: 2): set text(size: 2em)
// #show heading.where(level: 3): underline
#show heading.where(level: 3): set text(size: 1.5em, font: "Cascadia Mono")
#show heading.where(level: 3): block.with(below: 2em)
#show heading.where(level: 4): set text(size: 1.3em)
#show heading.where(level: 5): set text(size: 1.2em, font: "Cascadia Mono")

#let docs = parse-module(
  read("wiggly.typ"), 
  name: "wiggly", 
  scope: (wiggly: wiggly)
)
#show-module(docs, style: styles.default)


