# SandiMeter

Static analysis tool for checking your Ruby code for [Sandi Metz' for rules](http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers).

* 100 lines per class
* 5 lines per method
* 4 params per method call (and don't even try cheating with hash params)
* 2 instance variables per controller' action

## As simple as

~~~
gem install sandi_meter
sandi_meter ~/your/ruby/or/rails/project
~~~
