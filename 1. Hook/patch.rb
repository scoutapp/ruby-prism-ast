module Patch
  module InstructionSequence
    def load_iseq(path)
      puts path
      puts "\nFile contents: \n#{File.read(path)} \n"

      puts "Our modified compiled instructions return:"
      self.compile_prism("puts 'HI WORLD'", path)
    end
  end

  class << RubyVM::InstructionSequence
    prepend InstructionSequence
  end
end