#import "template.typ": *
#show link: underline

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "typst-doc",
  subtitle: "A doctor for your documentation",
  authors: (
    "Mc-Zen",
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [*typst-doc* is a package that generates documentation directly in #link("https://typst.app/", [Typst])  for your Typst modules. It parses docstring comments similar to javadoc and co. and can be used to easily build a reference section for each module.  ],
  date: "June 7, 2023",
)
// #set text(font: "DM Sans")

#import "../typst-doc.typ": *



#show heading: set text(size: 1.5em)
#show heading.where(level: 4): set text(size: .7em)

// The entire block may be indented by any amount, the declaration can either start with `#let` or `let`. The docstring must start with `///` on every line and the function declaration needs to start exactly at the next line. 

#set par(justify: true)

#show raw.where(block: false): it => box(inset: (x: 3pt), outset: (y: 3pt), radius: 40%, fill: luma(235), it)

= Introduction

Feed *typst-doc* your in-code documented source files and get beautiful documentation of all your functions printed out. Enjoy features like type annotations, links to other documented functions and arbitrary formatting within function and parameter descriptions. Let's get started.

You can document your functions similar to javadoc by prepending a block of `///` comments. 

*Example*

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

Each line needs to start with three slashes `///` (whitespace is allowed at the beginning of the line). Parameters of the function can be documented by listing them with `-` as showed above. The possible types for each parameter are given in parantheses and after a colon `:`, the parameter description follows. An optional return type can be annotated by ending with a line that contains `->` and the return type. 

In front of the arguments, a function description can be put. Both function and parameter descriptions may span multiple lines and can contain any Typst code. 

Calling `parse-code()` on the snippet above will read out the documentation of the given string. We can now invoke `show-module()` on the result to obtain the following result:

#block(fill: luma(235), inset: 20pt, 
{
  set text(size: .8em)
  let example-code-doc = parse-code(example-code.text)
  show-module(example-code-doc)
})

Cool, he?

Usually, you'll want to parse a file, so you can instead just call `parse-module("myfile.typ")` and then `show-module()` the result. 


There is another little nice feature: in the docstring, you can reference other functions by writing `@@other-function()`. This will automatically create a link that when clicked will lead you to the documentation of that function. 

Of course, everything happens instantaneously, so you can see the live result while writing the docs for your package. Keep your code documented!


Let us now "self-document" this package:

#{
  let result = parse-module("typst-doc.typ")
  let p = result.functions.remove(0)
  result.functions.push(p)
  // show-module(result)
  show-module(result)
}

