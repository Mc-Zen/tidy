#import "@preview/elembic:1.1.1" as e

#let Type = e.element.declare(
  "Type",
  prefix: "tidy",
  display: it => {
    if type(it.type) == type { 
      repr(it.type) 
    } else if it.type.starts-with("\"") { 
      it.type
    }
  },
  fields: (
    e.field("type", e.types.union(type, str), required: true),
  )
)

#let TypeList = e.element.declare(
  "TypeList",
  prefix: "tidy",
  display: it => it.types.join[ | ],
  fields: (
    e.field("types", e.types.array(e.types.union(Type, type, str)), required: true),
  )
)

#let Default = e.element.declare(
  "Default",
  prefix: "tidy",
  display: it => raw(lang: "typc", repr(it.value)),
  fields: (
    e.field("value", e.types.any, required: true),
  )
)


#let ParameterName = e.element.declare(
  "ParameterName",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)

#let Parameter = e.element.declare(
  "Parameter",
  prefix: "tidy",
  display: it => block(stroke: 1pt, inset: .5em, {
    block[
      #box(ParameterName(it.name))
      #h(1em)
      #TypeList(it.type.map(Type))
    ]
    it.description
    if it.named {
      par([Default: #Default(it.default)])
    }
  }),
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("type", array, required: true),
    e.field("default", e.types.any, default: none),
    e.field("named", bool, default: false),
    e.field("sink", bool, default: false)
  )
)

#let FunctionName = e.element.declare(
  "FunctionName",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)

#let SignatureParameter = e.element.declare(
  "SignatureParameter",
  prefix: "tidy",
  display: it => {
    let parameter = e.fields(it.parameter)
    if parameter.at("sink", default: false) [.. ]
    else { parameter.name + [: ] }
    TypeList(parameter.type.map(Type))
  },
  fields: (
    e.field("parameter", Parameter, required: true),
  )
)

#let Signature = e.element.declare(
  "Signature",
  prefix: "tidy",
  display: it => {
    it.name
    [(]
      it.parameters
        .map(SignatureParameter) 
        .join[, ]
    [)]
    if it.type != () [
       -> #it.type-list
    ]
  },
  fields: (
    e.field("name", str, required: true),
    e.field("parameters", e.types.array(Parameter), required: true),
    e.field("type", e.types.array(type), default: ())
  ),
  synthesize: it => {
    it.type-list = TypeList(it.type.map(Type))
    it
  }
)

#let Function = e.element.declare(
  "Function",
  prefix: "tidy",
  display: it => {
    FunctionName(it.name)
    block(it.description)
    it.signature
    it.parameters.join()
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("parameters", e.types.array(Parameter), default: ()),
    e.field("type", e.types.array(type), default: ()),
  ),
  synthesize: it => {
    it.signature = Signature(it.name, it.parameters, type: it.type)
    it.type-list = TypeList(it.type.map(Type))
    it
  }
)

#let Constant = e.element.declare(
  "Constant",
  prefix: "tidy",
  display: it => {
    FunctionName(it.name)
    block(it.description)
    it.type-list
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("type", e.types.array(type), default: ()),
  ),
  synthesize: it => {
    it.type-list = TypeList(it.type.map(Type))
    it
  }
)


#show e.selector(FunctionName): heading.with(level: 2)
#show e.selector(ParameterName): heading.with(level: 3)

  
#show e.selector(TypeList): set text(font: "DejaVu Sans Mono")

#show e.selector(Parameter): it => {
  set text(.8em)
  show e.selector(TypeList): it => e.fields(it).types.join(text(.85em, " or "))
  it
}

#show e.selector(Type): it => {
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

#show e.selector(TypeList): it => {
  e.fields(it).types.join(h(0.35em))
}

#show e.selector(Signature): it => {
  set text(font: "DejaVu Sans Mono", size: 0.8em)
  it
}


#Function(
  "foo", 
  [A real foo. ], 
  parameters: (
    Parameter("bar", [A fake bar. ], (int,), named: true, default: 2),
    Parameter("baz", [Just a baz. ], (bool, str, "yes", "\"x\"")),
    Parameter("bag", [A bag of things. ], (content,), sink: true),
  ),
  type: (int,)
)


#Constant(
  "int-maker", 
  [Makes an int. ], 
  type: (int,)
)


#{
  let a = Parameter("asd", [ASD], (str,))
  e.fields(a) 
}


== Questions
+ Should there be a a way of documenting constants or do we just need functions? The Typst standard library gives us no precedence for documented constants. Things like `std.sys.version` are simply documented in the module documentation of `sys`. However, I think that packages make more use of constants than the standard library and this will be an important feature. In this case, the following question needs to be posed: should functions and constants be unified in one type `definition` or whether they should be separate. They should be separate. 
+ What kind of types should be allowed for type annotations? Of course built-in types like `int`, `bool` are straight-forward. 
  - Shall we allow values as types, like #raw(lang: "typc", "kind: \"x\" | \"y\"")? The documentation of the standard library does not currently use such notation. They would write `kind: str` and mention the possible values in the parameter description. 
  - But should we also allow "custom" types as commonly used by packages like CeTZ which for example defines a type `coordinate`? Sooner or later, with built-in user-defined types, this will be standard procedure but even in this case it is important to think about how store such a value. 