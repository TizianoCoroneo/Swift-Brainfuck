//: [Previous](@previous)

import Foundation

var str = "Hello, brainfuck"

/// The tape of the Turing machine. Holds cell and the machine cursor's current position.
struct Tape {
    /// Contents of the whole tape. Using a dictionary instead of an array to allow for negative indices.
    var content: [Int: UInt8] = [0: 0]
    /// Current position of the cursor.
    var index: Int = 0

    /// Utility to get the value of the cell currently pointed by the cursor.
    var currentCell: UInt8 {
        get { content[index]! }
        set { content[index] = newValue }
    }
}

/// An operation that you can execute on the machine.
/// May be `MoveLeft`, `MoveRight`, `Increment`, `Decrement`, `Output`, `Jump` or `NoOp`.
protocol Operation {
    func apply(_ tape: inout Tape)
}

/// An operation that does nothing.
struct NoOp: Operation {
    func apply(_ tape: inout Tape) {}
}

/// Moves the cursor to the next cell, or to multiple locations forward in case `amount` is provided.
/// It also instantiates a new cell with the default value of `0` in case the cursor visits a new index.
/// In case the index goes over `Int.max`, the program will halt.
struct MoveRight: Operation {
    let amount: Int

    init(_ amount: Int = 1) {
        self.amount = amount
    }

    func apply(_ tape: inout Tape) {
        tape.index += amount
        if !tape.content.keys.contains(tape.index) {
            tape.currentCell = 0
        }
    }
}

/// Moves the cursor to the previous cell, or to multiple locations back in case `amount` is provided.
/// It also instantiates a new cell with the default value of `0` in case the cursor visits a new index.
/// In case the index goes under `Int.min`, the program will halt.
struct MoveLeft: Operation {
    let amount: Int

    init(_ amount: Int = 1) {
        self.amount = amount
    }

    func apply(_ tape: inout Tape) {
        tape.index -= amount
        if !tape.content.keys.contains(tape.index) {
            tape.currentCell = 0
        }
    }
}

/// Adds `amount` to the value of the current cell and updates its value.
/// In case the value goes over `UInt8.max`, the value will overflow and start back from `0`.
struct Increment: Operation {
    let amount: UInt8

    init(_ amount: Int = 1) {
        self.amount = UInt8(amount)
    }

    func apply(_ tape: inout Tape) {
        var value = tape.currentCell
        value = value &+ amount
        tape.currentCell = value
    }
}

/// Subtracts `amount` to the value of the current cell and updates its value.
/// In case the value goes under `0`, the value will overflow and start back from `UInt8.max`.
struct Decrement: Operation {
    let amount: UInt8

    init(_ amount: Int = 1) {
        self.amount = UInt8(amount)
    }

    func apply(_ tape: inout Tape) {
        var value = tape.currentCell
        value = value &- amount
        tape.currentCell = value
    }
}

/// Prints the value of the current cell, interpreting its `Int` value as a `ascii` character.
struct Output: Operation {
    func apply(_ tape: inout Tape) {
        let asciiBytes: [UInt8] = [tape.currentCell]
        let s = String(bytes: asciiBytes, encoding: .ascii)!
        print(s, separator: "", terminator: "")
    }
}

/// Utility operation to allow subgrouping of operations. On `apply`, applies the grouped operation.
/// This operation does not add anything to the behavior of the program: it is simply needed as a workaround for the lack of variadic generics in Swift.
/// Since I cannot write infinite overloads of `TupleOperation` and `buildBlock` each with a different number of generic parameters,
/// I can use the `Group` operation to logically group related operation in blocks of 10 or less (because I wrote 10 overloads).
struct Group<A: Operation>: Operation {
    let op: A

    init(@BFBuilder _ operations: () -> A) {
        self.op = operations()
    }

    func apply(_ tape: inout Tape) {
        op.apply(&tape)
    }
}

/// Jump operation to change the order in which instructions are executed: it works as both the `[` and `]` operations in classic brainfuck.
/// On `apply`, it first checks if the current cell is `0`. If it is, it "skips" all the operations cointained in its `init` closure. Otherwise, execute the operations inside the `init` closure: this behavior is logically equivalent to the `[` operation.
/// Then it applies the logic for the `]` operator: if the current cell is _not_ `0`, it jumps back at the matching `[` operation, which is equivalent to recursively calling the `Jump.apply` method.
struct Jump<Op: Operation>: Operation {
    let contained: Op

    init(@BFBuilder _ operation: () -> Op) {
        self.contained = operation()
    }

    func apply(_ tape: inout Tape) {
        // If the current cell is 0 when `[` is encountered...
        if tape.currentCell == 0 {
            // Jump to the closing instruction `]`.
            // If the current cell is NOT 0 when `]` is encountered...
            if tape.currentCell != 0 {
                // Jump back to the opening instruction `[`.
                self.apply(&tape)
            }
            // If the current cell is NOT 0 when `[` is encountered...
        } else {
            // Execute the "contained" operations.
            contained.apply(&tape)
            // If the current cell is NOT 0 when `]` is encountered...
            if tape.currentCell != 0 {
                // Jump back to the opening instruction `[`.
                self.apply(&tape)
            }
        }
    }
}

/// Utility operation to build a generic tuple of operations. On `apply`, applies all the operations in the tuple in order one after the other.
/// This operation has an overload for each different number of generic type variables, up to 10. It does not add anything else to the behavior of the program, if not the logic for sequential execution
/// Once variadic generics are implemented in Swift, I can remove all these overloads for a single definition.
struct TupleOperation<A: Operation, B: Operation>: Operation {
    var a: A
    var b: B

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
    }
}

struct TupleOperation3<A: Operation, B: Operation, C: Operation>: Operation {
    var a: A
    var b: B
    var c: C

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
    }
}

struct TupleOperation4<A: Operation, B: Operation, C: Operation, D: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
    }
}

struct TupleOperation5<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
    }
}

struct TupleOperation6<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E
    var f: F

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
        f.apply(&tape)
    }
}

struct TupleOperation7<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E
    var f: F
    var g: G

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
        f.apply(&tape)
        g.apply(&tape)
    }
}

struct TupleOperation8<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E
    var f: F
    var g: G
    var h: H

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
        f.apply(&tape)
        g.apply(&tape)
        h.apply(&tape)
    }
}

struct TupleOperation9<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation, I: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E
    var f: F
    var g: G
    var h: H
    var i: I

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
        f.apply(&tape)
        g.apply(&tape)
        h.apply(&tape)
        i.apply(&tape)
    }
}

struct TupleOperation10<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation, I: Operation, J: Operation>: Operation {
    var a: A
    var b: B
    var c: C
    var d: D
    var e: E
    var f: F
    var g: G
    var h: H
    var i: I
    var j: J

    func apply(_ tape: inout Tape) {
        a.apply(&tape)
        b.apply(&tape)
        c.apply(&tape)
        d.apply(&tape)
        e.apply(&tape)
        f.apply(&tape)
        g.apply(&tape)
        h.apply(&tape)
        i.apply(&tape)
        j.apply(&tape)
    }
}

/// The actual implementation of the `functionBuilder` attribute.
/// It simply provides 10 overloads of `buildBlock`, to account for a different number of different operations in the `@BFBuilder` scope.
@_functionBuilder
struct BFBuilder {
    static func buildBlock<F: Operation>(_ op: F) -> some Operation {
        op
    }

    static func buildBlock<A: Operation, B: Operation>(_ opA: A, _ opB: B) -> some Operation {
        TupleOperation(a: opA, b: opB)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation>(_ opA: A, _ opB: B, _ opC: C) -> some Operation {
        TupleOperation3(a: opA, b: opB, c: opC)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D) -> some Operation {
        TupleOperation4(a: opA, b: opB, c: opC, d: opD)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E) -> some Operation {
        TupleOperation5(a: opA, b: opB, c: opC, d: opD, e: opE)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E, _ opF: F) -> some Operation {
        TupleOperation6(a: opA, b: opB, c: opC, d: opD, e: opE, f: opF)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E, _ opF: F, _ opG: G) -> some Operation {
        TupleOperation7(a: opA, b: opB, c: opC, d: opD, e: opE, f: opF, g: opG)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E, _ opF: F, _ opG: G, _ opH: H) -> some Operation {
        TupleOperation8(a: opA, b: opB, c: opC, d: opD, e: opE, f: opF, g: opG, h: opH)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation, I: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E, _ opF: F, _ opG: G, _ opH: H, _ opI: I) -> some Operation {
        TupleOperation9(a: opA, b: opB, c: opC, d: opD, e: opE, f: opF, g: opG, h: opH, i: opI)
    }

    static func buildBlock<A: Operation, B: Operation, C: Operation, D: Operation, E: Operation, F: Operation, G: Operation, H: Operation, I: Operation, J: Operation>(_ opA: A, _ opB: B, _ opC: C, _ opD: D, _ opE: E, _ opF: F, _ opG: G, _ opH: H, _ opI: I, _ opJ: J) -> some Operation {
        TupleOperation10(a: opA, b: opB, c: opC, d: opD, e: opE, f: opF, g: opG, h: opH, i: opI, j: opJ)
    }
}


typealias Program = Group

let program = Program {
    Group {
        Increment(8)
        Jump {
            MoveRight()
            Increment(4)
            Jump {
                MoveRight()
                Increment(2)
                MoveRight()
                Increment(3)
                MoveRight()
                Increment(3)
                MoveRight()
                Increment(1)
                MoveLeft(4)
                Decrement()
            }
            Group {
                Group {
                    MoveRight()
                    Increment()
                    MoveRight()
                    Increment()
                    MoveRight()
                    Decrement()
                    MoveRight(2)
                    Increment()
                }

                Jump {
                    MoveLeft()
                }

                MoveLeft()
                Decrement()
            }
        }
    }
    Group {
        Group {
            MoveRight(2)
            Output()
        }
        Group {
            MoveRight()
            Decrement(3)
            Output()
        }
        Group {
            Increment(7)
            Output()
            Output()
            Increment(3)
            Output()
        }
        Group {
            MoveRight(2)
            Output()
        }
        Group {
            MoveLeft()
            Decrement()
            Output()
        }
        Group {
            MoveLeft()
            Output()
        }
        Group {
            Increment(3)
            Output()
            Decrement(6)
            Output()
            Decrement(8)
            Output()
        }
        Group {
            MoveRight(2)
            Increment()
            Output()

            MoveRight()
            Increment(2)
            Output()
        }
    }
}


var testTape = Tape()
program.apply(&testTape)



