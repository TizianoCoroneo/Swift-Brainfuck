# Swift-Brainfuck
An experiment in Swift 5.1 [eDSL syntax](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md) with `@functionBuilder` to create a [Brainfuck](https://github.com/brain-lang/brainfuck/blob/master/brainfuck.md) interpreter.

This works by executing a `Program` on a `Tape`. The program specified in the playground prints "Hello World!" in the console.

Currently I'm using full names instead of operators, for the simple reason that Swift wouldn't recognize the operators used in Brainfuck as valid identifiers.
Also, half of the code may be erased once we get variadic generics in Swift, that will allow me to erase all the multiple generic overloads of `TupleOperation` and `buildBlock`.
