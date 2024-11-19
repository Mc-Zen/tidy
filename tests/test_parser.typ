#import "/src/new-parser.typ": *
#{
  let src = ```
  ///Description
  let var = 23
  ```.text

  assert.eq(
    parse(src).variables,
    (
      (
        name: "var",
        description: "Description"
      ),
    )
  )

  let src = ```
  ///Description
  let func() = { 34 }
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description",
        args: ()
      ),
    )
  )

  let src = ```
  ///Description
  let func(pos)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description",
        args: ((name: "pos", description: ""),)
      ),
    )
  )

  let src = ```
  ///Description
  let func  (pos)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description",
        args: ((name: "pos", description: ""),)
      ),
    )
  )

  let src = ```
  ///Description
  let func(named: 2)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description",
        args: ((name: "named", description: "", default: "2"),)
      ),
    )
  )


  let src = ```
  ///Description
  let func(named: 2)
  ///Description
  let func1(named: 2)
  ```.text

  assert.eq(
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

  let src = ```
  ///Description
  let func(
    pos, // some comment
    named: 2 // another comment
  )
  ```.text

  assert.eq(
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

  let src = ```
  ///Description
  let func(
    ///param pos
    pos,
    named: 2
  )
  ```.text

  assert.eq(
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

  let src = ```
  ///Description
  let func(
    pos,
    ///param named
    named: 2
  )
  ```.text

  assert.eq(
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

  let src = ```
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

  assert.eq(
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

  let src = ```
  ///Description
  ///...
  let func(
    named: (
      a: 12, b: (1+1)
     )
  ) = {}
  ```.text

  assert.eq(
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

  
  let src = ```
  ///Description
  ///...
  let func(
    ///param pos
    /// -> int |  none
    pos,
    /// -> any
    named: 2,)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description\n...",
        args: (
          (name: "pos", description: "param pos", types: ("int", "none")),
          (name: "named", description: "", default: "2", types: ("any",)),
        )
      ),
    )
  )

  
  let src = ```
  ///Description
  ///...
  let func(
    ///param pos -> int | array
    pos,
    ///param named -> any
    named: 2,)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (
        name: "func",
        description: "Description\n...",
        args: (
          (name: "pos", description: "param pos", types: ("int", "array")),
          (name: "named", description: "param named", default: "2", types: ("any",)),
        )
      ),
    )
  )
  
  let src = ```
  ///Description
  ///...
  
  let func(
    ...
  ) = {}
  ```.text

  assert.eq(
    parse(src).functions,
    (
      
    )
  )

  let src = ```
  ///Description
  let a()
  let func(
    ...
  ) = {}
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (name: "a", description: "Description", args: ()),
    )
  )




  
  let src = ```
  ///Module description
  
  let a()
  let func(
    ...
  ) = {}
  ```.text

  assert.eq(
    parse(src).description,
    "Module description"
  )

  
  let src = ```
  // License info

  // more stuff
  
  ///Module description
  ///...
  ```.text

  assert.eq(
    parse(src).description,
    "Module description\n..."
  )

  assert.eq(parse(src).functions, ())



  let src = ```
  /// Doc
  #let aey(x)
  /// No Doc
             
  #let bey(x)
  ```.text

  assert.eq(
    parse(src).functions,
    (
      (name: "aey", description: "Doc", args: ((name: "x", description: ""),)),
      // (name: "bey", description: "No Doc", args: ((name: "x", description: ""),)),
    )
  )




  


}

a