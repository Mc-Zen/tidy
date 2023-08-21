
/// Takes given code and both shows it and the result of its evaluation. 
/// 
/// The code is by default shown in the language mode `lang: typc` (typst code)
/// if no language has been specified. Code in typst markup lanugage (`lang: typ`)
/// is automatically evaluated in markup mode. 
/// 
/// - code (raw): Raw object holding the example code. 
/// - scope (dictionary): Additional definitions to make available for the evaluated 
///          example code.
/// - inherited-scope (dictionary): Definitions that are made available to the entire parsed
///          module. This parameter is only used internally.
#let example(
  code, 
  dir: ltr,
  scope: (:),
  ratio: 1,
  scale-output: 80%,
  inherited-scope: (:),
  ..options
) = style(styles => {
  let code = code
  let mode = "code"
  if not code.has("lang") {
    code = raw(code.text, lang: "typc", block: code.block)
  } else if code.lang == "typ" {
    mode = "markup"
  }
  set text(size: .9em)
        
  let output = [#eval(code.text, mode: mode, scope: scope + inherited-scope)]
  
  let spacing = .5em
  let code-width
  let output-width
  
  if dir.axis() == "vertical" {
    code-width = 100%
    output-width = 100%
  } else {
    code-width = ratio / (ratio + 1) * 100% - 0.5 * spacing
    output-width = 100% - code-width - spacing
  }

  let output-scale-factor = scale-output / 100%
  
  layout(size => {
    style(style => {
      let output-size = measure(output, styles)
            
      let arrangement(width: 100%, height: auto) = block(width: width, inset: 0pt, stack(dir: dir, spacing: spacing,
        block(
          width: code-width, 
          height: height,
          radius: 3pt, 
          inset: .5em, 
          stroke: .5pt + luma(200), 
          code, 
        ),
        block(
          height: height, width: output-width, 
          fill: rgb("#e4e5ea"), radius: 3pt,
          inset: .5em,
          rect(
            width: 100%,
            fill: white,
            box(
              width: output-size.width * output-scale-factor, 
              height: output-size.height * output-scale-factor, 
              scale(origin: top + left, scale-output, output)
            )
          )
        )
      ))
      let height = if dir.axis() == "vertical" { auto } 
        else { measure(arrangement(width: size.width), style).height }
      arrangement(height: height)
    })
  })
})
