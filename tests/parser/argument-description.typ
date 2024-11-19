#import "/src/new-parser.typ": *


// Argument descriptions

#let src = ```
///Description
let func(
  pos, // some comment
  named: 2 // another comment
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
        named: (description: "", default: "2"),
      ),
      return-types: none
    ),
  )
)

// Just positional description

#let src = ```
///Description
let func(
  ///param pos
  pos,
  named: 2
)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (
        pos: (description: "param pos"),
        named: (description: "", default: "2"),
      ),
      return-types: none
    ),
  )
)

// Just named description


#let src = ```
///Description
let func(
  pos,
  ///param named
  named: 2
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
        named: (description: "param named", default: "2"),
      ),
      return-types: none
    ),
  )
)



// Multiline argument descriptions

#let src = ```
///Description
///...
let func(
  ///param pos
  ///...
  pos,
  ///param named
  ///...
  named: 2,)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description\n...",
      args: (
        pos: (description: "param pos\n..."),
        named: (description: "param named\n...", default: "2"),
      ),
      return-types: none
    ),
  )
)


// Argument descriptions with blank lines

#let src = ```
///Description
let func(

  ///param pos
  ///...
  pos,


  ///param named
  ///...
  named: 2
)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: (
        pos: (description: "param pos\n..."),
        named: (description: "param named\n...", default: "2"),
      ),
      return-types: none
    ),
  )
)
