
#import "/src/new-parser.typ": *
  

#let src = ```
///Module description

let a()
let func(
  ...
) = {}
```.text

#assert.eq(
  parse(src).description,
  "Module description"
)


#let src = ```
// License info

// more stuff

///Module description
///...
```.text

#assert.eq(
  parse(src).description,
  "Module description\n..."
)

#assert.eq(parse(src).functions, ())

