#import "../typst-doc.typ": *


// Basic tests
#{
let a = ```
/// Func
#let a-3_56C() = {}
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).name, "a-3_56C")
assert.eq(result.functions.at(0).description, " Func\n")
assert.eq(result.functions.at(0).return-types, "")
}


#{
let a = ```
#{
  /// Func
  let a() = {}
}
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).name, "a")
assert.eq(result.functions.at(0).description, " Func\n")
assert.eq(result.functions.at(0).return-types, none)
}



// Parameters and defaults
#{
let a = ```
/// Func
#let a(p1, p2: 2, p3: (), p4: ("entries": ())) = {}
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
let f0 = result.functions.at(0)

assert.eq(f0.name, "a")
assert.eq(f0.description, " Func\n")
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
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
let f0 = result.functions.at(0)

assert.eq(f0.name, "a")
assert.eq(f0.description, " Func\n")
assert.eq(f0.args.len(), 4)
assert.eq(f0.args.p1, (description: "a param $a$", types: ("string",)))
assert.eq(f0.args.p2.default, "2")
assert.eq(f0.args.p2.description, "a param $b$\n        Oh yes")
assert.eq(f0.args.p2.types, ("boolean", "function"))
assert.eq(f0.return-types, ("content", "integer"))
}




// Docstrings for functions without arguments
#{
let a = ```
/// Func
#let a = myfunc.where(e: 1)
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
}






// Ignore args that are not in the argument list
#{
let a = ```
/// Func
/// - foo (content): asd
/// - bar (content): asd
#let a(bar) = {}
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).args.len(), 1)
}


// Ignore interrupted docstring
#{
let a = ```
/// Func
// a
#let a()
```.text
let result = parse-code(a)
assert.eq(result.functions.len(), 0)
}
