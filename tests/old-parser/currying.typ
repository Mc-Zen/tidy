
#import "/src/parse-module.typ": *

#let parse-module = parse-module.with(old-syntax: true)
#let src = ```
/// Doc
#let aey = text.with(1pt, weight: 200)
```.text

#assert.eq(
  parse-module(src).functions,
  (
    (
      name: "aey", 
      description: " Doc\n\n", 
      args: (:),
      parent: (
        name: "text",
        pos: ("1pt",),
        named: (weight: "200")
      ),
    ),
  )
)


// Parent resolving

#let src = ```
/// - weight (int): The weight
/// -> any
let my-text(
  weight: 400, 
  body
)

/// Doc
#let aey = my-text.with(weight: 200)
```.text

#assert.eq(
  parse-module(src).functions.at(1),
  (
    name: "aey", 
    description: " Doc\n\n", 
    parent: (
      name: "my-text",
      pos: (),
      named: (weight: "200")
    ),
    args: (
      body: (:),
      weight: (description: "The weight", types: ("int",), default: "200")
    ),
    return-types: ("any",)
  ),
)

