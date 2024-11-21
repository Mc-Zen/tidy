#set page(width: 170pt, height: auto, margin: 0pt)
#import "/src/tidy.typ": show-example as example, render-examples
#let show-example = example.show-example.with(
    layout: (code, preview, ..sink) => {
        grid(columns: (1fr, 1fr), align: horizon, code, preview)
    }
)
#let almost-default-show-example = example.show-example.with(
    layout: example.default-layout-example.with(
        code-block: block.with(stroke: .5pt + luma(200)),
        col-spacing: 0pt
    )
)

#set block(below: 0pt)

// All possible combinations of code and markup mode
#show-example(`1`)
#show-example(`#calc.sin(0)`)
#show-example(raw("#calc.sin(0)"))
#show-example(raw(lang: "typc", "calc.sin(0)"))
#show-example(raw(lang: "typc", "calc.sin(0)", block: true))
#show-example(raw(lang: "typ", "#calc.sin(0)"))
#show-example(raw(lang: "typ", "a^2"), mode: "math")
#show-example(raw(lang: "typm", "a^2"), mode: "math")

#pagebreak()

// Check that `raw` is not forced to block in the preview, see #21
#show-example(`a #raw("foo") b`, mode: "markup")
// Language should NOT default to typ in the preview, see #21
#show-example(`#raw("#import")`, mode: "markup")

#pagebreak()

#show-example(`Fit that code in a tiny space`)

#pagebreak()

// Test ratio
#almost-default-show-example(`Ratio .5`, ratio: .5)
#pagebreak()

// Test scale-preview
#almost-default-show-example(`Fit that 200%`, scale-preview: 200%)
#almost-default-show-example(`Fit that 50%`, scale-preview: 50%)
#pagebreak()


// Test direction
#almost-default-show-example(`#ltr`, dir: ltr)
#pagebreak()
#almost-default-show-example(`#ttb`, dir: ttb)

#pagebreak()

// The auto-shower, see #15

#[
    #show: render-examples
    
    ```example
    #rect(height: 3pt)
    ```
]

#pagebreak()


#[
    #set page(width: auto, height: auto, margin: 0pt)
    #show: render-examples.with(layout: (code, preview) => grid(columns: 2, align: horizon, code, preview))

    ```example
    #rect(height: 3pt)
    ```
]
