## Class Method Wrapping

For most Ruby code, a file typically contains a single module or class, possibly with nested modules, classes, and their methods. This pattern is especially common in Rails controllers — the exact scenario the AutoInstruments feature targets.

It's at this point where we start to see the complexities of the AST start to build. As such, we should really be writing out the AST of the file that we are parsing, as well as the rewritten version of it to verify that we are indeed creating the correct source, with our intended instrumentation wrappings.

In fact, we start to see some of this right as we go and try and instrument a something like:
```ruby
Testclass.new.greet
```

If we use the `patch.rb` from the previous section we end up with something like:
```ruby
BlockCaller.yielder('new') { TestClass.new("Hello, world") }{ TestClass.new("Hello, world").greet }
```

I don't think that's what we want. In fact, what do we want? Do we want a wrapper around `greet` or `new` or both. If we look at the AST, we see that `.new` is a receiver / child node of `.greet`. As such, we may want to not to instruments nodes whose parent are currently being instrumented. How can we do that? Prism is unidirection tree and a node doesn't store references to its parents. As such, we need to manually keep track of these relationships either via a hashmap or something like a stack. 

For this case, we are going to use a stack as we just need to know about the current node's parent(s), and whether we have seen another CallNode. Once we are done processing the node, and if it is a CallNode, we will pop it off the stack. This ensures sibling CallNodes are instrumented only if none of their ancestors were instrumented.

This way we end up with the correct instrumentation:
```ruby
BlockCaller.yielder('greet') { TestClass.new("Hello, world").greet }
```

When it comes to parsing the AST and injecting / rewriting the source, a lot of it is handling various cases on how particular methods can be called, and the various ways that these nodes & method calls are related to one another.

