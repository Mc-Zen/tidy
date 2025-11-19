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




// No argument type
#let src = ```
/// 
#let edge(
  /// This is no problem -> int
  /// yes
  data,
) = {..}
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "edge",
      description: "",
      args: (
        data: (description: "This is no problem -> int\n yes"),
      ),
      return-types: none
    ),
  )
)



// Trailing argument type
#let src = ````
/// 
#let edge(
  /// This is the problem -> int
  data,
) = {..}
````.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "edge",
      description: "",
      args: (
        data: (description: "This is the problem", types: ("int",)),
      ),
      return-types: none
    ),
  )
)



// Multiline argument type
#let src = ```
/// 
#let edge(
  /// -> int | bool | string |
  ///    array
  data,
) = {..}
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "edge",
      description: "",
      args: (
        data: (description: "", types: ("int", "bool", "string", "array")),
      ),
      return-types: none
    ),
  )
)


