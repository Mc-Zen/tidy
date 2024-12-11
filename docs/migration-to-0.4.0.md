# Migration guide from 0.3.0 to 0.4.0 (new parser)


If you choose to use the new documentation parser, this guide helps you with migrating your existing documentation to the new documentation syntax. Of course, you can also keep using the old syntax which will still be around for some time. It can be activated via `tidy.parse-module(old-syntax: true, ...)`. 

## Breaking changes

Below you can find an overview over the breaking changes that the new syntax introduces. 

- [Documentation of function arguments](#documentation-of-function-arguments)
- [Cross-references](#cross-references)
- [Example previews](#example-previews) (not strictly a breaking change)
- [Doc-comment tests](#doc-comment-tests)


### Documentation of function arguments

In Tidy 0.3.0 and earlier, function arguments were all documented in a dedicated block that was part of the description doc-comment for the function, see below:
```typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// - x (int, float): The argument for the cardinal sine function. 
/// -> float
#let sinc(x) = if x == 0 {1} else {calc.sin(x) / x}
```

With the new syntax, the parameter description is moved right in front of the parameter declaration. The name of the parameter can thus be removed from the description. The type, however, is now annotated (until Typst provides built-in support for type annotations) just like the return type of the function itself with a trailing `->` expression. Also, multiple accepted types should now be separated with a pipe `|` operator instead of a comma (this also applies to the function return type). 

The previous example thus becomes

```typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// -> float
#let sinc(
  /// The argument for the cardinal sine function. 
  /// -> int | float
  x
) = if x == 0 {1} else {calc.sin(x) / x}
```
Note that the trailing type annotation does not need to be on its own line. 


### Cross-references

In the old documentation style, there was a dedicated syntax for cross-references: the `@@` prefix. The new style uses just plain Typst references starting with a single `@`. In the case of cross-referencing a function, parentheses are never placed after the function name. *This is a breaking change to before when these parentheses were obligatory*. 

In addition, it is now possible to reference a specific parameter of a function by appending a dot `.` and the parameter name, e.g., `sinc.x`. In order to use parameter references, the utilized template style needs to support them by creating appropriate labels for each parameter. The built-in style templates all support parameter referencing out of the box. 


### Example previews

A popular feature of Tidy is the example preview. A function, variable, or parameter description can contain demonstrating code examples that are automatically rendered and displayed side-by-side with the code. This used to be achieved through the `example()` function that Tidy provides since version 0.3.0. 

Although this function is still available, we now encourage users to use a raw element with the language `example` (for Typst markdown mode) or `examplec` (for Typst code mode). 

Thus, instead of 
````typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// #example(`#sinc(0)`, mode: "markup")
..
````
we can now simply write

````typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// ```example
/// #sinc(0)
/// ```
..
````
or
````typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// ```examplec
/// sinc(0)
/// ```
..
````

In all versions, you can insert _hidden_ code lines starting with `>>>` anywhere in the demo code. These lines will just be executed but not displayed. 
````typ
/// ```examplec
/// >>> import my-math: sinc // just executed, not shown
/// sinc(0)
/// ```
````
This is useful for many scenarios like import statements, wrapping everything inside a container of a fixed size and other things.

Look at the [default.typ](/src/styles/default.typ) template style for hints on customization of the example preview. 


## Standalone usage of example previews

Some people use the example preview feature to add self-compiling code examples independently of Tidy. This used to be possible via the following show rule:
````typ
#show raw: show-example.show-example

```typ
Hello world
```
````
With the new version, this should be replaced with 
```typ
#import "@preview/tidy:0.4.0": render-examples
#show: render-examples

...
```

### Scope
It also features a `scope` argument, that can be pre-set:

````typ
#show: render-examples.with(scope: (answer: 42))

```example
#answer
```
````


### Customization
The output format of the example can be customized through the parameter `layout` of `render-examples`. This parameter takes a `function` with two positional arguments: the `raw` element and the preview. 
````typ
#show: render-examples.with(layout: (code, preview) => grid(code, preview))
````

## Doc-comment tests
Doc-comment tests can still be used as before but the short-hand syntax with `>>>` is no longer supported with the new documentation syntax. With `old-parser: true`, it is still available. 