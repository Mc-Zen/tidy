#import "@preview/elembic:1.1.1" as e

#let type = e.element.declare(
  "type",
  prefix: "tidy",
  display: it => {
    if type(it.type) == std.type { // is built-in type
      repr(it.type) 
    } else if it.type.starts-with("\"") { 
      it.type
    } else {
      it.type
    }
  },
  fields: (
    e.field("type", e.types.union(std.type, str), required: true),
  )
)


#let type-list = e.element.declare(
  "type-list",
  prefix: "tidy",
  display: it => it.types.join(it.separator),
  fields: (
    e.field("types", e.types.array(type), required: true),
    e.field("separator", content, default: [ | ]),
  )
)

// to be parameter.default
#let parameter-default = e.element.declare(
  "parameter-default",
  prefix: "tidy",
  display: it => raw(lang: "typc", repr(it.value)),
  fields: (
    e.field("value", e.types.any, required: true),
  )
)

// to be parameter.name
#let parameter-name = e.element.declare(
  "parameter-name",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)

#let parameter = e.element.declare(
  "parameter",
  prefix: "tidy",
  display: it => {
    block[
      #box(parameter-name(it.name))
      #h(1em)
      #type-list(it.type.map(type))
    ]
    it.description
    if it.named {
      par[default: #parameter-default(it.default)]
    }
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("type", array, required: true),
    e.field("default", e.types.any, default: none),
    e.field("named", bool, default: false),
    e.field("sink", bool, default: false)
  )
)


// to be function.name
#let function-name = e.element.declare(
  "function-name",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)

// to be signature.parameter
#let signature-parameter = e.element.declare(
  "signature-parameter",
  prefix: "tidy",
  display: it => {
    let parameter = e.fields(it.parameter)
    if parameter.at("sink", default: false) [..]
    else { parameter.name + [: ] }
    type-list(parameter.type.map(type))
  },
  fields: (
    e.field("parameter", parameter, required: true),
  )
)

#let signature = e.element.declare(
  "signature",
  prefix: "tidy",
  display: it => {
    let inline(pre: none, post: none) = {
      it.name
      [(#pre]
        it.parameters
          .map(signature-parameter,) 
          .join[, #pre]
      [#post)]
      if it.type != () [
        -> #it.type-list
      ]
    }
    let broken = inline.with(pre: [\ ~~], post: [\ ])

    if it.inline == auto {
      layout(size => {
        let inline = inline()
        if measure(inline).width <= size.width {
          inline
        } else {
          broken()
        }
      })
    } else if it.inline {
      inline()
    } else {
      broken()
    }
  },
  fields: (
    e.field("name", str, required: true),
    e.field("parameters", e.types.array(parameter), required: true),
    e.field("type", e.types.array(std.type), default: ()),
    e.field("inline", e.types.union(auto, bool), default: auto)
  ),
  synthesize: it => {
    it.type-list = type-list(it.type.map(type))
    it
  }
)


#let function = e.element.declare(
  "function",
  prefix: "tidy",
  display: it => {
    function-name(it.name)
    par(it.description)
    it.signature
    it.parameters.join()
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("parameters", e.types.array(parameter), default: ()),
    e.field("type", e.types.array(std.type), default: ()),
  ),
  synthesize: it => {
    it.signature = signature(it.name, it.parameters, type: it.type)
    it.type-list = type-list(it.type.map(type))
    it
  }
)

#let constant = e.element.declare(
  "constant",
  prefix: "tidy",
  display: it => {
    function-name(it.name)
    par(it.description)
    it.type-list
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("type", e.types.array(std.type), default: ()),
  ),
  synthesize: it => {
    it.type-list = type-list(it.type.map(type))
    it
  }
)

#let theme-default(body) = {

  show e.selector(function-name): heading.with(level: 2)
  show e.selector(parameter-name): heading.with(level: 3)

    
  show: e.set_(type-list, separator: [ ])
  show: e.set_(signature, inline: false)
  show e.selector(type-list): set text(.9em, font: "DejaVu Sans Mono")

  show e.selector(parameter): it => {
    show: e.set_(type-list, separator: [ or ])
    it
  }
  show e.selector(parameter): block.with(
    width: 100%,
    fill: luma(95%), 
    inset: 1em
  )



  show e.selector(type): it => {
    import "../styles/default.typ": colors
    let type = e.fields(it).type
    if std.type(type) == std.type {
      type = repr(type)
    } 
    
    if type.starts-with("\"") {
      return raw(lang: "typc", type)
    }

    box(
      fill: colors.at(type, default: gray),
      inset: (x: 0.35em), 
      outset: (y: 0.35em), 
      radius: 0.35em, 
      type
    )
  }


  show e.selector(signature): it => {
    set text(font: "DejaVu Sans Mono", size: 0.8em)
    it
  }
  body
}


// #show e.selector(function-name): heading.with(level: 2)
// #show e.selector(parameter-name): heading.with(level: 3)

#show: theme-default

#function(
  "foo", 
  [A real foo. ], 
  parameters: (
    parameter("bar", [A fake bar. ], (int,), named: true, default: 2),
    parameter("baz", [Just a baz. ], (bool, str, "yes", "\"x\"")),
    parameter("bag", [A bag of things. ], (content,), sink: true),
  ),
  type: (int,)
)


#constant(
  "int-maker", 
  [Makes an int. ], 
  type: (int,)
)


#{
  let a = parameter("asd", [ASD], (str,))
  e.fields(a) 
}


== Questions
+ Should there be a a way of documenting constants or do we just need functions? The Typst standard library gives us no precedence for documented constants. Things like `std.sys.version` are simply documented in the module documentation of `sys`. However, I think that packages make more use of constants than the standard library and this will be an important feature. In this case, the following question needs to be posed: should functions and constants be unified in one type `definition` or whether they should be separate. They should be separate. 
+ What kind of types should be allowed for type annotations? Of course built-in types like `int`, `bool` are straight-forward. 
  - Shall we allow values as types, like #raw(lang: "typc", "kind: \"x\" | \"y\"")? The documentation of the standard library does not currently use such notation. They would write `kind: str` and mention the possible values in the parameter description. 
  - But should we also allow "custom" types as commonly used by packages like CeTZ which for example defines a type `coordinate`? Sooner or later, with built-in user-defined types, this will be standard procedure but even in this case it is important to think about how store such a value. 