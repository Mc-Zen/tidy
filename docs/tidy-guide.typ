#import "template.typ": *
#import "/src/tidy.typ"
// #import tidy: *
#include "/tests/test_tidy.typ"
#show link: underline

#let version = toml("/typst.toml").package.version
#let import-statement = "#import \"@preview/tidy:" + version + "\""
#show: project.with(
  title: "Tidy",
  subtitle: "Keep your code tidy.",
  authors: (
    "Mc-Zen",
  ),
  abstract: [*tidy* is a package that generates documentation directly in #link("https://typst.app/", [Typst])  for your Typst modules. It parses docstring comments similar to javadoc and co. and can be used to easily build a reference section for each module.  ],
  date: "July 31, 2023",
  version: version,
  url: "https://github.com/Mc-Zen/tidy"
)

#show heading: set text(size: 1.2em)
#show heading.where(level: 4): set text(size: .7em)
#let ref-fn(name) = link(label("tidy" + name), raw(name))

#show raw.where(block: false): it => box(inset: (x: 3pt), outset: (y: 3pt), radius: 40%, fill: luma(235), it)
#show raw.where(block: true): it => pad(x: 2%, block(
  width: 100%, 
  fill: gray.lighten(90%),
  inset: (x: 10pt, y: 4pt),
  outset: (y: 3pt),
  radius: 2pt,
  it
))


#pad(x: 10%, outline(depth: 1))
#pagebreak()

= Introduction

Feed *tidy* your in-code documented source files and get beautiful documentation of all your functions printed out. Enjoy features like type annotations, links to other documented functions and arbitrary formatting within function and parameter descriptions. Let's get started.

First, we import *tidy*. 
#raw(block: true, lang: "typ", import-statement)

You can document your functions similar to javadoc by prepending a block of `///` comments. 

*Example of some documented source code:*

#let example-code = ```typ
/// This function does something. It always returns true.
///
/// We can have *markdown* and 
/// even $m^a t_h$ here. A list? No problem:
///  - Item one 
///  - Item two 
///
///
/// - param1 (string): This is param1.
/// - param2 (content, length): This is param2.
///           Yes, it really is. 
/// -> boolean
#let something(param1, param2: 3pt) = { return true }
```
#example-code

Each line needs to start with three slashes `///` (whitespace is allowed at the beginning of the line). Parameters of the function can be documented by listing them as `- parameter-name (type): ...` as shown above. The possible types for each parameter are given in parentheses and after a colon `:`, the parameter description follows. An optional return type can be annotated by ending with a line that contains `->` and the return type. 

In front of the arguments, a function description can be put. Both function and parameter descriptions may span multiple lines and can contain any Typst code. 

Calling `tidy.parse-module()` on the snippet above will read out the documentation of the given string. We can now invoke `tidy.show-module()` on the result to obtain the following result:

#block(stroke: .5pt, inset: 20pt, 
{
  set text(size: .8em)
  let example-code-doc = tidy.parse-module(example-code.text)
  tidy.show-module(example-code-doc)
})

Cool, he?

Usually, you'll want to parse a file, so you can instead just call 
```typ
#tidy.parse-module(read("my-module.typ"))
```
and then `tidy.show-module()` the result. 


There is another little nice feature: in the docstring, you can reference other functions by writing `@@other-function()`. This will automatically create a link that when clicked will lead you to the documentation of that function. 

Of course, everything happens instantaneously, so you can see the live result while writing the docs for your package. Keep your code documented!

#pagebreak()
= Accessing User-Defined Symbols

This package uses the Typst function `eval()` to process any function or parameter descriptions in order to enable arbitrary Typst markup in them. Since `eval()` does not allow access to the filesystem and evaluates the content in a context where no user-defined variables or functions are available, it is not possible to call `#import`, `#image` or functions that you define in your code. 

Instead, definitions can be made available by passing them to `tidy.parse-module()` with the optional `scope` parameter. 
```typ
#let make-square(width) = rect(width: width, height: width)

#parse-module(read(my-module.typ), scope: (make-square: make-square))
```
A function declared in `my-module.typ` can now use this variable in the description:
```typ
/// This is a function
/// 
/// #makesquare(20pt)
/// 
#let my-function() = {}
```

It is even possible to add entire modules to the scope which makes rendering examples using your module really easy. Let us say, `my-module.typ` looks like the following:
#raw(lang: "typ", block: true, read("/examples/my-module.typ"))

We can now parse the module and 
```typ
#import "my-module.typ" // don't import something specific from the module!

#let module = tidy.parse-module(
  read("my-module.typ"), 
  scope: (my-module: my-module)
)
```


#{
  set text(size: 0.7em)
  import "/examples/my-module.typ"
  
  let module = tidy.parse-module(read("/examples/my-module.typ"), scope: (my-module: my-module))
  block(
    stroke: 0.5pt, 
    inset: 20pt, 
    breakable: false,
    columns(tidy.show-module(module)))
  my-module.draw-sine(1cm, 0.5cm, 2)
}


= Customizing the Style

There are multiple ways to customize the output style. You can
- pick a different predefined style,
- apply show rules before showing the module,
- create an entirely new style.


A different predefined style can be selected by passing a style to the `style` parameter:
```typ
#tidy.show-module(
  tidy.parse-module(read("my-module.typ")), 
  style: tidy.styles.minimal
)
```

A simple modification is also using show rules to customize the document style before calling #ref-fn("show-module()"). Setting any text and paragraph attributes works just out of the box. Furthermore, heading styles can be set to affect the appearance of the module name (relative heading level 1), function names (relative heading level 2) and the word *Parameters* (relative heading level 3), all relative to what is set with the parameter `first-heading-level` of #ref-fn("show-module()"). 



Finally, if that is not enough, you can design a completely new style. Examples of styles can be found in the folder `src/styles/` in the #link("https://github.com/Mc-Zen/tidy", "GitHub Repository"). 


#pagebreak()
= Function Documentation

Let us now "self-document" this package:

#let style = tidy.styles.default
#{
  set text(size: 9pt)

  let module = tidy.parse-module(read("/src/tidy.typ"), name: "tidy", require-all-parameters: true)
  tidy.show-module(module, show-outline: true, sort-functions: true, style: style)
}

#pagebreak()

#{
  set text(size: 9pt)

  let module = tidy.parse-module(read("/src/tidy-parse.typ"), require-all-parameters: true)
  tidy.show-module(module, show-outline: true, sort-functions: true, break-param-descriptions: true, style: style)
}

