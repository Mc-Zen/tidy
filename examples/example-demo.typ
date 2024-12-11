/// #set text(size: .9em) 
/// ```/// #example(`#example-demo.flashy[We like our code flashy]`)```
///  #example(`#example-demo.flashy[We like our code flashy]`)
/// ```/// #example(`#example-demo.flashy[Large previews will be scaled automatically to fit]`)```
///  #example(`#example-demo.flashy[Large previews will be scaled automatically to fit]`)
/// ```/// #example(`#example-demo.flashy[Change code to preview ratio]`, ratio: 2)```
///  #example(`#example-demo.flashy[Change code to preview ratio]`, ratio: 2)
///  ```/// #example(`#example-demo.flashy(map: color.map.vlag)[Huge preview]`, scale-preview: 200%)```
///  #example(`#example-demo.flashy(map: color.map.vlag)[Huge preview]`, scale-preview: 200%)
///  ```/// #example(`#flashy[Add to scope]`, scope: (flashy: example-demo.flashy, i: 2))```
///  #example(`#flashy[Add to scope #i ...]`, scope: (flashy: example-demo.flashy, i: 2))
///
/// \
///
///  ```/// #example(`Markup *mode*`, mode: "markup")```
///  #example(`Markup *mode*`, mode: "markup")
///  ```/// #example(`e^(i phi) = -1`, mode: "math")```
///  #example(`e^(i phi) = -1`, mode: "math")
///
/// \
///
///  ```/// #example(`#example-demo.flashy(map: color.map.crest)[Very extremely long examples might maybe require the need of vertical layouting]`, dir: ttb)```
///  #example(`#example-demo.flashy(map: color.map.crest)[Very extremely long examples might maybe require the need of vertical layouting]`, dir: ttb)
///
/// -> content
#let flashy(
    /// -> content
    body, 
    /// -> array 
    map: color.map.spectral
) = highlight(
    body, fill: gradient.linear(..map)
)