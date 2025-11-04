require "prism"
require "prism/inspect_visitor"
require "pathname"

class BlockCaller
  def self.yielder(name, &block)
    puts "Before call #{name}"
    block.call
    puts "After call #{name}"
  end
end

# --- AST Transformation ------------------------------------------------------

class AstTransform
  def self.parse(source)
    Prism.parse(source).value
  end

  def self.rewrite(ast, source)
    new.rewrite(ast, source)
  end

  def initialize
    @calls = []
    @stack = []
  end

  # Wrap calls in the BlockCaller
  def rewrite(ast, source)
    collect_top_level_calls(ast)

    # Replace from end → start so offsets stay correct when we start to inject/replace
    # the source with our wrapped code.
    @calls.sort_by! { |n| -n.location.start_offset }

    # Transform string into ASCII-8bit as Prism offsets are in bytes.
    bytes = source.b

    @calls.each do |call|
      name = call.name.to_s
      expr = call.location.slice
      wrapped = "BlockCaller.yielder('#{name}') { #{expr} }".b

      bytes[call.location.start_offset...call.location.end_offset] = wrapped
    end

    # RubyVM::InstructionSequence.compile will infer the correct encoding.
    bytes
  end

  private

  def collect_top_level_calls(node)
    return unless node.respond_to?(:child_nodes)

    @stack.push(node)

    node.child_nodes.each do |child|
      next unless child

      if child.is_a?(Prism::CallNode)
        # Only add if not nested inside another call
        @calls << child unless inside_call?
      end

      collect_top_level_calls(child)
    end
    @stack.pop
  end

  def inside_call?
    @stack.any? { |n| n.is_a?(Prism::CallNode) }
  end
end

# --- RubyVM hook -------------------------------------------------------------

module Patch
  module InstructionSequence
    def load_iseq(path)
      file = Pathname(path)
      base = file.basename(file.extname)

      source = File.read(file)
      ast = AstTransform.parse(source)

      # Write AST and transformed source for inspection
      File.write(file.dirname / "#{base}_ast.txt", ast.inspect)
      rewritten = AstTransform.rewrite(ast, source.dup)
      File.write(file.dirname / "#{base}_rewritten.rb", rewritten)

      self.compile_prism(rewritten, path)
    end
  end

  class << RubyVM::InstructionSequence
    prepend InstructionSequence
  end
end
