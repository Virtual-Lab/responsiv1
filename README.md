# responsive1

This is a version of a performance with SuperCollider and mobilephones 
It uses a rhizome server (based on node.js) and javascript
parameters of sound are mapped to visuals

This is a test application

Instructions

    install cloudspeaker and maincomputer (which is running supercollider and the rhizome server)
    connect them to a local network (best with lan, also works with wlan)
    load the supercollider patch in the supercolider IDE
    look up ip-adresses of the cloudspeaker and modify the ~ip variable in supercollider
    start the rhizome server (it needs nodejs Version 6, see intructions below)
    boot the server in supercollider IDE and evaluate the file (e.g. on Mac: CMD-B, CMD-A, CMD-)
    connect to the webpage (running on http://localhost:8000 or http://ip-adress-of-your-computer:8000) with a mobile phone, tablet or computer in the same network
    also works over internet, if the server is running the rhizome server and the ports which are configurated the config.js are open

How to start the rhizome application:

    install node.js and npm (It needs node Version 6) it is the best opportunity to install it with nvm:
    https://github.com/creationix/nvm

    install nvm with terminal
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

    or Wget:

    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

    install node 6 and use it:

    nvm install 6 nvm use 6

    You can also download an installer directly from Node.js website.

    Install rhizome

    Open a terminal, and simply run 
    npm install -g rhizome-server
    
    If this succeeded, you can try to run rhizome. This should print rhizome help message.

    To start the server, open your terminal, go to the example folder and run `rhizome config.js`. This should start the server and print an extract of the configuration.

    To open the web page (websocket client), just go to [http://localhost:8000/index.html](http://localhost:8000/index.html).

    All the code for the web page is in [pages/index.html](pages/index.html) 


