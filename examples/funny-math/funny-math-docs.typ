#import "template.typ": *
// #import "@preview/tidy:0.1.0"
#import "../../src/tidy.typ"
#import "custom-style.typ"

#show: project.with(
  title: "funny-math",
  subtitle: "Because math should be fun",
  authors: ("Euklid",),
  abstract: [*funny-math* is a funny math package for #link("https://typst.app/", [Typst]).  ],
  date: "361 B.C.",
)

// We can apply global styling here to affect the looks
// of the documentation. 
#set text(font: "Calibri", size: 9pt)
// #show heading: set text(size: 11pt)

// Module name
#show heading.where(level: 1): set text(size: 1.3em, font: "Cascadia Mono")

// Function name
#show heading.where(level: 2): set text(size: 1.2em, font: "Cascadia Mono")
#show heading.where(level: 2): block.with(above: 3em, below: 2em)

// "Parameters", "Example"
#show heading.where(level: 3): set text(size: 1.1em, weight: "semibold")
// #show heading.where(level: 3): block.with(spacing: 2em)
#show heading.where(level: 4): set text(size: 1.1em, font: "Cascadia Mono")


#pagebreak()

#{
  import "funny-math.typ"
  import "funny-math-complex.typ"
  let image-polar = image("polar.svg", width: 150pt)

  let show-module = tidy.show-module.with(
    first-heading-level: 1,
    style: custom-style
  )
  
  let funny-module = tidy.parse-module(
    read("funny-math.typ"), 
    name: "funny-math", 
    label-prefix: "funny-math",
    scope: (funny-math: funny-math)
  )
  show-module(funny-module)
  
  let funny-module-ext = tidy.parse-module(
    read("funny-math-complex.typ"), 
    name: "funny-math.complex",
    label-prefix: "funny-math",
    scope: (funny-math-comples: funny-math-complex, image-polar: image-polar)
  )
  
  pagebreak()
  // Also show the "complex" sub-module which belongs to the main module (funny-math.typ) since it is imported by it. 
  show-module(funny-module-ext)
}
