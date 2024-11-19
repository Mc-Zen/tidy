#import "/src/new-parser.typ": *


#let src = ```
///Description
///...
let func(
  ///param pos
  /// -> int | none
  pos,
  /// -> any
  named: 2,)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description\n...",
      args: (
        (name: "pos", description: "param pos", types: ("int", "none")),
        (name: "named", description: "", default: "2", types: ("any",)),
      )
    ),
  )
)


#let src = ```
///Description
///...
let func(
  ///param pos -> int | array
  pos,
  ///param named -> any
  named: 2,)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description\n...",
      args: (
        (name: "pos", description: "param pos", types: ("int", "array")),
        (name: "named", description: "param named", default: "2", types: ("any",)),
      )
    ),
  )
)