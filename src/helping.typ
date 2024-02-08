#import "styles.typ"
#import "utilities.typ"
#import "testing.typ"
#import "parse-module.typ": parse-module
#import "show-module.typ": show-module



/// Prints references directly into your document while typsting. This allows
/// one to easily check the usage and documentation of a function or variable. 
///
/// - namespace (dictionary): This dictionary should represent the namespace of the package in a tree structure, containing `read.with()` objects at the leafs. 
/// - style (dictionary): a
/// - package-name (string): a
///   Example
///   ```typc
///   (
///     ".": read.with("/src/lib.typ"),
///     "utility": read.with("/src/utility.typ"),
///     "testing": (
///       ".": (read.with("/src/testing1.typ"), read.with("/src/testing2.typ")),
///       "advanced": read.with("/src/testing/advanced.typ"),
///     )
///   )
///   ```
///  Each definition in your package should be accessible through this dictionary in the same way as 
///  in your entrypoint file. I.e., all symbols that are in scope when importing `*` from your 
///  package are to be put in the root directory `"."`. If your entrypoint file imports some other file
///  `utility.typ` (without importing any definitions specifically), then it is inserting into the 
///  dictionary at `"utility"` and so on. 
///  
///  By providing instances of `read()` with the filename prepended, you allow tidy to read the files 
///  that are not part of the tidy package but at the same time enable lazy evaluation of the files, 
///  i.e., a file is only opened when a definition from this file is requested through `help()`. 
#let generate-help(style: styles.help, namespace: (".": ""), package-name: "") = {

  let validate-namespace-tree(namespace) = {
    let validate-file-reader(file-reader) = {
      assert(type(file-reader) == function, message: "The namespace must have instances of `read.with([filename])` as leaves, found " + repr(file-reader))
    }
    for (entry, value) in namespace {
      if type(value) == array {
        for file-reader in value {
          validate-file-reader(file-reader)
        } 
      } else if type(value) == dictionary {
        validate-namespace-tree(value)
      } else {
        validate-file-reader(value)
      }
    }
  }

  validate-namespace-tree(namespace)

  let help-function = (name, style: style) => {

    if type(name) == function { name = repr(name) }
    assert.eq(type(name), str, message: "The definition name has to be a string, found `" + repr(name) + "`")

    let name-components = name.split(".")
    name = name-components.pop()
    let module-name = name-components.join(".")

    let current-module = namespace
    let current-subnamespace-name = ""
    name-components = name-components.rev()
    while name-components.len() > 0 {
      let sub-namespace = name-components.pop()
      if sub-namespace in current-module {
        current-module = current-module.at(sub-namespace)
        current-subnamespace-name = sub-namespace
      } else {
        if current-subnamespace-name == "" {
          assert(false, message: "The package `" + package-name + "` contains no module `" + sub-namespace + "`")
        } else {
          assert(false, message: "The module `" + current-subnamespace-name + "` from the package `" + package-name + "` contains no module `" + sub-namespace + "`")
        }
      }
    }

    // Select root of module
    if type(current-module) == dictionary {
      current-module = current-module.at(".")
    }
    // "Module" is made up of several files
    if type(current-module) != array {
      current-module = (current-module,)
    }
    let module = parse-module(current-module.map(x => x()).join("\n"))

    // We support selecting a specific parameter name (for functions)
    let param-name
    if "(" in name {
      let match = name.match(regex("(\w[\w\d\-_]*)\((.*)\)"))
      if match != none {
        (name, param-name) = match.captures
        if param-name == "" { param-name = none }
      }
    }

    let result
    // First check if there is a function with the given name
    let definition-doc = module.functions.find(x => x.name == name)
    if definition-doc != none {
      if param-name != none { // extract only the parameter description
        let style-functions = utilities.get-style-functions(style)
            
        let style-args = (
          style: style-functions,
          label-prefix: "", 
          first-heading-level: 2, 
          break-param-descriptions: true, 
          omit-empty-param-descriptions: false,
          colors: styles.default.colors,
          enable-cross-references: false
        )
            
        let eval-scope = (
          // Predefined functions that may be called by the user in docstring code
          example: style-functions.show-example.with(
            inherited-scope: module.scope
          ),
          test: testing.test.with(
            inherited-scope: testing.assertations + module.scope, 
            enable: false
          ),
          // Internally generated functions 
          tidy: (
            show-reference: style-functions.show-reference.with(style-args: style-args)
          )
        )
      
        eval-scope += module.scope
      
        style-args.scope = eval-scope
        
      
        // Show the docs
        assert(param-name in definition-doc.args, message: "The function `" + name + "` has no parameter `" + param-name)
        let info = definition-doc.args.at(param-name)
        let types = info.at("types", default: ())
        let description = info.at("description", default: "")
        result = block(strong(name), above: 1.8em)
        result += (style.show-parameter-block)(
          param-name, types, utilities.eval-docstring(description, style-args), 
          style-args,
          show-default: "default" in info, 
          default: info.at("default", default: none),
        )
      }
      module.functions = (definition-doc,)
      module.variables = ()
    } else {
      let definition-doc = module.variables.find(x => x.name == name)
      if definition-doc != none {
        assert(param-name == none, message: "Parameters can only be specified for function definitions, not for variables. ")
        module.variables = (definition-doc,)
        module.functions = ()
      } else {
        
        if current-subnamespace-name == "" {
          assert(false, message: "The package `" + package-name + "` contains no documented definition `" + name + "`")
        } else {
          assert(false, message: "The module `" + current-subnamespace-name + "` from the package `" + package-name + "` contains no documented definition `" + name + "`")
        }
      }
    }
    if result == none {
      result = show-module(
        module, 
        style: style,
        enable-cross-references: false,
        enable-tests: false,
        show-outline: false
      )
    }
    set text(size: .9em)
    block(
      above: 1em,
      inset: 1em,
      stroke: rgb("#AAA"),
      fill: rgb("#F5F5F544"),
      {
        text(size: 2em, [? #smallcaps("help")#h(1fr)?]) 
        result
      }
    )
  }
  help-function
}
