require 'pp'

insns = RubyVM::InstructionSequence.compile_prism("puts 'HI WORLD'")

pp insns.disassemble

insns.eval
