#!/bin/bash
set -e

/etc/init.d/apache2 start

/etc/init.d/apache2 restart

tail -f /dev/null 
