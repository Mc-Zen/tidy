#import "/src/tidy.typ": *



#{
  let code = ```

  /// >>> 2 == 2
  /// >>> ("e", 2) == ("e", 2)
  /// >>> eq(1+1, 2)
  /// >>> ne(2+1, 2)
  /// >>> approx(calc.sin(calc.pi), 0)
  /// 
  /// >>> 2 == 2
  /// >>> eq(2, 2)
  /// >>> eq((a: 13, b: 21) + (a: 3), (a: 3, b:21))
  #let f()
  ```
  
  let result = show-module(parse-module(code.text))
}


// disable tests
#{
  let code = ```
  /// >>> 2 == 3
  #let f()
  ```
  let result = show-module(parse-module(code.text), enable-tests: false)
}
