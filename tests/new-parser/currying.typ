
#import "/src/parse-module.typ": *

#let src = ```
/// Doc
#let aey = text.with(1pt, weight: 200)
```.text

#assert.eq(
  parse-module(src).functions.at(0),
  (
    name: "aey", 
    description: "Doc", 
    args: (:),
    parent: (
      name: "text",
      pos: ("1pt",),
      named: (weight: "200")
    ),
    return-types: none
  ),
)


#let src = ```
/// Doc
#let aey = text.with(
  1pt, weight: 200
)
```.text

#assert.eq(
  parse-module(src).functions.at(0),
  (
    name: "aey", 
    description: "Doc", 
    args: (:),
    parent: (
      name: "text",
      pos: ("1pt",),
      named: (weight: "200")
    ),
    return-types: none
  ),
)


// Parent resolving

#let src = ```
/// -> any
let my-text(
  /// The weight
  /// -> int
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
    description: "Doc", 
    args: (
      body: (description: ""),
      weight: (description: "The weight", types: ("int",), default: "200")
    ),
    parent: (
      name: "my-text",
      pos: (),
      named: (weight: "200")
    ),
    return-types: ("any",)
  ),
)


