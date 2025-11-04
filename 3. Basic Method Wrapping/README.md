At its core, instrumentation is just measuring how long something takes to run.

What is ultimately just a simple timing:

```ruby
start_time = Time.now
# do work
end_time = Time.now
puts "Work took #{end_time - start_time}"
```

Can be made a bit more reusable with something as simple:

```ruby
class Timer
  def self.capture
    start_time = Time.now
    yield
    end_time = Time.now
    puts "Capture took #{end_time - start_time}"
  end
end

Timer.capture do
  # do work
end
```

Building on this idea, we can move toward a structure that looks more like a tracing span / layer API that we have here at Scout:

```ruby
ScoutApm::Tracer.instrument("Category", "Subcategory") do
  # do work
end
```

So, to trace code dynamically, our goal is to inject this timing API directly into the source, wrapping each method call in the instrumentation block:

```ruby
def some_work
  # do work
end

ScoutApm::Tracer.instrument("Work", "some_work") do
  some_work
end
```

That's really the crux of it. However, just like many things in life, the devil is in the details. In Ruby, there are [many many ways that calls can be made](https://kddnewton.com/2023/12/13/advent-of-prism-part-13).
