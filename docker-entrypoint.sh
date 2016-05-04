#!/bin/bash

chown -R yapdnsui:yapdnsui /data
exec node /app/yapdnsui/bin/www
