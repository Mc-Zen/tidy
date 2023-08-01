#import "/src/tidy.typ": *
#set text(font: "DM Sans")

#set page(width: 300pt, height: auto, margin: 0em)

#show heading: set text(size: 1.5em)
#show heading.where(level: 4): set text(size: .7em)

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

#block(fill: luma(235), inset: 20pt, 
{
  set text(size: .8em)
  let example-code-doc = parse-module(example-code.text)
  show-module(example-code-doc)
})