// Source code for the typst-doc package

// Color to highlight function names in
#let fn-color = rgb("#4b69c6")

// Colors for Typst types
#let type-colors = (
  "content": rgb("#a6ebe6"),
  "color": rgb("#a6ebe6"),
  "string": rgb("#d1ffe2"),
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "boolean": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "relative-length": rgb("#e7d9ff"),
  "fraction": rgb("#e7d9ff"),
  "symbol": rgb("#eff0f3"),
  "array": rgb("#eff0f3"),
  "dictionary": rgb("#eff0f3"),
  "arguments": rgb("#eff0f3"),
  "selector": rgb("#eff0f3"),
  "module": rgb("#eff0f3"),
  "stroke": rgb("#eff0f3"),
  "function": rgb("#f9dfff"),
)



// Parse a comma-separated argument list that may contain
// arbitrary code syntax until the first parenthesis is closed
// return none, if it is never closed
//
// We deal with
//  - any number of opening and closing parenthesis
//  - string literals
// We don't deal with:
//  - commented out code (// or /**/)
//  - raw strings that contain " or ( or )
// Returns list of strings for arguments that are separated by commata at
// scope level and the number of characters that have been "swallowed"
#let parse-argument-list(text, index) = {
  if text.at(index) != "(" { return ((:), 0) }
  index += 1
  let brace-level = 1
  let literal-mode = none
  let arg-strings = ()
  let current-arg = ""
  let previous-char = none
  let count = 0
  for c in text.slice(index) {
    let ignore-char = false
    if c == "\"" and previous-char != "\\" { 
      if literal-mode == none { literal-mode = "\"" }
      else if literal-mode == "\"" { literal-mode = none }
    }
    if literal-mode == none {
      if c == "(" { brace-level += 1 }
      else if c == ")" { brace-level -= 1 }
      else if c == "," and brace-level == 1 {
        arg-strings.push(current-arg)
        current-arg = ""
        ignore-char = true
      }
    }
    if brace-level == 0 {
      arg-strings.push(current-arg)
      break
    }
    if not ignore-char { current-arg += c }
    previous-char = c
    count += 1
  }
  if brace-level > 0 { return none }
  return (arg-strings, count)
}

/// Parse an argument list from source code at given position. 
/// This function returns `none`, if the argument list is not properly closed. 
/// Otherwise, a dictionary is returned with an entry for each parsed 
/// argument name. The values are dictionaries that may be empty or 
/// have an entry for `default` containing a string with the parsed
/// default value for this argument. 
/// 
/// 
/// 
/// *Example*
///
/// Let's take some source code:
/// ```typ
/// #let func(p1, p2: 3pt, p3: (), p4: (entries: ())) = {...}
/// ```
/// Here, we would call `parse-parameter-list(source-code, 9)` and retrieve
/// #pad(x: 1em, ```typc
/// (
///   p0: (:),
///   p1: (default: "3pt"),
///   p2: (default: "()"),
///   p4: (default: "(entries: ())"),
/// ) 
/// ```)
///
/// - module-content (string): Source code.
/// - index (integer): Index where the argument list starts. This index should point to the character *next* to the function name, i.e. to the opening brace `(` of the argument list if there is one (note, that function aliases for example produced by `myfunc.where(arg1: 3)` do not have an argument list).
/// -> none, dictionary
#let parse-parameter-list(text, index) = {
  let result = parse-argument-list(text, index)
  if result == none { return none }
  let (arg-strings, count) = result
  let args = (:)
  for arg in arg-strings {
    if arg.trim().len() == 0 { continue }
    let colon-pos = arg.position(":")
    if colon-pos == none {
      args.insert(arg.trim(), (:))
    } else {
      let name = arg.slice(0, colon-pos)
      let default-value = arg.slice(colon-pos + 1)
      args.insert(name.trim(), (default: default-value.trim()))
    }
  }
  return args
}


// Take an array of arg strings and retrieve a list of positional and named
// arguments, respectively. THe values are `eval()`ed. 
#let parse-arg-strings(args) = {
  let positional-args = ()
  let named-args = (:)
  for arg in args {
    if arg.trim().len() == 0 { continue }
    let colon-pos = arg.position(":")
    if colon-pos == none {
      positional-args.push(eval(arg.trim()))
    } else {
      let name = arg.slice(0, colon-pos)
      let value = arg.slice(colon-pos + 1)
      named-args.insert(name.trim(), eval(value.trim()))
    }
  }
  return (positional-args, named-args)
}

// some stuff #{image("settings.svg")} asd#image("settings.svg")

// Find all calls to `image()` in the given code string and return an array
// of objects containing info about
// - the start index of the image call (including the `#` if present)
// - the end index of the image call, pointing to the closing `)`
// - whether the call takes place in code mode (no `#`) or in content mode
// - positional and named args for the `image()` function call
#let find-image-commands(text) = {
  let matches = text.matches("image(")
  let image-commands = ()
  for match in matches {
    let (arg-strings, length) = parse-argument-list(text, match.start + 5)
    let (positional-args, named-args) = parse-arg-strings(arg-strings)
    
    let code-mode = not (match.start > 0 and text.at(match.start - 1) == "#")
    text.slice(match.start + 6, match.end + length)
    image-commands.push(
      (
        start: match.start - int(not code-mode), 
        end: match.end + length,
        positional-args: positional-args,
        named-args: named-args,
        code-mode: code-mode
      )
    )
  }
  return image-commands
}

// In given code string, replace every `image()` call with a placeholder string
// `%%img0%%` (the number is incremented subsequently). 
#let replace-image-commands(text, image-commands) = {
  let result-text = ""
  let position = 0
  for (index, image-command) in image-commands.enumerate() {
    result-text += text.slice(position, image-command.start)
    let placeholder = "%%img" + str(index) + "%%"
    if image-command.code-mode { placeholder = "[" + placeholder + "]"}
    result-text += placeholder
    position = image-command.end + 1
  }
  return result-text + text.slice(position)
}

// This function `eval()`s the given string and shows images that are to be 
// inserted with the `image()` function. 
//
// `eval()` does not allow access to the file system, so calls to #image()
// do not work. We work around that by identifying all these calls and
// replacing them with some placeholder. We use show rules to show these
// placeholders as the correct images. 
//  - Any number of images is supported
//  - image() amy be called in content or code mode
//  - arguments like `width` for images are respected
#let eval-with-images(text) = {
  if "image" not in text { return eval(text) }
  
  let image-commands = find-image-commands(text)
  let replaced-text = replace-image-commands(text, image-commands)
  
  show regex("%%img\\d+%%") : it => {
    let index = int(it.text.slice(5, -2))
    let filename = image-commands.at(index).positional-args.at(0)
    image(filename, ..image-commands.at(index).named-args)
  }
  eval(replaced-text)
}


#let get-type-color(type) = type-colors.at(type, default: rgb("#eff0f3"))

// Create beautiful, colored type box
#let type-box(type) = { 
  let color = get-type-color(type)
  h(2pt)
  box(outset: 2pt, fill: color, radius: 2pt, raw(type))
  h(2pt)
}

// Create a parameter description block, containing name, type, description and optionally the default value. 
#let param-description-block(name, types, content, show-default: false, default: none, breakable: false) = block(
  inset: 10pt, fill: luma(98%), width: 100%,
  breakable: breakable,
  [
    #text(weight: "bold", size: 1.1em, name) 
    #h(.5cm) 
    #types.map(x => type-box(x)).join([ #text("or",size:.6em) ])
  
    #eval-with-images("[" + content + "]")
    
    #if show-default [ Default: #raw(lang: "typc", default) ]
  ]
)

// #parse-parameter-list("(asd: \"\", 4)", 0)
// #parse-parameter-list("sadsdasd (p0, p1: 3, p2: (), p4: (entries: ())) = ) asd", 9)


// Matches Typst docstring for a function declaration. Example:
// 
// // This function does something
// //
// // param1 (string): This is param1
// // param2 (content, length): This is param2.
// //           Yes, it really is. 
// #let something(param1, param2) = {
//   
// }
// 
// The entire block may be indented by any amount, the declaration can either start with `#let` or `let`. The docstring must start with `///` on every line and the function declaration needs to start exactly at the next line. 
// #let docstring-matcher = regex(`((?:[^\S\r\n]*/{3} ?.*\n)+)[^\S\r\n]*#?let (\w[\w\d\-_]+)`.text)
#let docstring-matcher = regex(`([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)\n[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
// The regex explained: 
//
// First capture group: ([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)
// is for the docstring. It may start with any whitespace [^\S\r\n]* 
// and needs to have /// followed by anything. This is the first line of 
// the docstring and we treat it separately only in order to be able to 
// match the very first line in the file (which is otherwise tricky here). 
// We then match basically the same thing n times: \n[^\S\r\n]*///.*)*
//
// We then want a linebreak (should also have \r here?), arbitrary whitespace
// and the word let or #let: \n[^\S\r\n]*#?let 
//
// Second capture group: (\w[\w\d\-_]*)
// Matches the function name (any Typst identifier)


#let argument-type-matcher = regex(`[^\S\r\n]*/{3} - ([.\w\d\-_]+) \(([\w\d\-_ ,]+)\): ?(.*)`.text)

#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)


#let process-function-references(text, label-prefix: none) = {
  return text.replace(reference-matcher, info => {
    let target = info.captures.at(0).trim(")").trim("(")
    return "#link(label(\"" + label-prefix + target + "()\"))[`" + target + "()`]"
  })
}

/// Parse the docstrings of Typst code. This function returns a dictionary with the keys
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references.
/// 
/// The function documentation dictionaries contain the keys
/// - `name`: The function name.
/// - `description`: The functions docstring description.
/// - `args`: A dictionary of info objects for each fucntion argument.
///
/// These again are dictionaries with the keys
/// - `description` (optional): The description for the argument.
/// - `types` (optional): A list of accepted argument types. 
/// - `default` (optional): Default value for this argument.
/// 
/// See @@show-module() for outputting the results of this function.
///
/// - content (string): Typst code to parse for docs. 
/// - label-prefix (none, string): Prefix for internally created labels 
///   and references. Use this to avoid name conflicts with labels. 
#let parse-code(content, label-prefix: none) = {
  let matches = content.matches(docstring-matcher)
  let function-docs = ()

  for match in matches {
    let docstring = match.captures.at(0)
    let fn-name = match.captures.at(1)

    let args = parse-parameter-list(content, match.end)
    
    let fn-desc = ""
    let started-args = false
    let documented-args = ()
    let return-types = none
    for line in docstring.split("\n") {
      let match = line.match(argument-type-matcher)
      if match == none {
        let trimmed-line = line.trim().trim("/")
        if not started-args { fn-desc += trimmed-line + "\n"}
        else {
          if trimmed-line.trim().starts-with("->") {
            return-types = trimmed-line.trim().slice(2).split(",").map(x => x.trim())
          } else {
            documented-args.last().desc += "\n" + trimmed-line 
          }
        }
      } else {
        started-args = true
        let param-name = match.captures.at(0)
        let param-types = match.captures.at(1).split(",").map(x => x.trim())
        let param-desc = match.captures.at(2)
        documented-args.push((name: param-name, types: param-types, desc: param-desc))
      }
    }
    fn-desc = process-function-references(fn-desc, label-prefix: label-prefix)
    for arg in documented-args {
      if arg.name in args {
        args.at(arg.name).description = process-function-references(arg.desc, label-prefix: label-prefix)
        args.at(arg.name).types = arg.types
      } else {
        assert(false, message: "The parameter \"" + arg.name + "\" does not appear in the argument list of the function \"" + fn-name + "\"")
      }
    }
    function-docs.push((name: fn-name, description: fn-desc, args: args, return-types: return-types))
  }
  let result = (functions: function-docs, label-prefix: label-prefix)
  return result
}

/// Parse the docstrings of a typst module. This function returns a dictionary with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module. /// 
/// See @@parse-code() for more details. 
///
/// - filename (string): Filename for the `.typ` file to analyze for docstrings.
/// - name (string, none): The name for the module. If not given, the module name will be derived form the filename. 
#let parse-module(filename, name: none, label-prefix: none) = {
  let mname = filename.replace(".typ", "")
  let prefix = if label-prefix != none { label-prefix } else { mname }
  let result = parse-code(read(filename), label-prefix: prefix)
  if name != none {
    result.insert("name", name)
  } else {
    result.insert("name", mname)
  }
  return result
}


#let show-outline(module-doc) = {
  let prefix = module-doc.label-prefix
  let items = ()
  for fn in module-doc.functions {
    items.push(link(label(prefix + fn.name + "()"), fn.name + "()"))
  }
  list(..items)
}

#let show-function(fn, label-prefix: "", first-heading-level: 2, allow-breaking: false, omit-empty-param-descriptions: true) = {
  [
    #heading(fn.name, level: first-heading-level + 1)
    #label(label-prefix + fn.name + "()")
  ]
  parbreak()
  eval("[" + fn.description + "]")

  block(breakable: allow-breaking,
    {
      heading("Parameters", level: first-heading-level + 2)
    
      pad(x:10pt, {
      set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
      text(fn.name, fill: fn-color)
      "("
      let inline-args = fn.args.len() < 2
      if not inline-args { "\n  " }
      let items = ()
      for (arg, info) in fn.args {
        let types 
        if "types" in info {
          types = ": " + info.types.map(x => type-box(x)).join(" ")
        }
        items.push(arg + types)
      }
      items.join( if inline-args {", "} else { ",\n  "})
      if not inline-args { "\n" } + ")"
      if fn.return-types != none {
        " -> " 
        fn.return-types.map(x => type-box(x)).join(" ")
      }
    })
  })

  let blocks = ()
  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description.trim() == "" and omit-empty-param-descriptions { continue }
    param-description-block(
      name, 
      types, description, 
      show-default: "default" in info, 
      default: info.at("default", default: none),
      breakable: allow-breaking
    )
  }
  v(1cm)
  // if index < module-doc.functions.len()  { v(1cm) }
}

/// Show given module in the style of the Typst online documentation. 
/// This displays all (documented) functions in the module sorted alphabetically. 
///
/// - module-doc (dictionary): Module documentation information as returned by 
///           @@parse-module. 
/// - first-heading-level (integer): Level for the module heading. Function names are 
///           created as second-level headings and the "Parameters" heading is two levels 
///           below the first heading level. 
/// - show-module-name (boolean): Whether to output the name of the module.  
/// - type-colors (dictionary): Colors to use for each type. 
///           Colors for missing types default to gray (`"#eff0f3"`).
/// - allow-breaking (boolean): Whether to allow breaking of parameter description blocks.
/// - omit-empty-param-descriptions (boolean): Whether to omit description blocks for
///           Parameters with empty description. 
/// -> content
#let show-module(
  module-doc, 
  first-heading-level: 2,
  show-module-name: true,
  type-colors: type-colors,
  allow-breaking: false,
  omit-empty-param-descriptions: true,
) = {
  let label-prefix = module-doc.label-prefix
  if "name" in module-doc and show-module-name {
    let module-name = module-doc.name
    heading(module-name, level: first-heading-level)
  }
  
  for (index, fn) in module-doc.functions.enumerate() {
    show-function(
      fn, 
      label-prefix: label-prefix, 
      first-heading-level: first-heading-level, 
      allow-breaking: allow-breaking, 
      omit-empty-param-descriptions: omit-empty-param-descriptions
    )
  }
}


