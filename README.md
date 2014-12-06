DASHBOARD ROMANIA
=================

In order to run the site on localhost, you need to install the following tools:
 * coffeescript
 * nodejs
 * libyajl-dev
 * ruby-dev

Create a symbolic link for nodejs:
	ln -s /usr/bin/nodejs /usr/local/bin/node

Also install other packages, by running the following commands:
 * gem install jekyll
 * npm install -g less
 * npm install -g gulp

Run the following command. This will start the web server on localhost:5000.
	gulp devel
