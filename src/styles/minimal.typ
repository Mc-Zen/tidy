#import "../utilities.typ": *


// Color to highlight function names in
#let fn-color = rgb("#1f2a63")

#let get-type-color(type) = rgb("#eff0f3")


#let show-outline(module-doc) = {
  let prefix = module-doc.label-prefix
  let items = ()
  for fn in module-doc.functions {
    items.push(link(label(prefix + fn.name + "()"), fn.name + "()"))
  }
  list(..items)
}

// Create beautiful, colored type box
#let show-type(type) = { 
  h(2pt)
  box(outset: 2pt, fill: get-type-color(type), radius: 2pt, raw(type))
  h(2pt)
}



#let show-parameter-list(fn, display-type-function) = {
  block(fill: rgb("#d8dbed"), width: 100%, inset: (x: 0.5em, y: 0.7em), {
    set text(font: "Cascadia Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: fn-color)
    "("
    let inline-args = fn.args.len() < 5
    if not inline-args { "\n  " }
    let items = ()
    for (arg-name, info) in fn.args {
      let types 
      if "types" in info {
        types = ": " + info.types.map(x => display-type-function(x)).join(" ")
      }
      items.push(box(arg-name + types))
    }
    items.join( if inline-args {", "} else { ",\n  "})
    if not inline-args { "\n" } + ")"
    if fn.return-types != none {
      " -> " 
      fn.return-types.map(x => display-type-function(x)).join(" ")
    }
  })
}



// Create a parameter description block, containing name, type, description and optionally the default value. 
#let show-parameter-block(
  name, types, content, style-args,
  show-default: false, 
  default: none, 
) = block(
  inset: 0pt, width: 100%,
  breakable: style-args.break-param-descriptions,
  [ 
    #[
      #set text(fill: fn-color)
      #raw(name) 
    ]
    (#h(-.2em)
    #types.map(x => (style-args.style.show-type)(x)).join([ #text("or",size:.6em) ])
    #if show-default [\= #raw(lang: "typc", default) ]
    #h(-.2em)) --
    #content
    
  ]
)


#let show-function(
  fn, style-args,
) = {
  set par(justify: false, hanging-indent: 1em, first-line-indent: 0em)

  block(breakable: style-args.break-param-descriptions, [
    #(style-args.style.show-parameter-list)(fn, style-args.style.show-type)
    #label(style-args.label-prefix + fn.name + "()")
  ])
  pad(x: 0em, eval-docstring(fn.description, style-args))
  [*Parameters:*]

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name, types, eval-docstring(description, style-args), 
      style-args,
      show-default: "default" in info, 
      default: info.at("default", default: none),
    )
  }
  v(4em, weak: true)
}


#let show-reference(label, name, style-args) = {
  link(label, raw(name))
}


#let show-example(
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
          inset: .5em, 
          stroke: .5pt +  fn-color, 
          code, 
        ),
        rect(
          height: height, width: output-width, 
          stroke: .5pt +  fn-color, 
          fill: white,
          box(
            width: output-size.width * output-scale-factor, 
            height: output-size.height * output-scale-factor, 
            scale(origin: top + left, scale-output, output)
          )
        )
        
      ))
      let height = if dir.axis() == "vertical" { auto } 
        else { measure(arrangement(width: size.width), style).height }
      arrangement(height: height)
    })
  })
})
