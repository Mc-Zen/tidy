
#import "/src/new-parser.typ": *

#let src = ```
/// Doc
#let aey(x) = text.with()
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "aey", 
      description: "Doc", 
      args: (x: (description: ""),), 
      curry-info: (name: "text"),
      return-types: none
    ),
  )
)

