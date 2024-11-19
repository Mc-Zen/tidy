#import "template.typ": *
#import "/src/tidy.typ"
// #include "/tests/test_tidy.typ" // ensure that tests pass

#let version = toml("/typst.toml").package.version
#let import-statement = "#import \"@preview/tidy:" + version + "\""


#show: project.with(
  title: "Tidy",
  subtitle: "Keep your code tidy.",
  authors: (
    "Mc-Zen",
  ),
  abstract: [
    *tidy* is a package that generates documentation directly in #link("https://typst.app/", [Typst])  for your Typst modules. It parses docstring comments similar to javadoc and co. and can be used to easily build a reference section for each module. 
  ],
  date: datetime.today().display("[month repr:long] [day], [year]"),
  version: version,
  url: "https://github.com/Mc-Zen/tidy"
)


#pad(x: 10%, outline(depth: 1))
#pagebreak()

= Introduction

You can easily feed *tidy* your in-code documented source files and get beautiful documentation of all your functions and variables printed out. // Enjoy features like type annotations, links to other documented definitions and arbitrary formatting within function and parameter descriptions. Let's get started.
The main features are:
- Type annotations,
- Seamless cross references,
- Rendering code examples (see @preview-examples),
- help command generation (see @help-command), and 
- Docstring testing (see @docstring-testing). 
First, we import *tidy*. 
#raw(block: true, lang: "typ", import-statement)

We now assume we have a Typst module called `repeater.typ`, containing a definition for a function named `repeat()`. 

// *Example of some documented source code:*

#let example-code = read("/examples/repeater.typ")
#file-code("repeater.typ", raw(block: true, lang: "typ", example-code))

Tidy uses `///` doc-comments for documentation. 
A function or variable can be provided with a *description* by placing a doc-comment just before the definition. 

Until type annotations are natively available in Typst, a return type can be annotated with the `->` syntax in the last line of the description. If more there is more than one possible return type, they can be given separated by the pipe `|` operator, e.g., `-> int, float`. 

Function arguments are documented in the same way. 
All descriptions are parsed as Typst markup. See @user-defined-symbols on how to add images or examples to a description. 


// A *function* is documented vi 
// similar to javadoc by prepending a block of `///` comments. Each line needs to start with three slashes `///` (whitespace is allowed at the beginning of the line). _Parameters_ of the function can be documented by listing them as 
// #show raw.where(lang: "markspace"): it => {
//   show " ": box(inset: (x: 0.1pt), box(
//     fill: red.lighten(70%), 
//     width: .7em, height: .8em,
//     radius: 1pt,
//     outset: (bottom: 3pt, top: 1pt),
//   ))
//   it
// }
// ```markspace
// /// - parameter-name (type): ...
// ```
// Following this exact form is important (see also the spaces marked in red) since this allows to distinguish the parameter list from ordinary markup lists in the function description or in parameter descriptions. For example, another space in front of the `-` could be added to markup lists if necessary. 

// The possible types for each parameter are given in parentheses and after a colon `:`, the parameter description follows. Indicating a type is mandatory (you may want to pick `any` in some cases). An optional _return type_ can be annotated by ending with a line that contains `->` followed by the return type(s). 

// In front of the parameter list, a _function description_ can be put. 

// *Variables* are documented just in the same way (lacking the option to specify parameters). A definition is recognized as a variable if the identifier (variable/function name) is not followed by an opening parenthesis. The `->` syntax which also specifies the return type for functions can be used to define the type of a variable. 

Calling #ref-fn("parse-module()") will read out the documentation of the given string. We can then invoke #ref-fn("show-module()") on the returned docs object. The actual output depends on the utilized style template, see @customizing. 

```typ
#let docs = tidy.parse-module(read("docs.typ"), name: "Repeater")
#tidy.show-module(docs)
```

This will produce the following output. 
#tidy-output-figure(
  tidy.show-module(tidy.parse-module(example-code, name: "Repeater", old-parser: false), style: tidy.styles.default)
)


Cool, he?

By default, an outline for all definitions is displayed at the top. This behaviour can be turned off with the parameter `show-outline` of #ref-fn("show-module()"). 

There is another nice little feature: in the docstring, you can cross-reference other definitions with the extra syntax `@@repeat()` or `@@awful-pi`. This will automatically create a link that when clicked in the PDF will lead you to the documentation of that definition. 


Of course, everything happens instantaneously, so you can see the live result while writing the docs for your package. Keep your code documented!


= More options

Sometimes you want to document "private" functions and variables but omit them in the public documentation. In order to hide all definitions starting with an underscore, you may set `omit-private-definitions` to `true` in the call to #ref-fn("show-module()"). Similarly, "implementation parameters" to otherwise public functions occur once in a while. These are then used internally by the library. In order to conceal such parameters which may lead to confusion with dedicated documentation readers, you can name them with a leading underscore and set `omit-private-parameters` to `true` as well. 


#pagebreak()
= Accessing user-defined symbols <user-defined-symbols>


This package uses the Typst function #raw(lang: "typc", "eval()") to process function and parameter descriptions in order to enable arbitrary Typst markup within those. Since #raw(lang: "typc", "eval()") does not allow access to the filesystem and evaluates the content in a context where no user-defined variables or functions are available, it is not possible to directly call #raw(lang: "typ", "#import"), #raw(lang: "typ", "#image") or functions that you define in your code. 

Nevertheless, definitions can be made accessible with *tidy* by passing them to #ref-fn("parse-module()") through the optional `scope` parameter in form of a dictionary: 
```typ
#let make-square(width) = rect(width: width, height: width)
#tidy.parse-module(
  read("my-module.typ"), scope: (make-square: make-square)
)
```
This makes any symbol in specified in the `scope` dictionary available under the name of the key. A function declared in `my-module.typ` can now use this variable in the description:
```typ
/// This is a function
/// #make-square(20pt)
#let my-function() = {}
```

It is even possible to add *entire modules* to the scope which makes rendering examples using your module really easy. Let us say the file `wiggly.typ` contains:

#file-code("wiggly.typ", raw(lang: "typ", block: true, read("/examples/wiggly.typ")))

#pagebreak()

Note, that we use the predefined function `example()` here to show the code as well as the rendered output of some demo usage of our function. The `example()` function is treated more in-detail in @preview-examples.

We can now parse the module and pass the module `wiggly` through the `scope` parameter. Furthermore, we apply another trick: by specifying a `preamble`, we can add code to run before each example. Here we use this feature to import everything from the module `wiggly`. This way, we can directly write `draw-sine(...)` in the example (instead of `wiggly.draw-sine(...)`):
```typ
#import "wiggly.typ" // don't import something specific from the module!

#let docs = tidy.parse-module(
  read("wiggly.typ"), 
  name: "wiggly",
  scope: (wiggly: wiggly),
  preamble: "import wiggly: *;"
)
```

In the output, the preview of the code examples is shown next to it.

#{
  import "/examples/wiggly.typ"

  let module = tidy.parse-module(
    read("/examples/wiggly.typ"), 
    name: "wiggly",
    scope: (wiggly: wiggly),
    preamble: "import wiggly: draw-sine;", 
    old-parser: false
  )
  tidy-output-figure(tidy.show-module(module, show-outline: false))
}

#pagebreak()








= Preview examples <preview-examples>

As we saw in the previous section, it is possible with *tidy* to add examples to a docstring and preview it along with its output. 
The function `example()` is available in every docstring and has some bells and whistles which are showcased with the following `example-demo.typ` module which contains a function for highlighting text with gradients (seems not very advisable due to the poor readability):

// #file-code("example-demo.typ", raw(lang: "typ", block: true, read("/examples/example-demo.typ")))

#{  
  set text(size: .89em)
  import "/examples/example-demo.typ"
  
  let module = tidy.parse-module(
    read("/examples/example-demo.typ"), 
    scope: (example-demo: example-demo),
    old-parser: false
  )
  tidy-output-figure(tidy.show-module(module, show-outline: false, break-param-descriptions: true))
}






= Customizing the style <customizing>

There are multiple ways to customize the output style. You can
- pick a different predefined style,
- apply show rules before printing the module documentation or
- create an entirely new style.


A different predefined style can be selected by passing a style to the `style` parameter:
```typ
#tidy.show-module(
  tidy.parse-module(read("my-module.typ")), 
  style: tidy.styles.minimal
)
```

You can use show rules to customize the document style before calling #ref-fn("show-module()"). Setting any text and paragraph attributes works just out of the box. Furthermore, heading styles can be set to affect the appearance of the module name (relative heading level 1), function or variable names (relative heading level 2) and the word *Parameters* (relative heading level 3), all relative to what is set with the parameter `first-heading-level` of #ref-fn("show-module()"). 

Finally, if that is not enough, you can design a completely new style. Examples of styles can be found in the folder `src/styles/` in the #link("https://github.com/Mc-Zen/tidy", "GitHub Repository"). 


== Customizing Colors (mainly for the `default` style)

The colors used by a style (especially the color in which types are shown) can be set through the option `colors` of #ref-fn("show-module()"). It expects a dictionary with colors as values. Possible keys are all type names as well as `signature-func-name` which sets the color of the function name as shown in a function signature. 

The `default` theme defines a color scheme `colors-dark` along with the default `colors` which adjusts the plain colors for better readability on a dark background. 

```typ
#tidy.show-module(
  docs, 
  colors: tidy.styles.default.colors-dark
)
```
With a dark background and light text, these colors produce much better contrast than the default colors:
#{ 
  set box(fill: luma(20))
  set text(fill: luma(240))
  
  let module = tidy.parse-module(
    ```
    /// Produces space. 
    #let space(
      /// -> length
      amount
    )
    ```.text,
    old-parser: false
  )
  tidy-output-figure(tidy.show-module(module, show-outline: false, colors: tidy.styles.default.colors-dark, style: tidy.styles.default))
}

#pagebreak()

== Predefined styles 
Currently, the two predefined styles `tidy.styles.default` and `tidy-styles.minimal` are available.
- `tidy.styles.default`: Loosely imitates the online documentation of Typst functions. 
- `tidy.styles.minimal`: A very light and space-efficient theme that is oriented around simplicity. With this theme, the example from above looks like the following:
#{
  import "/examples/wiggly.typ"
  
  let module = tidy.parse-module(
    read("/examples/wiggly.typ"), 
    name: "wiggly",
    scope: (wiggly: wiggly),
    preamble: "import wiggly: *;",
    old-parser: false
  )
  tidy-output-figure(tidy.show-module(module, show-outline: false, style: tidy.styles.minimal))
}




#pagebreak()
= Help command <help-command>

#text(red)[This feature is still experimental and may change a bit in its details. Output customization will be made available with the introduction of user-defined types into Typst. The _search_ feature will then move into a nested function, i.e., `help.search()`. ]

With *tidy*, you can easily add a `help` command to your package. This allows the users of your package to call #raw(lang: "typ", "#your-package.help(\"foo\")") to get the docs for the specified definition printed right in their document. This makes reading up on options and discovering features in your package effortless. After the desired information has been gathered, it's no more than deleting a line of document source code to make the docs vanish into the hidden realms of repositories once again!

As a demonstration, calling #raw(lang: "typ", "#tidy.help(\"parse-module\")") produces the following (clipped) output into the document. 
#{
  set text(size: .8em)
  pad(x: 5%,
    box(
      height: 170pt, clip: true,
      box(
        height: 180pt, clip: true,
        box(tidy.help("parse-module"))
      )
    )
  )
    
}
/*
The feature that will make using *your* package attractive. 
Without leaving the editor

The usage and ease of access for typst packages is about to be revolutionized!
*/

This feature supports:
- function and variable definitions,
- definitions defined in nested submodules, e.g., \ #raw(lang: "typ", "#your-package.help(\"sub.bar.foo\")")
- asking only for the parameter description of a function, e.g., \ #raw(lang: "typ", "#your-package.help(\"foo(param1)\")")
- lazy evaluation of docstring processing (even loading `tidy` is made lazy). \ _Don't pay for what you don't use!_
- search through the entire package documentation, e.g., \ #raw(lang: "typ", "#your-package.help(search: \"module\")")


== Setup

If you have already documented your code, adding such a help function will require only little further effort in implementation. In your root library file, add some code of the following kind:
#raw(block: true, lang: "typ", ```
#let help(..args) = {
```.text + "\n  " + import-statement.slice(1) + "\n" + 
```
  let namespace = (
    ".": read.with("/src/my-package.typ")
  )
  tidy.generate-help(namespace: namespace, package-name: "tidy")(..args)
}
```.text)
First, we set up a `namespace` dictionary that reflects the way that definitions can be accessed by a user. Note that due to import statements that import _from_ a file, this may not reflect the actual file structure of your repository. Take care to provide `read.with()` objects with the filename prepended instead of directly calling `read()`. This allows *tidy* to only lazily read the source files upon a help request from the end user.  

As a more elaborate example, let us look at some library root file for a maths package called `heymath`. 
#file-code("heymath.typ", ```typ
#import "vec.typ": vec-add, vec-subtract // import definitions into root
#import "matrix.typ"                     // submodule "matrix"

/// ...
#let pi-squared = 9.86960440108935861883
```)
Our `namespace` dictionary could then look like this:
```typc
let namespace = (
  ".": (read.with("/heymath.typ"), read.with("/vec.typ"))
  "matrix": read.with("/matrix.typ")
  "matrix.solve": read.with("/solve.typ")
)
```
Since the symbols from `vec.typ` are imported directly into the library (and are accessible through `heymath.vec-add()` and `heymath.vec-subtract()`), we add this file to the root together with the main library file. Both files will be internally concatenated for docstring processing. The content of `matrix.typ`, however, can only be accessed through `heymath.matrix.` (by the user) and so we place `matrix.typ` at the key `matrix`. 
For nested submodules, write out the complete name "path" for the key. As an example, we have added `matrix.solve` -- a module that would be imported within `matrix.typ` -- to the code sample above. *It is advised not to change the signature of the help function manually in order to keep consistency between different packages using this features*. 


== Searching

It is also possible to search the package documentation via the search argument of the help function: \ #raw(lang: "typ", "#tidy.help(search: \"module\")"). This feature is even more experimental. 
#{
  set text(size: .8em)
  pad(x: 5%,
    box(
      height: 170pt, clip: true,
      box(
        height: 180pt, clip: true,
        box(tidy.help(search: "module"))
      )
    )
  )
}

== Output customization (for end-users)

The default style for help output should work more or less for light and dark documents but is otherwise not very customizable. This is intended to be changed when user-defined types are available in Typst because these would provide the ideal interface for such customization. Until then, I do not deem it much sense to provide a temporary solution that need. 

== Notes about optimization (for package developers)

When set up in the form as shown above, the package `tidy` is only imported when a user calls `help` for the first time and not at all if the feature is not used _(don't pay for what you don't use)_. The files themselves are also only read when a definition from a specific submodule in the "namespace" is requested. In the case of _extremely_ long code files, it _could_ make sense to separate the documentation from the implementation by adding "documentation files" that only contain a _declaration_ plus docstring for each definition -- with the body left empty. 
```typ
#let my-really-long-algorithm(
  /// The inputs for the algorithm. -> array
  inputs, 
  /// Some parameters. -> none | dictionary
  parameters: none
  ) = { }
```

The advantage is that the source code is not as crowded with (sometimes very long) docstrings and that docstring parsing may get faster. On the downside, there is an increased maintenance overhead due to the need of synchronizing the actual file and the documentation file (especially when the interface of a function changes). 



#pagebreak()
= Docstring testing <docstring-testing>

Tidy supports small-scale docstring tests that are executed automatically and throw appropriate error messages when a test fails. 

In every docstring, the function #raw(lang: "typc", "test(..tests, scope: (:))") is available. An arbitrary number of tests can be passed in and the evaluation scope may be extended through the `scope` parameter. Any definition exposed to the docstring evaluation context through the `scope` parameter passed to #ref-fn("parse-module()") (see @user-defined-symbols) is also accessible in the tests. Let us create a module `num.typ` with the following content:

```typ
/// #test(
///   `num.my-square(2) == 4`,
///   `num.my-square(4) == 16`,
/// )
#let my-square(n) = n * n
```

Parsing and showing the module will run the docstring tests. 

```typ
#import "num.typ"
#let module = tidy.parse-module(
  read("num.typ"), 
  name: "num", 
  scope: (num: num)
)
#tidy.show-module(module) // tests are run here
```

As alternative to using `test()`, the following dedicated shorthand syntax can be used:

```typ
/// >>> my-square(2) == 4
/// >>> my-square(4) == 16
#let my-square(n) = n * n
```

When using the shorthand syntax, the error message even shows the line number of the failed test in the corresponding module. 

A few test assertion functions are available to improve readability, simplicity and error messages. Currently, these are `eq(a, b)` for equality tests, `ne(a, b)` for inequality tests and `approx(a, b, eps: 1e-10)` for floating point comparisons. These assertion helper functions are always available within docstring tests (with both `test()` and `>>>` syntax). 

Docstring tests can be disabled by passing `enable-tests: false` to #ref-fn("show-module()"). 




#pagebreak()
= Function documentation

Let us now "self-document" this package:

#let style = tidy.styles.default
#{
  set heading(numbering: none)
  set text(size: 9pt)
  
  let module = tidy.parse-module(
    (
      read("/src/parse-module.typ"),
      read("/src/show-module.typ"),
      read("/src/helping.typ")
    ).join("\n"),
    name: "tidy", 
    require-all-parameters: true, 
    old-parser: false
  )
  tidy.show-module(
    module, 
    style: style,
    show-outline: true, 
    sort-functions: false, 
    omit-private-parameters: true,
    omit-private-definitions: true
  )
}
