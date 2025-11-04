require "prism"
require "prism/inspect_visitor"
require "pathname"

# Simple wrapper to observe method calls
class BlockCaller
  def self.yielder(name)
    puts "Before call #{name}"
    yield
    puts "After call #{name}"
  end
end

# AST transformer that wraps method calls
class AstTransform
  attr_accessor :calls

  def self.parse(source)
    Prism.parse(source).value
  end

  def self.wrap_all_calls(root, source)
    new.wrap_all_calls(root, source)
  end

  def initialize
    @calls = []
  end

  def wrap_all_calls(root, source)
    collect_call_nodes(root)

    # Replace from end → start so offsets stay correct when we start to inject/replace
    # the source with our wrapped code.
    @calls.sort_by! { |node| -node.location.start_offset }

    # Transform string into ASCII-8bit as Prism offsets are in bytes.
    bytes = source.b

    @calls.each do |call|
      name     = call.name.to_s
      call_src = call.location.slice
      wrapped  = "BlockCaller.yielder('#{name}') { #{call_src} }"
      bytes[call.location.start_offset...call.location.end_offset] = wrapped
    end

    # RubyVM::InstructionSequence.compile will infer the correct encoding.
    bytes
  end

  private

  def collect_call_nodes(node)
    return unless node.respond_to?(:child_nodes)

    node.child_nodes.each do |child|
      next unless child

      @calls << child if child.is_a?(Prism::CallNode) && child.message_loc

      collect_call_nodes(child)
    end
  end
end

# --- RubyVM hook -------------------------------------------------------------

module Patch
  module InstructionSequence
    def load_iseq(path)
      file = Pathname(path)
      base = file.basename(file.extname)

      # Parse source into AST
      source    = File.read(path)
      ast       = AstTransform.parse(source)

      # Wrap all call nodes with BlockCaller
      rewritten = AstTransform.wrap_all_calls(ast, source.dup)

      # Compile the rewritten source
      self.compile_prism(rewritten, path)
    end
  end

  class << RubyVM::InstructionSequence
    prepend InstructionSequence
  end
end
