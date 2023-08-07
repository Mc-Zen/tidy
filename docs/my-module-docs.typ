#import "../src/tidy.typ": *
#set text(font: "Arial")

#set page(width: 300pt, height: auto, margin: 0em)

#show heading: set text(size: 1.5em)
#show heading.where(level: 4): set text(size: .7em)

#let example-code = read("../examples/my-module.typ")

#block(fill: luma(255), inset: 20pt,
{
  set text(size: .8em)
  let example-code-doc = parse-module(example-code)
  show-module(example-code-doc)
})