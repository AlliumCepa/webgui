# AlliumCepa Admin Interface Unoficial

In the abscense of a good/natural Perl CMS system that is OpenSource I decided to give this another look and possibly revive this CMS.

There are NO guarantees that this project will be supported.  As a matter of fact the project may be used as inspiration to write a similar version in [Perl6](https://perl6.org).

### Tech

The developers use a variety of resources to support this project:

* [Docker &copy;](https://www.docker.com) - Docker resources
* [AlliumCepa](https://github.com/AlliumCepa/webgui) - Content Management System
* [MariaDB &copy;](https://mariadb.org) - MariaDB
* [Netbeans &copy;](https://netbeans.org) - Netbeans (Developer IDE)
* [Netbeans Perl Plugin](http://plugins.netbeans.org/plugin/36183/perl-on-netbeans) - Netbeans Perl Plugin
* [React](https://reactjs.org) - React, JavaScript Framework
* [Redux](https://redux.js.org) - Redux, A predictable state container for JavaScript apps
* [React Final Form] - Form management the React way (https://final-form.org/docs/react-final-form)
* [Git](https://git-scm.com) - Git, version control system 

### Installation
Start the Docker Engine in your local environemt

```sh
$ git clone https://github.com/AlliumCepa/webgui.git
$ cd webgui
$ docker build -t webgui:local .
$ docker-compose up
```

Verify the deployment by navigating to your systems local address in your preferred browser.

```sh
http://localhost
```

### Development

If you want to contribute to the new Admin interface you can skip the installation part and just follow these instructions:

Start the backend test rest server (https://github.com/typicode/json-server) 
```
cd WebGUI/www/developer/admin
json-server -p 3001 --watch database/users.json
```
This will start the REST service on http://localhost:3001/

Start the interface test environment in a separate window
```
cd WebGUI/www/developer/admin
npm start
```
Use your browser to view the interface at http://localhost:3000/

To deploy the software to a live website simply invoke the buid script: ./buildAndDeploy.sh
Once complete you can access the "deployed" sofware at:  http://localhost/extras/Kestrel/index.html

Want to contribute? Great!
Contact https://github.com/AlliumCepa/webgui 

**Free Software, Hell Yeah!**
