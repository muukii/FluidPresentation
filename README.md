# FluidPresentation

A view controller that supports the interactive dismissal by edge pan gesture or screen pan gesture from modal presentation.

| | |
|---|---|
|![CleanShot 2021-04-24 at 00 26 38](https://user-images.githubusercontent.com/1888355/115894190-f2778900-a493-11eb-8795-3dcaddc6f380.gif)|![CleanShot 2021-04-24 at 00 26 14](https://user-images.githubusercontent.com/1888355/115894209-f7d4d380-a493-11eb-89a7-fad3eddf0433.gif)|


## Motivation - what about UINavigationController?

### View Controller would be presented in push and modal.

Against the small application, a big application abolutely have a tons of transitions between view controllers.  
In addition, the view controller migth be presented in navigation controller or modal presentation.  
Which means that should support the both of presentations.

And also `self.navigationController?.push` is not safe operation. (under the dependencies the context.)

### What about Coordinator pattern?

Coordinator-pattern's purpose is solving those problems from complex transitions.
However, even this pattern, it's hard to manage pushing and presenting view controller corresponding to the context.

### So, FluidPresentation stop us to use `push`.

WIP

## License

FluidPresentation is released under the MIT license.

