#import "/src/new-parser.typ": *


/// Positional arguments

#let src = ```
///Description
let func(pos)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (pos: (description: ""),), 
      return-types: none
    ),
  )
)


/// Identifier not directly followed argument list 

#let src = ```
///Description
let func  (pos)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (pos: (description: ""),),
      return-types: none
    ),
  )
)


// Named arguments

#let src = ```
///Description
let func(named: 2)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (named: (description: "", default: "2"),),
      return-types: none
    ),
  )
)


// Complex default for named argument. 

#let src = ```
///Description
///...
let func(
  named: (
    a: 12, b: (1+1)
    )
) = {}
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description\n...",
      args: (
        named: (description: "", default: "(a: 12, b: (1+1))"),
      ),
      return-types: none
    ),
  )
)