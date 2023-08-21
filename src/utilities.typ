
// Matches docstring references of the form `@@otherfunc` or `@@otherfunc()`. 
#let reference-matcher = regex(`@@([\w\d\-_\)\(]+)`.text)


/// Take a documentation string (for example a function or parameter 
/// description) and process docstring cross-references (starting with `@@`), 
/// turning them into links. 
///
/// - text (string): Source code.
/// - parse-info (dictionary): 
#let process-function-references(text, parse-info) = {
  return text.replace(reference-matcher, info => {
    let target = info.captures.at(0).trim(")").trim("(")
    return "#link(label(\"" + parse-info.label-prefix + target + "()\"))[tidy-ref-" + target + "()]"
    // let l = label(parse-info.label-prefix + target)
    // return "#show-reference(label(\"" + parse-info.label-prefix + target + "()\"), \"" + target + "()\")"
  })
}



/// Evaluate a docstring description (i.e., a function or parameter description)
/// while processing cross-references (@@...) and providing the scope to the 
/// evaluation context. 
///
/// - docstring (string): Docstring to evaluate. 
/// - parse-info (dictionary): Object holding information for cross-reference 
///        processing and evaluation scope. 
#let eval-docstring(docstring, parse-info) = {
  let scope = parse-info.scope
  let content = process-function-references(docstring.trim(), parse-info)
  eval(content, mode: "markup", scope: scope)
}