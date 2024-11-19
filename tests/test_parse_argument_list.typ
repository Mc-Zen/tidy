#import "/src/old-parser.typ": *


//// General test
#{
  let str = "#let func(p1, p2: 3pt, p3: (), p4: (entries: ()), p5, \"as:d\")"
  let (pos, named, sink, count) = parse-argument-list(str, 9)
  assert.eq(count, str.len() - 9)
  assert.eq(pos.len(), 3)
  assert.eq(named.len(), 3)
  assert.eq(pos.at(0), "p1")
  assert.eq(pos.at(1), "p5")
  assert.eq(pos.at(2), "\"as:d\"")
  assert.eq(named.p2, "3pt")
  assert.eq(named.p3, "()")
  assert.eq(named.p4, "(entries: ())")
  assert.eq(named.p2, "3pt")
}


// Comma after last argument
#{
  let str = "#let func(p1,)"
  let (pos, named, sink, count) = parse-argument-list(str, 9)
  assert.eq(count, str.len() - 9)
  assert.eq(pos.len(), 1)
}


// line breaks in argument list
#{
  let str = "#let func(p1\n,p2\n,\n\n)\n"
  let (pos, named, sink, count) = parse-argument-list(str, 9)
  assert.eq(count, str.len() - 10)
  assert.eq(pos.len(), 2)
}

// #parse-argument-list("#let func(p1, p2: 3pt, p3: (), p4: (entries: ()), p5)", 9)

