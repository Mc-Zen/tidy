
#let split-once(string, delimiter) ={
  let pos = string.position(delimiter)
  if pos == none { return string }
  (string.slice(0, pos), string.slice(pos + 1))
}

#let parse-argument-list(text) = {
  let brace-level = 1
  let literal-mode = none // Whether in ".."
  
  let args = ()
  
  let arg = ""
  let is-named = false // Whether current argument is a named arg
  
  let previous-char = none // lookbehind of 1
  let count-processed-chars = 1

  let maybe-split-argument(arg, is-named) = {
      if is-named {
        return split-once(arg, ":").map(str.trim)
      } else {
        return (arg.trim(),)
      }
  }
  
  for c in text {
    let ignore-char = false
    if c == "\"" and previous-char != "\\" { 
      if literal-mode == none { literal-mode = "\"" }
      else if literal-mode == "\"" { literal-mode = none }
    }
    if literal-mode == none {
      if c == "(" { brace-level += 1 }
      else if c == ")" { brace-level -= 1 }
      else if c == "," and brace-level == 1 {
        if is-named {
          let (name, value) = split-once(arg, ":").map(str.trim)
          args.push((name, value))
        } else {
          arg = arg.trim()
          args.push((arg,))
        }
        arg = ""
        ignore-char = true
        is-named = false
      } else if c == ":" and brace-level == 1 {
        is-named = true
      }
    }
    count-processed-chars += 1
    if brace-level == 0 {
      if arg.trim().len() > 0 {
        if is-named {
          let (name, value) = split-once(arg, ":").map(str.trim)
          args.push((name, value))
        } else {
          arg = arg.trim()
          args.push((arg,))
        }
        // arg = ""
      }
      break
    }
    if not ignore-char { arg += c }
    previous-char = c
  }
  // arg = arg.trim()
  // if arg != "" { args.push(arg) }
  return (
    args: args,
    brace-level: brace-level - 1
  )
}

#assert.eq(
  parse-argument-list("text)"), 
  (args: (("text",),), brace-level: -1)
)
#assert.eq(
  parse-argument-list("pos,"), 
  (args: (("pos",),), brace-level: 0)
)
#assert.eq(
  parse-argument-list("12, 13, a)"), 
  (args: (("12",), ("13",), ("a",)), brace-level: -1)
)
#assert.eq(
  parse-argument-list("a: 2, b: 3)"), 
  (args: (("a", "2"), ("b", "3")), brace-level: -1)
)


#let eval-doc-comment-test((line-number, line), label-prefix: "") = {
    if line.starts-with(" >>> ") {
      return " #test(`" + line.slice(8) + "`, source-location: (module: \"" + parse-info.label-prefix + "\", line: " + str(line-number) + "))"
    }
    line
}


#let parse-description-and-types(lines, label-prefix: "", first-line-number: 0) = {

  let description = lines
    .enumerate(start: first-line-number)
    .map(eval-doc-comment-test.with(label-prefix: label-prefix))
    .join("\n")
    
  if description == none { description = "" }
    
  let types = none
  if description.contains("->") {
    let parts = description.split("->")
    types = parts.last().replace(",", "|").split("|").map(str.trim)
    description = parts.slice(0, -1).join("->")
  }
  
  return (
    description: description.trim(), 
    types: types
  )
}

#assert.eq(
  parse-description-and-types(("asd",)),
  (description: "asd", types: none)
)
#assert.eq(
  parse-description-and-types(("->int",)),
  (description: "", types: ("int",))
)
#assert.eq(
  parse-description-and-types((" -> int",)),
  (description: "", types: ("int",))
)
#assert.eq(
  parse-description-and-types(("abcdefg -> int",)),
  (description: "abcdefg", types: ("int",))
)
#assert.eq(
  parse-description-and-types(("abcdefg", "-> int",)),
  (description: "abcdefg", types: ("int",))
)



#let trim-trailing-comments(line) = {
  let pos = line.position("//")
  if pos == none { return line }
  return line.slice(0, pos).trim()
}

#assert.eq(trim-trailing-comments("1+2+3+4 // 23"), "1+2+3+4")
#assert.eq(trim-trailing-comments("1+2+3+4 // 23 // 3"), "1+2+3+4")




#let definition-name-regex = regex(`#?let (\w[\w\d\-_]*)\s*(\(?)`.text)



#let process-parameters(parameters) = {
  let processed-params = ()
  
  for param in parameters {
    
    let (args: param-parts,) = parse-argument-list(param.arg)
    for param-parts in param-parts {
      let (description, types) = parse-description-and-types(param.desc-lines, label-prefix: "")
      let param-info = (
        name: param-parts.first(),
        description: description,
      )
      if param-parts.len() == 2 {
        param-info.default = param-parts.last()
      } 
      if types != none {
        param-info.types = types
      }
      processed-params.push(param-info)
    }
  }
  processed-params
}

#let process-parameters(parameters) = {
  let processed-params = ()
  
  for param in parameters {
    let param-parts = param.name
    let (description, types) = parse-description-and-types(param.desc-lines, label-prefix: "")
    let param-info = (
      name: param-parts.first(),
      description: description,
    )
    if param-parts.len() == 2 {
      param-info.default = param-parts.last()
    } 
    if types != none {
      param-info.types = types
    }
    processed-params.push(param-info)
  }
  processed-params
}


// #assert.eq(
//   process-parameters(((arg: "myarg)", desc-lines: ()),)), ()
// )

#let process-definition(definition) = {
  if definition.args == none {
    definition.remove("args")
  } else {
    definition.args = process-parameters(definition.args)
  }
  let (description, types) = parse-description-and-types(definition.description, label-prefix: "")
  if types != none {
    definition.types = types
  }
  definition.description = description
  definition
}




#let parse(src) = {
  let lines = (src.split("\n") + ("",)).map(str.trim)

  let module-description = none
  let definitions = ()
  

  let empty-arg = (arg: "", desc-lines: ())

  // Parser state
  let name = none
  let is-collecting-args = false
  let found-code = false // are we still looking for a potential module description?
  let args = ()
  let desc-lines = ()

  
  for line in lines {
    if line.starts-with("///") { // is a doc-comment line
      
      line = line.slice(3)
      if is-collecting-args { args.last().desc-lines.push(line) } 
      else                  { desc-lines.push(line) }
      
      continue
      
    } else if desc-lines != () { 
      // look for something to attach the doc-comment to 
      // (a parameter or a definition)
      
      if is-collecting-args {
        args.last().arg += trim-trailing-comments(line) 
        let (brace-level,) = parse-argument-list(args.last().arg)
        
        if brace-level == -1 {
          is-collecting-args = false
          args.push(empty-arg)
        }
        if args.last().arg.ends-with(",") {
          args.push(empty-arg)
        }
        continue
        
      }
      
      line = line.trim("#")
      if line.starts-with("let ") and name == none {
        
        found-code = true
        let match = line.match(definition-name-regex)
        if match != none {
          name = match.captures.first()
          if match.captures.at(1) != "" { // it's a function
            args = (empty-arg, )
            args.last().arg = line.slice(match.end)
            let (brace-level,) = parse-argument-list(args.last().arg)
            if brace-level != -1 { // parentheses are already closed on this line
              is-collecting-args = true
            }
          } else { // it's a variable
            args = none
          }
          continue
        }
        
      } else { // neither /// nor (#)let
        if not found-code {
          found-code = true
          module-description = desc-lines.join("\n")
          desc-lines = ()
        }
      }
    }
    if name != none {
      definitions.push(
        (name: name, description: desc-lines, args: args)
      )
    }
    desc-lines = ()
    name = none
  }
  
  if name != none {
    definitions.push(
      (name: name, description: desc-lines, args: args)
    )
  }

  definitions = definitions.map(process-definition)
  (
    description: module-description,
    functions: definitions.filter(x => "args" in x),
    variables: definitions.filter(x => "args" not in x),
  )
}
