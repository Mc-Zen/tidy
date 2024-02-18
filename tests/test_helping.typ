#import "/src/tidy.typ"


#let heymath = ```
#import "vector.typ": *

/// 
#let cos(x) = {}
///
#let pi-squared = 
```.text

#let vector = ```
///
#let vec-add()
///
#let vec-subtract()
```.text


#let matrix = ```
#import "solve.typ"
/// - n (int): dimension
#let id(n)
```.text

#let solve = ```
///
#let solve(n)
```.text


#let help(..args) = {
  let namespace = (
    ".": (() => heymath, () => vector),
    "matrix": () => matrix,
    "matrix.solve": () => solve
  )
  tidy.generate-help(
    namespace: namespace, 
    package-name: "heymath",
    onerror: msg => block(msg)
  )(..args)
}

#help("pi-squared")

#let assert-not-failed(help-result) = {
  assert.eq(
    help-result.child.body.children.at(1)
      .child.children.first().fill,
    rgb("#d8dbed44")
  )
}

// Valid calls
#assert-not-failed(help("cos"))
#assert-not-failed(help("pi-squared"))
#assert-not-failed(help("vec-add"))
#assert-not-failed(help("vec-subtract"))
#assert-not-failed(help("matrix.id"))
#assert-not-failed(help("matrix.solve.solve"))
// #assert-not-failed(help("matrix.id(n)"))
#help("matrix.id(n)")

// Invalid definition
#assert.eq(
  help("ma"), 
  tidy.helping.help-box(block("The package `heymath` contains no (documented) definition `ma`"))
)


// Invalid submodule
#assert.eq(
  help("matrixs.id"), 
  tidy.helping.help-box(block("The package `heymath` contains no module `matrixs`"))
)



// Invalid submodule
#assert.eq(
  help("matrix.id(aaaa)"), 
  tidy.helping.help-box(block("The function `matrix.id` has no parameter `aaaa`"))
)


// Invalid submodule
#assert.eq(
  help("cos(aaaa)"), 
  tidy.helping.help-box(block("The function `cos` has no parameter `aaaa`"))
)


// #help("vec-add")
// #help("vec-subtract")
// #help("matrixs.id")
// #help("matrix.asd")
// #help("matrix.solve.solve")
// #help("cos(x)")
// #help("matrix.id")
#help(search: "vec")