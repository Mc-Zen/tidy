#import "template.typ": *
#import "/src/tidy.typ"
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
  date: "August 7, 2023",
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

We now assume we have a Typst module called `my-module.typ`, containing a definition for a function named `something()`. 

*Example of some documented source code:*

#let example-code = read("/examples/my-module.typ")
#raw(lang: "typ", example-code)

You can document your functions similar to javadoc by prepending a block of `///` comments. Each line needs to start with three slashes `///` (whitespace is allowed at the beginning of the line). Parameters of the function can be documented by listing them as 
#show raw.where(lang: "markspace"): it => {
  show " ": box(inset: (x: 0.3pt), box(
    fill: red.lighten(70%), 
    width: .7em, height: 1em,
    radius: 1pt,
    outset: (bottom: 2pt),
  ))
  it
}
```markspace
/// - parameter-name (type): ...
```
Following this exact form is important (see also the spaces marked in red) since this allows to distinguish the parameter list from ordinary markup lists in the function description or in parameter descriptions. For example, another space in front of the `-` could be added to markup lists if necessary. 

The possible types for each parameter are given in parentheses and after a colon `:`, the parameter description follows. Indicating a type is mandatory (you may want to pick `any` in some cases). An optional return type can be annotated by ending with a line that contains `->` and the return type(s). 

In front of the parameter list, a function description can be put. Both function and parameter descriptions may span multiple lines and can contain any Typst code (see @user-defined-symbols on how to use images, user-defined variables and functions in the docstring). 

Calling #ref-fn("parse-module()") will read out the documentation of the given string. We can then invoke #ref-fn("show-module()") on the result.

```typ
#let my-module = tidy.parse-module(read("my-module.typ"), name: "my-module")
#tidy.show-module(my-module)
```

#block(stroke: .5pt, inset: 20pt, breakable: false,
{
  set text(size: .8em)
  let example-code-doc = tidy.parse-module(example-code, name: "my-module")
  figure(align(left, tidy.show-module(example-code-doc)))
})

Cool, he?

By default, an outline for all functions is displayed at the top. This behaviour can be turned off with the parameter `show-outline` of #ref-fn("show-module()"). 

There is another nice little feature: in the docstring, you can reference other functions with the extra syntax `@@other-function()`. This will automatically create a link that when clicked in the PDF will lead you to the documentation of that function. 

Of course, everything happens instantaneously, so you can see the live result while writing the docs for your package. Keep your code documented!




#pagebreak()
= Accessing User-Defined Symbols <user-defined-symbols>


This package uses the Typst function #raw(lang: "typc", "eval()") to process function and parameter descriptions in order to enable arbitrary Typst markup in them. Since #raw(lang: "typc", "eval()") does not allow access to the filesystem and evaluates the content in a context where no user-defined variables or functions are available, it is not possible to directly call #raw(lang: "typ", "#import"), #raw(lang: "typ", "#image") or functions that you define in your code. 

Nevertheless, definitions can be made accessible by passing them to #ref-fn("parse-module()") through the optional `scope` parameter in form of a dictionary: 
```typ
#let make-square(width) = rect(width: width, height: width)

#tidy.parse-module(read("my-module.typ"), scope: (make-square: make-square))
```
This makes any symbol in specified in the `scope` dictionary available under the name of the key. A function declared in `my-module.typ` can now use this variable in the description:
```typ
/// This is a function
/// 
/// #make-square(20pt)
/// 
#let my-function() = {}
```

It is even possible to add *entire modules* to the scope which makes rendering examples using your module really easy. Let us say, `my-sine.typ` contains:
#raw(lang: "typ", block: true, read("/examples/my-sine.typ"))

We can now parse the module and pass the module `my-sine` through the `scope` parameter:
```typ
#import "my-sine.typ" // don't import something specific from the module!

#let module = tidy.parse-module(
  read("my-sine.typ"), 
  scope: (my-sine: my-sine)
)
```


#{
  set text(size: 0.7em)
  import "/examples/my-sine.typ"
  
  let module = tidy.parse-module(read("/examples/my-sine.typ"), scope: (my-sine: my-sine))
  figure(align(left,block(
    width: 80%,
    stroke: 0.5pt, 
    inset: 20pt, 
    breakable: false,
    tidy.show-module(module, show-outline: false)
  )))
}


= Customizing the Style

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

You can use show rules to customize the document style before calling #ref-fn("show-module()"). Setting any text and paragraph attributes works just out of the box. Furthermore, heading styles can be set to affect the appearance of the module name (relative heading level 1), function names (relative heading level 2) and the word *Parameters* (relative heading level 3), all relative to what is set with the parameter `first-heading-level` of #ref-fn("show-module()"). 



Finally, if that is not enough, you can design a completely new style. Examples of styles can be found in the folder `src/styles/` in the #link("https://github.com/Mc-Zen/tidy", "GitHub Repository"). 


#pagebreak()
= Function Documentation

Let us now "self-document" this package:

#let style = tidy.styles.default
#{
  set text(size: 9pt)

  let module = tidy.parse-module(read("/src/tidy.typ"), name: "tidy", require-all-parameters: true)
  tidy.show-module(
    module, 
    style: style,
    show-outline: true, 
    sort-functions: auto, 
  )
}
