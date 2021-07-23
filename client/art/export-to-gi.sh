#!/usr/bin/bash
lime build html5 -debug
sudo rm -rf /var/www/gi/fnf/nightly
sudo mv export/debug/html5/bin /var/www/gi/fnf/nightly
echo 'built and moved to fnf.general-infinity.tech/nightly'