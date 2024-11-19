#import "/src/old-parser.typ": *


//// General test
#{
  let str = "#let func(p1, p2: 3pt, p3: (), p4: (entries: ()), p5, \"as:d\")"
  let (args, processed-chars) = parse-argument-list(str, 9)
  assert.eq(processed-chars, str.len() - 9)
  assert.eq(args.len(), 6)
  assert.eq(args.at(0), ("p1",))
  assert.eq(args.at(1), ("p2", "3pt"))
  assert.eq(args.at(2), ("p3", "()"))
  assert.eq(args.at(3), ("p4", "(entries: ())"))
  assert.eq(args.at(4), ("p5",))
  assert.eq(args.at(5), ("\"as:d\"",))  
}


// Comma after last argument
#{
  let str = "#let func(p1,)"
  let (args, processed-chars) = parse-argument-list(str, 9)
  assert.eq(processed-chars, str.len() - 9)
  assert.eq(args.len(), 1)
}


// line breaks in argument list
#{
  let str = "#let func(p1\n,p2\n,\n\n)\n"
  let (args, processed-chars) = parse-argument-list(str, 9)
  assert.eq(processed-chars, str.len() - 10)
  assert.eq(args.len(), 2)
}

// #parse-argument-list("#let func(p1, p2: 3pt, p3: (), p4: (entries: ()), p5)", 9)

