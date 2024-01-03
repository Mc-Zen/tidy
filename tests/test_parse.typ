#import "/src/tidy.typ": *
#import "/src/tidy-parse.typ": *
#import "/src/utilities.typ": *

#let eval-string(string) = eval-docstring(string, (scope: (:)))

// Test reference-matcher
#{
  let matches = " @@func".matches(reference-matcher)
  assert.eq(matches.len(), 1)
  assert.eq(matches.at(0).captures, ("func",))
  
  let matches = " @@func()".matches(reference-matcher)
  assert.eq(matches.len(), 1)
  assert.eq(matches.at(0).captures, ("func()",))
  
  let matches = " ()@@@@my-func12-bliblablub @@ @@a".matches(reference-matcher)
  assert.eq(matches.len(), 2)
  assert.eq(matches.at(0).captures, ("my-func12-bliblablub",))
  assert.eq(matches.at(1).captures, ("a",))
}


// Test argument-documentation-matcher
#{
  let matches = "   \t\n\t  /// - my-arg1 (string, content): desc".matches(argument-documentation-matcher)
  assert.eq(matches.len(), 1)
  assert.eq(matches.at(0).captures, ("my-arg1","string, content", "desc"))

  // multiline argument description
  let matches = "/// - arg (type): desc\n\tasd\n-3$234$".matches(argument-documentation-matcher)
  assert.eq(matches.len(), 1)
  assert.eq(matches.at(0).captures, ("arg", "type", "desc"))
}


// Basic tests
#{
let a = ```
/// Func
#let a-3_56C() = {}
```.text
let result = parse-module(a)
assert.eq(result.functions.len(), 1)
assert.eq(result.functions.at(0).name, "a-3_56C")
assert.eq(eval-string(result.functions.at(0).description), [Func])
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
  assert.eq(eval-string(result.functions.at(0).description), [Func])
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
  assert.eq(eval-string(f0.description), [Func])
  assert.eq(f0.args.len(), 4)
  assert.eq(f0.args.p1, (:))
  assert.eq(f0.args.p2, (default: "2"))
  assert.eq(f0.args.p3, (default: "()"))
  assert.eq(f0.args.p4, (default: "(\"entries\": ())"))
  assert.eq(f0.return-types, none)
}




// Parameter and return types
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
  assert.eq(eval-string(f0.description), [Func])
  assert.eq(f0.args.len(), 4)
  assert.eq(f0.args.p1.types, ("string",))
  assert.eq(eval-string(f0.args.p1.description), [a param $a$])
  assert.eq(f0.args.p2.default, "2")
  assert.eq(eval-string(f0.args.p2.description), [a param $b$ Oh yes])
  assert.eq(f0.args.p2.types, ("boolean", "function"))
  assert.eq(f0.return-types, ("content", "integer"))
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

