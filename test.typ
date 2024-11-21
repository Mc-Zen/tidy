// #import "@preview/tidy:0.3.0"
#import "src/tidy.typ"

#show raw.where(block: true): highlight

#let module = ````
/// #example(```
/// [a #raw("foo") b]
/// ```)
let x = none

/// #example(`[a #raw("foo") b]`)
let y = none

/// #example(raw(`[a #raw("foo") b]`.text), mode: "markup")
let z = none

/// #example(raw(lang: "typc", `[a #raw("foo") b]`.text))
let ß = none
````.text

#let module = tidy.parse-module(
  module,
  // preamble: "set raw(block: false);"
)
#tidy.show-module(
  module,
  sort-functions: none,
  style: tidy.styles.minimal,
)