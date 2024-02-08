// Source code for the typst-doc package


#import "styles.typ"
#import "tidy-parse.typ"
#import "utilities.typ"
#import "testing.typ"
#import "show-example.typ"
#import "parse-module.typ": parse-module
#import "show-module.typ": show-module
#import "helping.typ": generate-help


#let help = {
  let namespace = (
    ".": (
      read.with("/src/parse-module.typ"), 
      read.with("/src/show-module.typ"),
      read.with("/src/helping.typ"),
    )
  )
  generate-help(namespace: namespace, package-name: "tidy")
}
