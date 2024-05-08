#import "/src/tidy.typ"
#set text(font: "Arial")

#set page(width: auto, height: auto, margin: 0em)



#import "/examples/sincx.typ" 

#let docs = tidy.parse-module(
  read("/examples/sincx.typ"), 
  scope: (sincx: sincx),
  preamble: "#import sincx: *;"
)

#set heading(numbering: none)
#block(
  width: 12cm, 
  fill: luma(255), 
  inset: 20pt,
  tidy.show-module(docs, show-outline: false)
)
