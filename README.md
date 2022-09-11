# SkyResolver
A lightweight dependency resolution library.

## Dependency registration
To register your dependencies, use the following command:
``` swift
SkyContainer.shared.register { A() as TestSubject }
```

Be aware that subsequent registration of the same type would lead to an error as a return value. If you wish to overwrite already registered types use the `override` parameter on the `register` method:
``` swift
SkyContainer.shared.register(override: true) {
      B() as TestSubject
    }
```

`register` method returns a `Result<Void, SkyRegistrationError>`, which you can check for the failure of the particular type registration, if any.

## Dependency resolution
Resolving dependencies is similar to registration:
``` swift
let classA: A = try! SkyContainer.shared.resolve()
```

`SkyContainer` is going to automatically resolve the correct type and initialize the class.

It also works with nested dependencies, where a class initializer depends on another class, like this:
``` swift
SkyContainer.shared.register { A() as TestSubject }
SkyContainer.shared.register { B(testSubject: try! SkyContainer.shared.resolve()) }

let classB: B = try! SkyContainer.shared.resolve()
```

`resolve()` might throw a possible error in case some conditions have not been met. Check the error's `failureReason` and `recoverySuggestion` for help.

## Circular dependency resolution
SkyResolver does not support circular initializer dependency resolution. Upon having 
``` swift
SkyContainer.shared.register { Egg(chicken: try! SkyContainer.shared.resolve()) }
SkyContainer.shared.register { Chicken(egg: try! SkyContainer.shared.resolve()) }
```
expect the resolver to throw an error. try structuring your dependencies with another pattern.
