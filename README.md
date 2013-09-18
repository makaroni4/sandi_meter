# SandiMeter

Static analysis tool for checking your Ruby code for [Sandi Metz' for rules](http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers).

* 100 lines per class
* 5 lines per method
* 4 params per method call (and don't even try cheating with hash params)
* 1 instance variables per controller' action

## CLI mode

~~~
gem install sandi_meter
sandi_meter ~/your/ruby/or/rails/project

1. 94% of classes are under 100 lines.
2. 53% of methods are under 5 lines.
3. 98% of methods calls accepts are less than 4 parameters.
4. 21% of controllers have one instance variable per action.
~~~

## Ruby script mode

~~~ruby
require 'sandi_meter/file_scanner'
require 'pp'

scanner = SandiMeter::FileScanner.new
data = scanner.scan(PATH_TO_PROJECT)
pp data
# {:first_rule=>
#   {:small_classes_amount=>916,
#    :total_classes_amount=>937,
#    :missindented_classes_amount=>1},
#  :second_rule=>
#   {:small_methods_amount=>1144,
#    :total_methods_amount=>1833,
#    :missindented_methods_amount=>0},
#  :third_rule=>{:proper_method_calls=>5857, :total_method_calls=>5894},
#  :fourth_rule=>{:proper_controllers_amount=>17, :total_controllers_amount=>94}}
~~~
