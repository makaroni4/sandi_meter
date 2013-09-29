# SandiMeter
[![Build Status](https://travis-ci.org/makaroni4/sandi_meter.png?branch=master)](https://travis-ci.org/makaroni4/sandi_meter)
[![Gem Version](https://badge.fury.io/rb/sandi_meter.png)](http://badge.fury.io/rb/sandi_meter)

Static analysis tool for checking your Ruby code for [Sandi Metz' four rules](http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers).

* 100 lines per class
* 5 lines per method
* 4 params per method call (and don't even try cheating with hash params)
* 1 instance variables per controller' action

## CLI mode

~~~
gem install sandi_meter

sandi_meter --help
-g, --graph                      Create folder and log data to graph
-l, --log                        Show syntax error and indentation log output
-p, --path PATH                  Path to folder or file to analyze
-r, --rules                      Show rules
-h, --help                       Help

sandi_meter -p ~/your/ruby/or/rails/project

1. 94% of classes are under 100 lines.
2. 53% of methods are under 5 lines.
3. 98% of methods calls accepts are less than 4 parameters.
4. 21% of controllers have one instance variable per action.
~~~

## HTML mode

Try using gem with `-g (--graph)` option, so it will create a folder with beautiful html output and log file with results of any scan.

![SandiMeter HTML mode](http://img545.imageshack.us/img545/5601/t8qk.png)

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
#    :misindented_classes_amount=>1},
#  :second_rule=>
#   {:small_methods_amount=>1144,
#    :total_methods_amount=>1833,
#    :misindented_methods_amount=>0},
#  :third_rule=>{:proper_method_calls=>5857, :total_method_calls=>5894},
#  :fourth_rule=>{:proper_controllers_amount=>17, :total_controllers_amount=>94}}
~~~
