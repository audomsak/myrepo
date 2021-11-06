#!/bin/sh

for i in {1..10}; do
  concurrent=`expr $i \* 100`

  echo "============================================================================================"
  echo "Concurrent: $concurrent"
  echo "============================================================================================"

  echo "--------------------------------------------------------------------------------------------"
  
  for j in {1..10}; do
    echo "Round: $j"
    echo "--------------------------------------------------------------------------------------------"
    group=`expr $concurrent + $j`
    
    ./hey -n 10000 -c $concurrent -m POST -D "json-schema.json" -T "application/json" -H "artifactType: JSON" http://my-registry-service:8080/apis/registry/v2/groups/$group/artifacts

    sleep 30
    echo "--------------------------------------------------------------------------------------------"  
  done;
done;
