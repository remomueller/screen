# Screen

[![Build Status](https://travis-ci.org/remomueller/screen.png?branch=master)](https://travis-ci.org/remomueller/screen)
[![Dependency Status](https://gemnasium.com/remomueller/screen.png)](https://gemnasium.com/remomueller/screen)
[![Code Climate](https://codeclimate.com/github/remomueller/screen.png)](https://codeclimate.com/github/remomueller/screen)

Manage prescreens and call log. Using Rails 4.0+ and Ruby 2.1+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation): Instructions for installing prerequisites like Ruby, Git, JavaScript compiler, etc.

Once you have the prerequisites in place, you can proceed to install bundler which will handle most of the remaining dependencies.

```
gem install bundler
```

This README assumes the following installation directory: /var/www/screen

```
cd /var/www

git clone https://github.com/remomueller/screen.git

cd screen

bundle install
```

Install default configuration files for database connection, email server connection, server url, and application name.

```
ruby lib/initial_setup.rb

bundle exec rake db:migrate RAILS_ENV=production

bundle exec rake assets:precompile RAILS_ENV=production
```

Run Rails Server (or use Apache or nginx)

```
rails s -p80
```

Open a browser and go to: [http://localhost](http://localhost)

All done!

## Setting up Daily Priority Flagging

This will run the task lib/tasks/flag_priority.rake using Cron

```
sudo crontab -e

0 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/screen && /usr/local/rvm/gems/ruby-2.1.1/bin/bundle exec rake flag_priority RAILS_ENV=production
```

## Contributing to Screen

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright [![Creative Commons 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

Copyright (c) 2014 Remo Mueller. See [LICENSE](https://github.com/remomueller/screen/blob/master/LICENSE) for further details.

