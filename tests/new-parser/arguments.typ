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
  named: (a: 12, b: (1+1))
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


// Multiline default arguments, see https://github.com/Mc-Zen/tidy/issues/41

#let src = `````
/// -> float
#let func(
  code: ```py
i = 1
while i < 10:
  print(i)
  i += 1
  ```,
  dict: (
    a: 1,
    b: 2,
    c: 3,
  )
) = {
  return 0
}
`````.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "",
      args: (
        code: (
          description: "", 
          default: "```py\ni = 1\nwhile i < 10:\n  print(i)\n  i += 1\n  ```"
        ),
        dict: (
          description: "", 
          default: "(\n    a: 1,\n    b: 2,\n    c: 3,\n  )"
        ),
      ),
      return-types: ("float",)
    ),
  )
)