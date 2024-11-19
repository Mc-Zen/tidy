#import "/src/new-parser.typ": *



// Multiple functions

#let src = ```
///Description
let func(named: 2)
///Description
let func1(named: 2)
```.text

#assert.eq(
  parse(src).functions,
  (
    (
      name: "func",
      description: "Description",
      args: ((name: "named", description: "", default: "2"),)
    ),
    (
      name: "func1",
      description: "Description",
      args: ((name: "named", description: "", default: "2"),)
    ),
  )
)


/// Description is not connected to definition

#let src = ```
///Description
///...

let func(
  ...
) = {}
```.text

#assert.eq(
  parse(src).functions,
  (
    
  )
)


// Undocumented second function

#let src = ```
///Description
let a()
let func(
  ...
) = {}
```.text

#assert.eq(
  parse(src).functions,
  (
    (name: "a", description: "Description", args: ()),
  )
)




#let src = ```
/// Doc
#let aey(x)
/// No Doc
            
#let bey(x)
```.text

#assert.eq(
  parse(src).functions,
  (
    (name: "aey", description: "Doc", args: ((name: "x", description: ""),)),
    // (name: "bey", description: "No Doc", args: ((name: "x", description: ""),)),
  )
)
