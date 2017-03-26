#!/bin/bash
DATA_PATH=${DATA_PATH:="/osrm-build/data"}

_sig() {
  kill -TERM $child 2>/dev/null
}

if [ "$1" = 'osrm' ]; then
  trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

  if [ ! -f $DATA_PATH/$2.osrm ]; then
    if [ ! -f $DATA_PATH/$2.osm.pbf ]; then
      curl $OSRM_DATA_URL > $DATA_PATH/$2.osm.pbf
    fi
    ./osrm-extract $DATA_PATH/$2.osm.pbf -p profiles/$3
    ./osrm-contract $DATA_PATH/$2.osrm
  fi

  ./osrm-routed $DATA_PATH/$2.osrm --max-table-size 8000 &
  child=$!
  wait "$child"
else
  exec "$@"
fi
