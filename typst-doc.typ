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

#let get-type-color(type) = type-colors.at(type, default: rgb("#eff0f3"))

// Create beautiful, colored type box
#let colored-type-box(type) = { 
  h(2pt)
  box(outset: 2pt, fill: get-type-color(type), radius: 2pt, raw(type))
  h(2pt)
}


/// Parse a Typst argument list either at
///  - call site, e.g., "f("Timbuktu", value: 23)" or at
///  - declaration, e.g. "let f(place, value: 0)".
///
/// This function returns a tuple `(args, count-processed-chars)` where
/// `count-processed-chars` is the number of processed characters, i.e. the
/// length of the argument list and `args` is a list with an entry for each 
/// argument. 
/// 
/// The entries are lists with either one item if the argument is positional
/// or two items if the argument is named. In this case, the first item holds
/// the name, the second the value. Names as well as values are returned as 
/// strings. 
/// 
/// This function returns `none`, if the argument list is not properly closed. 
/// Note, that valid Typst code is expected. 
///
// Example: 
// Calling this function with the following text 
//   `"#let func(p1, p2: 3pt, p3: (), p4: (entries: ())) = {...}"`
// and index 9 (which points to the opening parenthesis) yields the result 
// ```
//   (
//     (
//       ("p1",),
//       ("p2", "3pt"),
//       ("p3", "()"),
//       ("p4", "(entries: ())"),
//       ("p5",),
//     ),
//     44,
//   )
// ```
// 
// This function can deal with
//  - any number of opening and closing parenthesis
//  - string literals
// We don't deal with:
//  - commented out code (// or /**/)
//  - raw strings that contain " or ( or )
#let parse-argument-list(text, index) = {
  if text.at(index) != "(" { return ((:), 0) }
  index += 1
  let brace-level = 1
  let literal-mode = none // Whether in ".."
  let arg-strings = ()
  let current-arg = ""
  let is-named = false // Whether current argument is a named arg
  
  let previous-char = none
  let count-processed-chars = 1

  let maybe-split-argument(arg, is-named) = {
      if is-named {
        let colon-pos = arg.position(":")
        return (arg.slice(0, colon-pos).trim(), arg.slice(colon-pos + 1).trim())
      } else {
        return (arg.trim(),)
      }
  }
  
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
        arg-strings.push(maybe-split-argument(current-arg, is-named))
        current-arg = ""
        ignore-char = true
        is-named = false
      } else if c == ":" and brace-level == 1 {
        is-named = true
      }
    }
    count-processed-chars += 1
    if brace-level == 0 {
      arg-strings.push(maybe-split-argument(current-arg, is-named))
      break
    }
    if not ignore-char { current-arg += c }
    previous-char = c
  }
  if brace-level > 0 { return none }
  return (arg-strings, count-processed-chars)
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
/// - text (string): Source code.
/// - index (integer): Index where the argument list starts. This index should point to the character *next* to the function name, i.e. to the opening brace `(` of the argument list if there is one (note, that function aliases for example produced by `myfunc.where(arg1: 3)` do not have an argument list).
/// -> none, dictionary
#let parse-parameter-list(text, index) = {
  let result = parse-argument-list(text, index)
  if result == none { return none }
  let (arg-strings, count) = result
  let args = (:)
  for arg in arg-strings {
    if arg.len() == 1 {
      args.insert(arg.at(0), (:))
    } else {
      args.insert(arg.at(0), (default: arg.at(1)))
    }
  }
  return args
}


// Take the result of `parse-argument-list()` and retrieve a list of positional and named
// arguments, respectively. The values are `eval()`ed. 
#let parse-arg-strings(args) = {
  let positional-args = ()
  let named-args = (:)
  for arg in args {
    if arg.len() == 1 {
      positional-args.push(eval(arg.at(0)))
    } else {
      named-args.insert(arg.at(0), eval(arg.at(1)))
    }
  }
  return (positional-args, named-args)
}


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
    image-commands.push(
      (
        start: match.start - int(not code-mode), 
        end: match.end + length - 2,
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



// Create a parameter description block, containing name, type, description and optionally the default value. 
#let param-description-block(
  name, types, content, 
  show-default: false, 
  default: none, 
  breakable: false,
  display-type-function: colored-type-box 
) = block(
  inset: 10pt, fill: luma(98%), width: 100%,
  breakable: breakable,
  [
    #text(weight: "bold", size: 1.1em, name) 
    #h(.5cm) 
    #types.map(x => display-type-function(x)).join([ #text("or",size:.6em) ])
  
    #eval-with-images("[" + content + "]")
    
    #if show-default [ Default: #raw(lang: "typc", default) ]
  ]
)


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
// #let docstring-matcher = regex(`([^\S\r\n]*///.*(?:\n[^\S\r\n]*///.*)*)\n[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
#let docstring-matcher = regex(`(?m)^((?:[^\S\r\n]*///.*\n)+)[^\S\r\n]*#?let (\w[\w\d\-_]*)`.text)
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


// Matches an argument documentation of the form `/// - myparameter (string)`. 
#let argument-documentation-matcher = regex(`[^\S\r\n]*/{3} - ([.\w\d\-_]+) \(([\w\d\-_ ,]+)\): ?(.*)`.text)

// Matches docstring references of the form `@@otherfunc` or `@@otherfunc()`. 
#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)


// Take some text (i.e. a function or parameter description) and process
// docstring references (starting with `@@`). 
#let process-function-references(text, parse-info) = {
  return text.replace(reference-matcher, info => {
    let target = info.captures.at(0).trim(")").trim("(")
    return "#link(label(\"" + parse-info.label-prefix + target + "()\"))[`" + target + "()`]"
  })
}

// Parse a function docstring that has been located in the source code
// with given match. The first capture group should hold the entire, raw
// docstring and the second capture the function name. 
#let parse-function-docstring(content, match, parse-info) = {
  let docstring = match.captures.at(0)
  let fn-name = match.captures.at(1)
  
  let fn-desc = ""
  let started-args = false
  let documented-args = ()
  let return-types = none
  for line in docstring.split("\n") {
    let arg-match = line.match(argument-documentation-matcher)
    if arg-match == none {
      let trimmed-line = line.trim().trim("/")
      if trimmed-line.len() == 0 { continue }
      if not started-args { fn-desc += trimmed-line + "\n"}
      else { // Return type:
        if trimmed-line.trim().starts-with("->") {
          return-types = trimmed-line.trim().slice(2).split(",").map(x => x.trim())
        } else {
          documented-args.last().desc += "\n" + trimmed-line 
        }
      }
    } else {
      started-args = true
      let param-name = arg-match.captures.at(0)
      let param-types = arg-match.captures.at(1).split(",").map(x => x.trim())
      let param-desc = arg-match.captures.at(2)
      documented-args.push((name: param-name, types: param-types, desc: param-desc))
    }
  }
  fn-desc = process-function-references(fn-desc, parse-info)
  let args = parse-parameter-list(content, match.end)
  for arg in documented-args {
    if arg.name in args {
      args.at(arg.name).description = process-function-references(arg.desc, parse-info)
      args.at(arg.name).types = arg.types
    } else {
      assert(false, message: "The parameter \"" + arg.name + "\" does not appear in the argument list of the function \"" + fn-name + "\"")
    }
  }
  if parse-info.require-all-parameters {
    for arg in args {
      assert(documented-args.find(x => x.name == arg.at(0)) != none, message: "The parameter \"" + arg.at(0) + "\" of the function \"" + fn-name + "\" is not documented. ")
    }
  }
  return (name: fn-name, description: fn-desc, args: args, return-types: return-types)
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
/// - require-all-parameters (boolean): Require that all parameters of a functions are documented and fail if some are not. 
#let parse-code(
  content, 
  label-prefix: none, 
  require-all-parameters: false
) = {
  let matches = content.matches(docstring-matcher)
  let function-docs = ()
  let parse-info = (
    label-prefix: label-prefix,
    require-all-parameters: require-all-parameters
  )

  for match in matches {
    function-docs.push(parse-function-docstring(content, match, parse-info))
  }
  let result = (functions: function-docs, label-prefix: label-prefix)
  return result
}

/// Parse the docstrings of a typst module. This function returns a dictionary with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module if not given explicity.
/// 
/// See @@parse-code() for more details. 
///
/// - filename (string): Filename for the `.typ` file to analyze for docstrings.
/// - name (auto, string): The name for the module. If `auto`, the module name will be derived from the filename. 
/// - label-prefix (auto, string): The label-prefix for internal function references. If `auto`, the label-prefix name will be derived from the filename. 
/// - require-all-parameters (boolean): Require that all parameters of a functions are documented and fail if some are not. 
#let parse-module(
  filename, 
  name: auto, 
  label-prefix: auto,
  require-all-parameters: false
) = {
  let module-name = filename.replace(".typ", "")
  let prefix = if label-prefix == auto { module-name } else { label-prefix }
  let result = parse-code(read(filename), label-prefix: prefix, require-all-parameters: require-all-parameters)
  result.name = if name == auto { module-name } else { name }
  return result
}


#let default-show-outline(module-doc) = {
  let prefix = module-doc.label-prefix
  let items = ()
  for fn in module-doc.functions {
    items.push(link(label(prefix + fn.name + "()"), fn.name + "()"))
  }
  list(..items)
}

#let default-display-parameter-list-function(fn, display-type-function) = {
  pad(x: 10pt, {
    set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: fn-color)
    "("
    let inline-args = fn.args.len() < 2
    if not inline-args { "\n  " }
    let items = ()
    for (arg-name, info) in fn.args {
      let types 
      if "types" in info {
        types = ": " + info.types.map(x => display-type-function(x)).join(" ")
      }
      items.push(arg-name + types)
    }
    items.join( if inline-args {", "} else { ",\n  "})
    if not inline-args { "\n" } + ")"
    if fn.return-types != none {
      " -> " 
      fn.return-types.map(x => display-type-function(x)).join(" ")
    }
  })
}


#let show-function(
  fn, 
  label-prefix: none, 
  first-heading-level: 2, 
  allow-breaking: false, 
  omit-empty-param-descriptions: true,
  display-type-function: colored-type-box,
  display-parameter-list-function: default-display-parameter-list-function
) = {
  [
    #heading(fn.name, level: first-heading-level + 1)
    #label(label-prefix + fn.name + "()")
  ]
  eval-with-images("[" + fn.description + "]")

  block(breakable: allow-breaking, {
    heading("Parameters", level: first-heading-level + 2)
    display-parameter-list-function(fn, display-type-function)
  })

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description.trim() == "" and omit-empty-param-descriptions { continue }
    param-description-block(
      name, 
      types, description, 
      show-default: "default" in info, 
      default: info.at("default", default: none),
      breakable: allow-breaking,
      display-type-function: display-type-function
    )
  }
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
/// - show-function (function): Function to use to show the documentation for a single
///           function. This can be used to customize the look of the documentation. 
/// - show-outline (function): Function to use to show the documentation for a single
/// - sort (auto, none, function): Function to use to sort the function documentations. 
///           With `auto`, they are sorted alphabetatically by name and with `none` they
///           are not sorted. 
/// -> content
#let show-module(
  module-doc, 
  first-heading-level: 2,
  show-module-name: true,
  type-colors: type-colors,
  allow-breaking: false,
  omit-empty-param-descriptions: true,
  show-outline: false,
  sort: auto,
  show-function: show-function
) = {
  let label-prefix = module-doc.label-prefix
  if "name" in module-doc and show-module-name {
    heading(module-doc.name, level: first-heading-level)
    parbreak()
  }
  
  if sort == auto { module-doc.functions = module-doc.functions.sorted(key: x => x.name) }
  else if type(sort) == "function" { module-doc.functions = module-doc.functions.sorted(key: sort) }
  
  if show-outline {
    default-show-outline(module-doc)
  }
  
  for (index, fn) in module-doc.functions.enumerate() {
    show-function(
      fn, 
      label-prefix: label-prefix, 
      first-heading-level: first-heading-level, 
      allow-breaking: allow-breaking, 
      omit-empty-param-descriptions: omit-empty-param-descriptions
    )
    // if index < module-doc.functions.len() - 1  { v(1cm) }
  }
}


