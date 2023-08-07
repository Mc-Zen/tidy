#import "template.typ": *
#import "@preview/tidy:0.1.0"
#show link: underline


// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "funny-math",
  subtitle: "Because math should be fun",
  authors: (
    "Euklid",
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [*funny-math* is a funny math package for #link("https://typst.app/", [Typst]).  ],
  date: "361 B.C.",
)

// We can apply global styling here to affect the looks
// of the documentation. 
#set text(font: "DM Sans")
#show heading.where(level: 1): it => {
  align(center, it)
}
#show heading: set text(size: 1.5em)
#show heading.where(level: 3): set text(size: .7em, style: "italic")

#pagebreak()
#{
  import "funny-math.typ"
  let image1 = image("/settings.svg", width: 20pt)
  let funny-module = tidy.parse-module(read("/funny-math.typ"), name: "Funny module", scope: (image1: image1, funny-math: funny-math))
  tidy.show-module(funny-module, first-heading-level: 1)
  
  let funny-module-ext = tidy.parse-module(read("/funny-math-complex.typ"), name: "Funny Math Extension Module")
  
  pagebreak()
  // Also show the "complex" sub-module which belongs to the main module (funny-math.typ) since it is imported by it. 
  tidy.show-module(funny-module-ext, first-heading-level: 1)
}