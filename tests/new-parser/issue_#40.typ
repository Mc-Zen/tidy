#import "/src/new-parser.typ": *


// Default args as strings containing  "//"

#let src = ```
///Description
let func(
  link: "//"
)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (
        link: (default: "\"//\"", description: ""),
      ),
      return-types: none
    ),
  )
)


// Check that comments still work
#let src = ```
///Description
let func(
  pos, // some comment
)
```.text


#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (
        pos: (description: ""),
      ),
      return-types: none
    ),
  )
)

