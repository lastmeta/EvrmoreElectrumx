#!/bin/bash
  
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

(
  echo "Updating evrmore"
  cd ./workspace/Evrmore || exit 77
  git pull
  docker build -f ./contrib/Dockerfile -t evrmore:latest . || exit 77
)
(
  echo "Updating electrumx evrmore"
  cd ./workspace/electrumx-evrmore || exit 77
  git reset --hard
  git pull
  latest_tag=`git describe --tags --abbrev=0`
  
  # The dockerfile doesnt have the evrmore dependancy in it for some reason, so we add it here
  match='WORKDIR /home/electrumx/electrumx-evrmore-\${VERSION}'
  insert='RUN echo "evrhash @ git+https://github.com/EvrmoreOrg/cpp-evrprogpow@master" >> ./requirements.txt'
  sed -i "s|$match|$match\n$insert|" ./contrib/Dockerfile || exit 77

  # And we need the csv file for some reason
  match='RUN python3 setup.py install'
  insert='RUN mv ./electrumx/airdropindexes.csv /home/electrumx'
  sed -i "s|$match|$match\n$insert|" ./contrib/Dockerfile || exit 77

  docker build --build-arg="VERSION=${latest_tag:1}" -f ./contrib/Dockerfile -t electrumx-evrmore:latest . || exit 77
)
