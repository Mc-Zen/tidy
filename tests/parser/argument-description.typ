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
        (name: "pos", description: ""),
        (name: "named", description: "", default: "2"),
      )
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
        (name: "pos", description: "param pos"),
        (name: "named", description: "", default: "2"),
      )
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
        (name: "pos", description: ""),
        (name: "named", description: "param named", default: "2"),
      )
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
        (name: "pos", description: "param pos\n..."),
        (name: "named", description: "param named\n...", default: "2"),
      )
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
        (name: "pos", description: "param pos\n..."),
        (name: "named", description: "param named\n...", default: "2"),
      )
    ),
  )
)
