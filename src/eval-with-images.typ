#import "parse.typ": parse-argument-list, parse-arg-strings

// Find all calls to `image()` in the given code string and return an array
// of objects containing info about
// - the start index of the image call (including the `#` if present)
// - the end index of the image call, pointing to the closing `)`
// - whether the call takes place in code mode (no `#`) or in content mode
// - positional and named args for the `image()` function call
#let find-image-commands(text) = {
  let matches = text.matches("image(")
  let image-commands = ()
  for match in matches {
    let (arg-strings, length) = parse-argument-list(text, match.start + 5)
    let (positional-args, named-args) = parse-arg-strings(arg-strings)
    
    let code-mode = not (match.start > 0 and text.at(match.start - 1) == "#")
    image-commands.push(
      (
        start: match.start - int(not code-mode), 
        end: match.end + length - 2,
        positional-args: positional-args,
        named-args: named-args,
        code-mode: code-mode
      )
    )
  }
  return image-commands
}

// In given code string, replace every `image()` call with a placeholder string
// `%%img0%%` (the number is incremented subsequently). 
#let replace-image-commands(text, image-commands) = {
  let result-text = ""
  let position = 0
  for (index, image-command) in image-commands.enumerate() {
    result-text += text.slice(position, image-command.start)
    let placeholder = "%%img" + str(index) + "%%"
    if image-command.code-mode { placeholder = "[" + placeholder + "]"}
    result-text += placeholder
    position = image-command.end + 1
  }
  return result-text + text.slice(position)
}

// This function `eval()`s the given string and shows images that are to be 
// inserted with the `image()` function. 
//
// `eval()` does not allow access to the file system, so calls to #image()
// do not work. We work around that by identifying all these calls and
// replacing them with some placeholder. We use show rules to show these
// placeholders as the correct images. 
//  - Any number of images is supported
//  - image() amy be called in content or code mode
//  - arguments like `width` for images are respected
#let eval-with-images(text, scope: (:)) = {
  if "image" not in text { return eval(text) }
  
  let image-commands = find-image-commands(text)
  let replaced-text = replace-image-commands(text, image-commands)
  
  show regex("%%img\\d+%%") : it => {
    let index = int(it.text.slice(5, -2))
    let filename = image-commands.at(index).positional-args.at(0)
    image(filename, ..image-commands.at(index).named-args)
  }
  eval(replaced-text)
}