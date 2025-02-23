#!/bin/bash
VERSION=$(./gradlew properties -q | grep "version:" | awk '{print $2}')
./gradlew clean build
docker build --build-arg VERSION=$VERSION -t cicd-application:$VERSION . 