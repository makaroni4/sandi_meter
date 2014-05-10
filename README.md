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
    -d, --details                    CLI mode. Show details (path, line number)
    -g, --graph                      HTML mode. Create folder, log data and output stats to HTML file.
        --json                       Output as JSON
    -l, --log                        Show syntax error and indentation log output
    -p, --path PATH                  Path to folder or file to analyze (default is ".")
    -r, --rules                      Show rules
    -h, --help                       Help

cd ~/your/ruby/or/rails/project
sandi_meter -d

1. 85% of classes are under 100 lines.
2. 45% of methods are under 5 lines.
3. 99% of method calls accepted are less than 4 parameters.
4. 66% of controllers have one instance variable per action.

Classes with 100+ lines
  Class name                 | Size  | Path
  SandiMeter::Analyzer       | 219   | ./lib/sandi_meter/analyzer.rb:7
  SandiMeter::Calculator     | 172   | ./lib/sandi_meter/calculator.rb:2
  SandiMeter::HtmlGenerator  | 135   | ./lib/sandi_meter/html_generator.rb:5
  Valera                     | 109   | ./spec/test_classes/12.rb:1

Misindented classes
  Class name        | Path
  MyApp::TestClass  | ./spec/test_classes/1.rb:2
  OneLinerClass     | ./spec/test_classes/5.rb:1

Methods with 5+ lines
  Class name                          | Method name                   | Size  | Path
  SandiMeter::Analyzer                | initialize                    | 10    | ./lib/sandi_meter/analyzer.rb:10
  SandiMeter::Analyzer                | analyze                       | 13    | ./lib/sandi_meter/analyzer.rb:22

Misindented methods
  Class name        | Method name  | Path
  MyApp::TestClass  | blah         | ./spec/test_classes/1.rb:3

Method calls with 4+ arguments
  # of arguments  | Path
  5               | ./lib/sandi_meter/html_generator.rb:55
  5               | ./lib/sandi_meter/html_generator.rb:71

Controllers with 1+ instance variables
  Controller name         | Action name  | Instance variables
  AnotherUsersController  | index        | @users, @excess_variable
~~~

## HTML mode

Try using gem with `-g (--graph)` option, so it will create a folder with beautiful html output and log file with results of any scan.

![SandiMeter HTML mode pie charts](http://cl.ly/image/1p142M3K1S2x/content)
![SandiMeter HTML mode details](http://cl.ly/image/2R163v283V3Q/content)

Add ignore files and folders in `sandi_meter/.sandi_meter` file.

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
