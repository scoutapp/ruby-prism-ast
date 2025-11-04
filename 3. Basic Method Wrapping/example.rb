# Basic AST Structure:
# ProgramNode
# └── StatementsNode
#     ├── DefNode (def greet(name))
#     │   ├── parameters:
#     │   │   └── RequiredParameterNode(:name)
#     │   └── body:
#     │       └── StatementsNode
#     │           └── CallNode
#     │               ├── name: :puts
#     │               └── arguments:
#     │                   └── InterpolatedStringNode
#     │                       ├── StringNode: "Hello, "
#     │                       └── EmbeddedStatementsNode
#     │                           └── LocalVariableReadNode(:name)
#     ├── CallNode
#     │   ├── name: :greet
#     │   └── arguments:
#     │       └── StringNode: "world"
#     └── CallNode
#         ├── name: :puts
#         └── arguments:
#             └── StringNode: "Done"

# Expected:
# def greet(name)
#   BlockCaller.yielder('puts') { puts "Hello, #{name}" }
# end

# BlockCaller.yielder('greet') { greet("world") }

# BlockCaller.yielder('puts') { puts "Done" }


def greet(name)
  puts "Hello, #{name}"
end

greet("world")

puts "Done"
