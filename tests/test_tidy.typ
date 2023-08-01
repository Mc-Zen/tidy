#import "/src/tidy.typ": *
#import "/src/tidy-parse.typ": *

// Color to highlight function names in
#let fn-color = rgb("#4b69c6")



// Basic tests
#{
let a = ```
/// Func
#let a-3_56C() = {}
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).name, "a-3_56C")
assert.eq(result.functions.at(0).description, [Func])
assert.eq(result.functions.at(0).return-types, none)
}


#{
let a = ```
#{
  /// Func
  /// 
  let a() = {}
}
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).name, "a")
assert.eq(result.functions.at(0).description, [Func])
assert.eq(result.functions.at(0).return-types, none)
}



// Parameters and defaults
#{
let a = ```
/// Func
#let a(p1, p2: 2, p3: (), p4: ("entries": ())) = {}
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
let f0 = result.functions.at(0)

assert.eq(f0.name, "a")
assert.eq(f0.description, [Func])
assert.eq(f0.args.len(), 4)
assert.eq(f0.args.p1, (:))
assert.eq(f0.args.p2, (default: "2"))
assert.eq(f0.args.p3, (default: "()"))
assert.eq(f0.args.p4, (default: "(\"entries\": ())"))
assert.eq(f0.return-types, none)
}




// Parameter and return Types
#{
let a = ```
/// Func
/// - p1 (string): a param $a$
/// - p2 (boolean, function): a param $b$
///        Oh yes
/// - p3 (string): 
/// -> content, integer
#let a(p1, p2: 2, p3: (), p4: ("entries": ())) = {}
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
let f0 = result.functions.at(0)

assert.eq(f0.name, "a")
assert.eq(f0.description, [Func])
assert.eq(f0.args.len(), 4)
assert.eq(f0.args.p1, (description: [a param $a$], types: ("string",)))
assert.eq(f0.args.p2.default, "2")
assert.eq(f0.args.p2.description, [a param $b$ Oh yes])
assert.eq(f0.args.p2.types, ("boolean", "function"))
assert.eq(f0.return-types, ("content", "integer"))
}




// Docstrings for functions without arguments
#{
let a = ```
/// Func
#let a = myfunc.where(e: 1)
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
}






// // Ignore args that are not in the argument list
// #{
// let a = ```
// /// Func
// /// - bar (content): asd
// #let a(bar) = {}
// ```.text
// let result = parse-module(a)
// assert.eq(result.functions.len(), 1)
// assert.eq(result.functions.at(0).args.len(), 1)
// }


// Ignore interrupted docstring
#{
let a = ```
/// Func
// a
#let a()
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 0)
}




//// Parse args

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

// #parse-argument-list("#let func(p1, p2: 3pt, p3: (), p4: (entries: ()), p5)", 9)

