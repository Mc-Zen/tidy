#import "template.typ": *
#import "../../typst-doc.typ": parse-module, show-module
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


#{
  let funny-module = parse-module("funny-math.typ", name: "Funny module")

  show-module(funny-module, first-heading-level: 1)
  
  let funny-module-ext = parse-module("funny-math-complex.typ")

  // Also show the "complex" sub-module which belongs to the main module (funny-math.typ) since it is imported by it. 
  show-module(funny-module-ext, show-module-name: false, first-heading-level: 1)
}