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
        pos: (description: "param pos", types: ("int", "none")),
        named: (description: "", default: "2", types: ("any",)),
      ),
      return-types: none
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
        pos: (description: "param pos", types: ("int", "array")),
        named: (description: "param named", default: "2", types: ("any",)),
      ),
      return-types: none
    ),
  )
)