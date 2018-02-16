#!/bin/bash

if [[ $DEFAULT_BRANCH == "" ]]; then
    export DEFAULT_BRANCH=cmd-develop
fi

GOPATH=$HOME/go

clone() {
    echo "cloning dp repositories"

    mkdir -p $GOPATH/src/github.com/ONSdigital

    cloneGoRepo "dp-code-list-api" $DEFAULT_BRANCH
    cloneGoRepo "dp-dataset-api" $DEFAULT_BRANCH
    cloneGoRepo "dp-dataset-exporter" $DEFAULT_BRANCH
    cloneGoRepo "dp-dimension-extractor" $DEFAULT_BRANCH
    cloneGoRepo "dp-dimension-importer" $DEFAULT_BRANCH
    cloneGoRepo "dp-filter-api" $DEFAULT_BRANCH
    cloneGoRepo "dp-frontend-dataset-controller" $DEFAULT_BRANCH
    cloneGoRepo "dp-frontend-filter-dataset-controller" $DEFAULT_BRANCH
    cloneGoRepo "dp-frontend-renderer" $DEFAULT_BRANCH
    cloneGoRepo "dp-frontend-router" $DEFAULT_BRANCH
    cloneGoRepo "dp-hierarchy-api" $DEFAULT_BRANCH
    cloneGoRepo "dp-import-api" $DEFAULT_BRANCH
    cloneGoRepo "dp-import-tracker" $DEFAULT_BRANCH
    cloneGoRepo "dp-observation-extractor" $DEFAULT_BRANCH
    cloneGoRepo "dp-observation-importer" $DEFAULT_BRANCH
    cloneGoRepo "dp-recipe-api" $DEFAULT_BRANCH
    cloneGoRepo "florence" $DEFAULT_BRANCH
    cloneGoRepo "dp-hierarchy-builder" $DEFAULT_BRANCH
    cloneGoRepo "dp-search-builder" $DEFAULT_BRANCH
    cloneGoRepo "dp-search-api" $DEFAULT_BRANCH

    cloneRepo "babbage" $DEFAULT_BRANCH
    cloneRepo "zebedee" $DEFAULT_BRANCH
    cloneRepo "dp-compose" "master"
    cloneRepo "sixteens" $DEFAULT_BRANCH
    cloneRepo "dp-dataset-exporter-xlsx" $DEFAULT_BRANCH
    cloneRepo "dp-web-tests" $DEFAULT_BRANCH
}

cloneGoRepo() {
    if [ -d "$GOPATH/src/github.com/ONSdigital/$1" ]; then
        echo "$1 already cloned... skipping"
    else
        git clone -b $2 git@github.com:ONSdigital/$1.git $GOPATH/src/github.com/ONSdigital/$1
    fi
}

cloneRepo() {
    if [ -d "$HOME/$1" ]; then
        echo "$1 already cloned... skipping"
    else
        git clone -b $2 git@github.com:ONSdigital/$1.git $HOME/$1
    fi
}

copyFiles() {
    cp -r $HOME/dp-web-tests/features test/
    cp -r $HOME/dp-web-tests/page_objects test/
    cp -r $HOME/dp-web-tests/step_definitions test/
    cp -r $HOME/dp-web-tests/support test/
    cp -r $HOME/dp-web-tests/testdata test/
    cp -r $HOME/dp-web-tests/testdump test/
    cp $HOME/dp-web-tests/create-html-report.js test/
}

removeFiles() {
    rm -rf test/features
    rm -rf test/page_objects
    rm -rf test/step_definitions
    rm -rf test/support
    rm -rf test/testdata
    rm -rf test/testdump
    rm -rf test/create-html-report.js
}

stopContainers() {
    docker-compose -f docker-compose-stores.yml stop
    docker-compose -f docker-compose-backend-apps.yml stop
    docker-compose -f docker-compose-legacy-apps.yml stop
    docker-compose -f docker-compose-frontend-apps.yml stop
    docker-compose -f docker-compose-web-tests.yml stop hub chrome firefox
}

startContainers() {
    docker-compose -f docker-compose-stores.yml up -d

    sleep 20

    docker-compose -f docker-compose-backend-apps.yml up -d
    docker-compose -f docker-compose-legacy-apps.yml up -d
    docker-compose -f docker-compose-frontend-apps.yml up -d
}

buildAndRun() {
    ./bin/build
    docker-compose -f docker-compose-web-tests.yml up -d hub chrome firefox
    # wait for zebedee to start (can take a long time)
    sleep 80
    # change florence password to match acceptance tests
    curl -v -X POST -d '{"email":"florence@magicroundabout.ons.gov.uk","password":"one two three four","oldPassword":"Doug4l"}' http://localhost:8082/password
    ./bin/test
}

removeFiles
 
clone
copyFiles

stopContainers
startContainers

# wait for apps to start
sleep 50

buildAndRun

stopContainers
removeFiles


