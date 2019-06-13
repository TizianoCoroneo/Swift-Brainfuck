# Swift-Brainfuck
An experiment in Swift eDSL syntax with @functionBuilder to create a Brainfuck interpreter.

This works by executing a `Program` on a `Tape`.
Currently I'm using full names instead of operators, for the simple reason that Swift wouldn't recognize the operators used in Brainfuck as valid identifiers.
Also, half of the code may be erased once we get variadic generics in Swift, that will allow me to erase all the multiple generic overloads of `TupleOperation` and `buildBlock`.
