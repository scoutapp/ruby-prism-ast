There are many ways we could transform Ruby source code, but before diving into adding automatic instrumentation, let’s start with something simpler — renaming a method.

Let’s say we want to modify the `example.rb` so that the call to greet works even though the method is actually defined as greeting.

When we parse the file with Prism, the root of the Abstract Syntax Tree (AST) is a `ProgramNode`, which contains a `StatementsNode`. Since the AST is a unidirectional tree, we can recursively traverse its children — from `ProgramNode` → `StatementsNode` → `DefNode` — until we find the DefNode for the method we want to rename (greeting). See the [Advent of Prism](https://kddnewton.com/2023/11/30/advent-of-prism-part-0.html) for more on the Prism AST structure.

Once we’ve found that node, Prism gives us the location of the method name within the source. With that, we can overwrite that portion of the source string with the new name (greet).

Note: Because Prism’s Location offsets are measured in bytes, we’ll need to set the source string’s encoding to ASCII-8BIT (using `String#b`).
This avoids index errors that can occur if non-UTF-8 characters (like those in comments or string literals) shift the byte offsets.

Now, if we run the unpatched file:

```bash
ruby -r ./example.rb -e 'exit'
```

We’ll get an error:

```ruby
undefined local variable or method 'greet'
```

But when we require our patch first (which rewrites the method name before compilation) we get:

```bash
ruby -r ./patch.rb -r ./example.rb -e 'exit'
Hello World
```
