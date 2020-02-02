#/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

dirName=$1

if [ ! -d $dirName ]
  then
    echo "Directory DOES NOT exists."
    exit 1
fi

VERSION=$(cat $dirName/VERSION)
REGISTRY="marcoamador"

REPO=$(echo $dirName | tr '_' '-')
IMAGE=pipeline-$REPO:$VERSION

docker build --build-arg dir=$dirName -t $IMAGE .
docker tag $IMAGE $REGISTRY/$IMAGE
docker push $REGISTRY/$IMAGE
