#import "@preview/elembic:1.1.1" as e


Todo: 
- Be able to get namespace, e.g., to use it in signature: `asd.foo` and also for nested definitions. 


#let namespace = e.element.declare(
  "namespace",
  prefix: "tidy",
  display: it => {
    it.namespace
  },
  fields: (
    e.field("namespace", e.types.wrap(str, fold: _ => (a, b) => if b.starts-with(".") { a + b.trim(".", at: start) } else { b }), default: ""),
  )
)

// #namespace()\
// #show: e.set_(namespace, namespace: "asd")
// #namespace()\
// #show: e.set_(namespace, namespace: ".kjh")
// #namespace()\


/// An atomic annotation expression. This can be
/// - a type like `int`, `bool`, `module`, or
/// - a value like `top`, `2`, or `"bounds"`. 
#let annotation-expr = e.element.declare(
  "annotation-expr",
  prefix: "tidy",
  display: it => {
    repr(it.type)
  },
  fields: (
    e.field("type", e.types.any, required: true),
  ),
)

/// An annotation for a parameter or return value, consisting of 
/// a list of possible annotation expressions. 
#let annotation = e.element.declare(
  "annotation",
  prefix: "tidy",
  display: it => it.types.join(it.separator),
  fields: (
    e.field("types", e.types.array(annotation-expr), required: true),
    e.field("separator", content, default: [ | ]),
  )
)



// (to be parameter.name)
/// The name of a function or type parameter
#let parameter-name = e.element.declare(
  "parameter-name",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)


// (to be parameter.default)
/// A default value for a function or type parameter. 
#let parameter-default = e.element.declare(
  "parameter-default",
  prefix: "tidy",
  display: it => it.supplement + repr(it.value),
  fields: (
    e.field("value", e.types.any, required: true),
    e.field("supplement", content, default: [Default: ]),
  )
)

/// A function or type parameter. 
#let parameter = e.element.declare(
  "parameter",
  prefix: "tidy",
  display: it => {
    block[
      #box(parameter-name(it.name))
      #h(1em)
      #annotation(it.type.map(annotation-expr))
    ]
    it.description
    if it.named {
      par(parameter-default(it.default))
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


// (to be function.name or definition-name)
/// The name of a function, constant, or type. 
#let function-name = e.element.declare(
  "function-name",
  prefix: "tidy",
  display: it => it.name,
  fields: (
    e.field("name", str, required: true),
  )
)

// (to be signature.parameter)
/// A parameter in a function or type signature. 
#let signature-parameter = e.element.declare(
  "signature-parameter",
  prefix: "tidy",
  display: it => {
    let parameter = e.fields(it.parameter)
    if parameter.at("sink", default: false) [..]
    else { parameter.name + [: ] }
    annotation(parameter.type.map(annotation-expr))
  },
  fields: (
    e.field("parameter", parameter, required: true),
  )
)

/// Represents a signature of a function or type, summarizing 
/// the name, all parameters, and their type annotations. 
#let signature = e.element.declare(
  "signature",
  prefix: "tidy",
  display: it => {
    let inline(pre: none, post: none) = {
      namespace() + it.name
      [(#pre]
        it.parameters
          .map(signature-parameter,) 
          .join[, #pre]
      [#post)]
      if it.type != () [
        -> #it.annotation
      ]
    }
    let broken = inline.with(pre: [\ ~~], post: [\ ])
    if it.inline == true or it.parameters.len() == 0 {
      inline()
    } else if it.inline == auto {
      layout(size => {
        let inline = inline()
        if measure(inline).width <= size.width {
          inline
        } else {
          broken()
        }
      })
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
    it.annotation = annotation(it.type.map(annotation-expr))
    it
  }
)

/// Represents the full documentation of a function. 
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
    e.field("contextual", bool, default: false),
    e.field("type", e.types.array(std.type), default: ()),
  ),
  synthesize: it => {
    it.signature = signature(it.name, it.parameters, type: it.type)
    it.annotation = annotation(it.type.map(annotation-expr))
    it
  }
)

/// Represents the full documentation of a constant (or variable 
/// but Typst packages effectively only expose constants).  
#let constant = e.element.declare(
  "constant",
  prefix: "tidy",
  display: it => {
    function-name(it.name)
    par(it.description)
    it.annotation
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("type", e.types.array(std.type), default: ()),
  ),
  synthesize: it => {
    it.annotation = annotation(it.type.map(annotation-expr))
    it
  }
)


/// Represents the full documentation of a type. 
#let type = e.element.declare(
  "type",
  prefix: "tidy",
  display: it => {
    function-name(it.name)
    par(it.description)
    it.signature
    it.parameters.join()
    it.members
      .map(member => {
        if e.eid(member) == e.eid(function) {
          show: e.set_(namespace, namespace: "self.")
          member
        } else {
          show: e.set_(namespace, namespace: "." + it.name + ".")
          member
        }
      })
      .join()
  },
  fields: (
    e.field("name", str, required: true),
    e.field("description", content, required: true),
    e.field("parameters", e.types.array(parameter), default: ()),
    e.field("members", e.types.array(e.types.union(function, e.types.any/*type*/)), default: ()),
  ),
  synthesize: it => {
    it.signature = signature(it.name, it.parameters, type: (content,))
    it
  }
)

#let theme-default(body) = {

  show e.selector(function-name): heading.with(level: 2)
  show e.selector(parameter-name): heading.with(level: 3)

    
  show: e.set_(annotation, separator: h(0.3em))
  show: e.set_(signature, inline: false)

  show e.selector(parameter): it => {
    show: e.set_(annotation, separator: [ #text(.7em)[or] ])
    it
  }
  show e.selector(parameter): block.with(
    width: 100%,
    fill: luma(96%), 
    inset: 1em
  )

  show e.selector(parameter-default): it => {
    it = e.fields(it)
    it.supplement + raw(lang: "typc", repr(it.value))
  }

  show e.selector(annotation-expr): it => {
    import "../styles/default.typ": colors
    let type = e.fields(it).type
    if std.type(type) == std.type {
      type = repr(type)
    } else {
      return raw(lang: "typc", repr(type))
    }
    

    box(
      fill: colors.at(type, default: gray),
      inset: (x: 0.35em), 
      outset: (y: 0.35em), 
      radius: 0.35em, 
      raw(lang: none, type)
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
#show: e.set_(namespace, namespace: "tidy.")

#function(
  "foonction", 
  [A real foonction. ], 
  parameters: (
    parameter("bar", [A fake bar. ], (int,), named: true, default: 2),
    parameter("baz", [Just a baz. ], (bool, str, "yes", 2)),
    parameter("bag", [A bag of things. ], (content,), sink: true),
  ),
  type: (int,)
)


#constant(
  "coonstant", 
  [Is an int. ], 
  type: (int,)
)

#type(
  "entry", 
  [Represents an entry line in an outline.], 
  parameters: (
    parameter("level", [The level of the entry. ], (int,)),
    parameter("element", [The element this entry refers to. ], (content,)),
  ),
  members: (
    function(
      "indented",
      [A helper function for. ],
      type: (content,),
      parameters: (
        parameter("prefix", [The prefix is aligned... ], ("none", content)),
        parameter("inner", [The formatted inner content of the entry.], (content,)),
        parameter("gap", [The gap between the prefix and the inner content.], (length,), named: true, default: 0.5em),
      )
    ),
    type(
      "body",
      "Description",
      parameters: (
        parameter("level", [The level of the entry. ], (int,)),
        parameter("element", [The element this entry refers to. ], (content,)),
      ),
      members: (
        function(
          "convert",
          [A helper function for. ],
          type: (content,),
          parameters: (
            parameter("converter", [How to convert.], (std.function,), named: true, default: int),
          )
        ),
      )
    ),
  )
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