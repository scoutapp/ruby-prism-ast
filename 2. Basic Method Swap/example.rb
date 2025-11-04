# Basic AST Structure:
# ProgramNode
# └── StatementsNode
#     ├── DefNode
#     │   ├── name: :greeting
#     │   └── body:
#     │       └── StatementsNode
#     │           └── CallNode
#     │               ├── name: :puts
#     │               └── arguments:
#     │                   └── StringNode: "Hello World"
#     └── CallNode
#         └── name: :greet

# Expected:
# def greet
#   puts "Hello World"
# end

# greet


def greeting
  puts "Hello World"
end

greet
