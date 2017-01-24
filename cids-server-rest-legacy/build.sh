#!/bin/bash

# RELEASE BUILD ----------------------------------------------------------------
# docker build -t cismet/cids-server-rest-legacy:latest -t cismet/cids-server-rest-legacy:4.0 .

# SNAPSHOT BUILD ---------------------------------------------------------------
docker build -t cismet/cids-server-rest-legacy:latest-snapshot -t cismet/cids-server-rest-legacy:4.1-SNAPSHOT .
