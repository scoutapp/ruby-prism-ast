class TestClass
  def initialize(message)
    @message = message
  end

  def greet
    BlockCaller.yielder('puts') { puts @message }
  end
end

BlockCaller.yielder('greet') { TestClass.new("Hello, world").greet }