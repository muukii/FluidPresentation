# FluidPresentation

A view controller that supports the interactive dismissal by edge pan gesture or screen pan gesture from modal presentation.

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

