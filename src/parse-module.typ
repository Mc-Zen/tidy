#import "tidy-parse.typ"
#import "styles.typ"


#let resolve-parents(function-docs) = {
  for i in range(function-docs.len()) {
    let docs = function-docs.at(i)
    if not "parent" in docs { continue }
    
    let parent = docs.parent
    if parent == none { continue }
    
    let parent-docs = function-docs.find(x => x.name == parent.name)
    if parent-docs == none { continue }

    // Inherit args and return types from parent
    docs.args = parent-docs.args
    docs.return-types = parent-docs.return-types
    
    for (arg, value) in parent.named {
      assert(arg in docs.args)
      docs.args.at(arg).default = value
    }
    
    // Maybe strip some positional arguments
    if parent.pos.len() > 0 {
      let named-args = docs.args.pairs().filter(((_, info)) => "default" in info)
      let positional-args = docs.args.pairs().filter(((_, info)) => not "default" in info)
      assert(parent.pos.len() <= positional-args.len(), message: "Too many positional arguments")
      positional-args = positional-args.slice(parent.pos.len())
      docs.args = (:)
      for (name, info) in positional-args + named-args {
        docs.args.insert(name, info)
      }
    }
    function-docs.at(i) = docs
  }
  return function-docs
}


/// Parse the docstrings of a typst module. This function returns a dictionary 
/// with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module if not given 
/// explicity.
/// 
/// The function documentation dictionaries contain the keys
/// - `name`: The function name.
/// - `description`: The function's docstring description.
/// - `args`: A dictionary of info objects for each function argument.
///
/// These again are dictionaries with the keys
/// - `description` (optional): The description for the argument.
/// - `types` (optional): A list of accepted argument types. 
/// - `default` (optional): Default value for this argument.
/// 
/// See @@show-module() for outputting the results of this function.
///
/// - content (str): Content of `.typ` file to analyze for docstrings.
/// - name (str): The name for the module. 
/// - label-prefix (auto, str): The label-prefix for internal function 
///       references. If `auto`, the label-prefix name will be the module name. 
/// - require-all-parameters (boolean): Require that all parameters of a 
///       functions are documented and fail if some are not. 
/// - scope (dictionary): A dictionary of definitions that are then available 
///       in all function and parameter descriptions. 
/// - preamble (str): Code to prepend to all code snippets shown with `#example()`. 
///       This can for instance be used to import something from the scope. 
#let parse-module(
  content, 
  name: "", 
  label-prefix: auto,
  require-all-parameters: false,
  scope: (:),
  preamble: "",
  enable-curried-functions: true
) = {
  if label-prefix == auto { label-prefix = name }
  
  let parse-info = (
    label-prefix: label-prefix,
    require-all-parameters: require-all-parameters,
  )
  
  let matches = content.matches(tidy-parse.docstring-matcher)
  let function-docs = ()
  let variable-docs = ()

  for match in matches {
    
    if content.len() <= match.end or content.at(match.end) != "("  {
      let doc = tidy-parse.parse-variable-docstring(content, match, parse-info)
      if enable-curried-functions {
        let parent-info = tidy-parse.parse-curried-function(content, match.end)
        if parent-info == none {
          variable-docs.push(doc)
        } else {
          doc.parent = parent-info
          doc.remove("type")
          function-docs.push(doc)
        }
      } else {
        variable-docs.push(doc)
      }
    } else {
      let function-doc = tidy-parse.parse-function-docstring(content, match, parse-info)
      function-docs.push(function-doc)
    }
  }

  if enable-curried-functions {
    function-docs = resolve-parents(function-docs)
  }
  
  return (
    name: name,
    functions: function-docs, 
    variables: variable-docs, 
    label-prefix: label-prefix,
    scope: scope,
    preamble: preamble
  )
}
