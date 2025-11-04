class TestClass
  def initialize(message)
    @message = message
  end

  def greet
    puts @message
  end
end

TestClass.new("Hello, world").greet