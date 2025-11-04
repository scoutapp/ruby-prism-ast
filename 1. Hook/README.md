To dynamically add instrumentation to Ruby code, we can intercept the moment Ruby loads and compiles a file — such as during a require.
Using RubyVM::InstructionSequence.load_iseq, we can hook into this process, modify the source code before it’s compiled, and return the updated instruction sequence.

```ruby
module Patch
  module InstructionSequence
    def load_iseq(path)
      # Return the path/file’s altered source's instruction sequence
      self.compile_file_prism(transform_file_source(path))

      # Normally this would just be:
      # self.compile_file_prism(path)
    end
  end

  class << RubyVM::InstructionSequence
    prepend InstructionSequence
  end
end
```

For example, if we look at patch.rb. If we run:

```bash
ruby -r ./example.rb -e 'exit'
```

We get:

```bash
HELLO WORLD
```

If we run:

```bash
ruby -r ./patch.rb -r ./example.rb -e 'exit'
```

We see that we should get `HELLO WORLD`, but we tell it to compile `HI WORLD` instead in `patch.rb`.

