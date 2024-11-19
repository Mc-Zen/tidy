#import "/src/new-parser.typ": *

// Variables

#let src = ```
///Description
let var = 23
```.text

#assert.eq(
  parse(src).variables,
  (
    (
      name: "var",
      description: "Description"
    ),
  )
)


// Functions

#let src = ```
///Description
let func() = { 34 }
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (:),
      return-types: none
    ),
  )
)