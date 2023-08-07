
# Tidy
*Keep it tidy.*

[![Tests](https://github.com/Mc-Zen/tidy/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/tidy/actions/workflows/run_tests.yml)

**tidy** is a package that generates documentation directly in [Typst](https://typst.app/) for your Typst modules. It parses docstring comments similar to javadoc and co. and can be used to easily build a beautiful reference section for the parsed module.  

Within the docstring you may use any Typst syntax - so markup, equations and even figures are no problem!

Features:
- Customizable output styles. 
- Call you own module's code within the docstring, e.g., to render examples. 
- Annotate types of parameters and return values.
- Automatically read off default values for named parameters.


The [documentation](./docs/tidy-guide.pdf) describes the usage of this module and the defined format for the docstrings. 

## Usage

```java
#import "@preview/tidy:0.1.0"
#let module = tidy.parse-module("my-module.typ")
#tidy.show-module(module, style: tidy.styles.default)
```

## Example

A full example on how to use this module for your own package (maybe even consisting of multiple files) can be found at [examples](./examples/).

Feed **tidy** your in-code documented source files and get beautiful documentation of all your functions printed out. Enjoy features like type annotations, links to other documented functions and arbitrary formatting within function and parameter descriptions. Let's get started.

You can document your functions similar to javadoc by prepending a block of `///` comments. 


```java
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

**tidy** turns this into:

![](docs/images/my-module-docs.svg)
