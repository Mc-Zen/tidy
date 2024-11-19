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
      args: ((name: "pos", description: ""),)
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
      args: ((name: "pos", description: ""),)
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
      args: ((name: "named", description: "", default: "2"),)
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
        (name: "named", description: "", default: "(a: 12, b: (1+1))"),
      )
    ),
  )
)