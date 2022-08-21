# BasicCompiler
 
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
