require 'prism'

OLD_NAME = "greeting"
NEW_NAME = "greet"

# --- AST Transformation ------------------------------------------------------

class SwapMethodNames
  def self.swap_greeting_for_greet(path)
    source                   = File.read(path) 
    program_root_ast_node    = Prism.parse(source).value
    statements_root_ast_node = program_root_ast_node.compact_child_nodes.first
    
    # Find the method definition node that matches "greeting"
    def_node = statements_root_ast_node.compact_child_nodes.find do |node|
      node.is_a?(Prism::DefNode) && node.name == OLD_NAME.to_sym
    end

    # Replace the method name in the source string with 'greet'
    loc = def_node.name_loc

    # Transform string into ASCII-8bit as Prism offsets are in bytes.
    bytes = source.b
    bytes[loc.start_offset...loc.end_offset] = NEW_NAME

    # RubyVM::InstructionSequence.compile will infer the correct encoding.
    bytes
  end
end

# --- RubyVM hook -------------------------------------------------------------

module Patch
  module InstructionSequence
    def load_iseq(path)
      rewritten_source = SwapMethodNames.swap_greeting_for_greet(path)

      RubyVM::InstructionSequence.compile(rewritten_source, path)
    end
  end

  class << RubyVM::InstructionSequence
    prepend InstructionSequence
  end
end
