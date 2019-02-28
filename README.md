# responsive1

This is a version of a performance with SuperCollider and mobilephones 
It uses a rhizome server (based on node.js) and javascript
parameters of sound are mapped to visuals

This is a test application - also in development

the shell scripts start_stream.sh starts an icecast server to stream audio content in the network
icecast needs to be installed, could be installed with homebrrew in the terminal

<code>brew install icecast</code>

needs some configuration in the configuration file to fit your needs.
Also see: http://icecast.org/

the shell script startbutt starts the "butt" application on a mac which servers the icecast server
It can take any input from the soundcard or the output of any application
also see: https://danielnoethen.de/

Instructions

    install cloudspeaker and maincomputer (which is running supercollider and the rhizome server)
    connect them to a local network (best with lan, also works with wlan)
    load the supercollider patch in the supercolider IDE
    evaluate the file (e.g. on Mac: CMD-B, CMD-A, CMD-RETURN)
    connect to the webpage (running on http://localhost:8000 or http://ip-adress-of-your-computer:8000) with a mobile phone, tablet or computer in the same network
    also works over internet, if the server is running the rhizome server and the ports which are configurated the config.js are open

How to start the rhizome application:

    install node.js and npm (It needs node Version 6) it is the best opportunity to install it with nvm:
    https://github.com/creationix/nvm

    install nvm with terminal
    <code>curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash</code>

    or Wget:

    <code>wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash</code>

    install node 6 and use it:

    <code>nvm install 6</code>
	<code>nvm use 6</code>

    You can also download an installer directly from Node.js website.

    Install rhizome

    Open a terminal, and simply run 
    <code>npm install -g rhizome-server</code>
    
    If this succeeded, you can try to run rhizome. This should print rhizome help message.

    To start the server, open your terminal, go to the example folder and run `rhizome config.js`. This should start the server and print an extract of the configuration.

    To open the web page (websocket client), just go to [http://localhost:8000/index.html](http://localhost:8000/index.html).

    All the code for the web page is in [pages/index.html](pages/index.html) 


