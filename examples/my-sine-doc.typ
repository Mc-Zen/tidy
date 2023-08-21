#import "my-sine.typ"
// #import "@preview/tidy:0.1.0":*
#import "/src/tidy.typ": *


#let example(code) = {
  table(columns: (1fr, 1fr),
   raw(code.text.replace("my-sine.", ""), block: true, lang: "typc"),
   eval(code.text, mode: "code", scope: (my-sine: my-sine))
  )
}


#{
  let module = parse-module(read("/examples/my-sine.typ"), name: "my-sine", scope: (my-sine: my-sine/*, example: example*/))
  show-module(module, style: styles.default)


  let k = `asdasd`


  let jgfh = k
  // k.fields()
  // k.has()
}

