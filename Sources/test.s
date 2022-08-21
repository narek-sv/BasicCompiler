# set program name to: test


# start data segment
.data

# declare variable with name: a, and type: integer
.comm a, 8

# declare variable with name: b, and type: integer
.comm b, 8

# declare variable with name: c, and type: integer
.comm c, 8

# start code segment
.text
.globl main
main:

# do simple assignment on variable: a with literal: int(42)
movq $42, a

# do simple assignment on variable: b with value: a
movq a, %rax
movq %rax, b

# do complex assignment on variable: b with: a, +, int(5)
movq a, %rax
movq $5, %rbx
add %rbx, %rax
movq %rax, b

# do complex assignment on variable: b with: int(5), +, a
movq $5, %rax
movq a, %rbx
add %rbx, %rax
movq %rax, b

# do complex assignment on variable: c with: int(135), -, int(9)
movq $126, c

# do complex assignment on variable: c with: c, -, b
movq c, %rax
movq b, %rbx
sub %rbx, %rax
movq %rax, c

# end
mov $60, %rax
mov c, %rdi
syscall
