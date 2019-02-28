#!/usr/bin/env bash

# Script to start the icecast server
# and start butt with diffrent configurations
# --------------------------------------------

# start the butt
/Applications/Icecast/butt/butt.app/Contents/MacOS/butt -c /Users/Vog/.buttrc1 &

/Applications/Icecast/butt/butt.app/Contents/MacOS/butt -c /Users/Vog/.buttrc2 &

/Applications/Icecast/butt/butt.app/Contents/MacOS/butt -c /Users/Vog/.buttrc3 &

/Applications/Icecast/butt/butt.app/Contents/MacOS/butt -c /Users/Vog/.buttrc4 &