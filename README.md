# BasicCompiler

A compiler with very basic capabilities written in Swift. This project is not intended for real-world use; it's implemented just for fun.

The desired language syntax is described in the following EBNF:

```
prg               = prgHeader varDefs "begin" statementSeq "end" "."
prgHeader         = "program" identifier ";"
varDefs           = [ "var" varSeq { varSeq } ]
varSeq            = identifier { "," identifier } : type ";"
type              = "integer" | "string"
statementSeq      = { ( simpleAssignment | complexAssignment) ";" }
simpleAssignment  = identifier ":=" operand ";"
complexAssignment = identifier ":=" operand mathOP operand ";"
operand           = identifier | number
mathOp            = "+" | "-"
```

## Prerequisites
* Install the lates version of Swift. Please follow the [instructions](https://www.swift.org/getting-started/#installing-swift).
* Install the lates version of Make. Please follow the [instructions](https://www.gnu.org/software/make/)
* Install the lates version of Ubuntu. Please follow the [instructions](https://ubuntu.com/download/desktop/)

## Instructions
1) Download or clone the project.
2) Go to the root folder and run ```cd Sources```.
3) Run ```make build``` to build the compiler.
4) Run ```make run``` to run the compiler.

Your compiled program will exit with a status code equal to your last assignment.


## Build-time error handling
`BasicCompiler` is capable of handling all the errors mentioned below by providing user-readable messages:

* Parser errors
    * When the lexeme exceeds the predefined max lexeme length, with additional info (```line, offset```)
    * When a string literal is not closed, with additional info (```line, offset```)
    * When an unsupported symbol appears, with additional info (```line, offset, unupported_symbol```)
    * When an invalid lexeme is detected, with additional info (```line, offset, invalid_lexeme```)

* Compiler errors
    * When expected to find the end of the program but found another token instead, with additional info (```unexpected_token```)
    * When expected to find a token but found the end of the program
    * When an unexpected (wrong) token has been found, with additional info (```unexpected_token```)
    * When a variable is declared more than once, with additional info (```variable_name```)
    * When trying to use a variable without declaring it, with additional info (```variable_name```)
    * When trying to assign a variable with a wrong type, with additional info (```expected_type, given_type```)
    * When trying to use an unsupported type, with additional info (```unsupported_type```)
    * When trying to use an uninitialized variable, with additional info (```variable_name```)

* File errors
    * When the source file is not provided
    * When the provided source file doesn't exist
    * When the provided source file can't be read
    * When the output file can't be written

* Other errors
    * All other errors, with auto-generated messages


## Optimizations
If both operands of the ```complexAssignment``` are literals, the value will be calculated at build-time, and the result will be assigned as ```simpleAssignment```.

## Disclaimer
Alternatively, generate the assembly file ```swift run BasicCompiler $(INPUT_FILE)``` then compile and run it using an [online IDE](https://www.jdoodle.com/compile-assembler-gcc-online/) to check the results.
