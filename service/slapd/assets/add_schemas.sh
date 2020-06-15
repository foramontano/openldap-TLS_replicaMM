#!/bin/bash -e
set -o pipefail
PWD=`pwd`

function is_new_schema() {
    local COUNT=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config cn | grep -c "}$1,")
    if [ "$COUNT" -eq 0 ]; then
      echo 1
    else
      echo 0
    fi
  }

# convert schemas to ldif
SCHEMAS=""
for f in $(find schema -name \*.schema -type f|sort); do
	echo ${f}
	if [[ ${f} == *"rfc2307bis.schema"* ]]; then
		echo  "Ya se ha tratado el fichero rfc2307bis.schema"]
		continue
	fi

	SCHEMAS="$SCHEMAS $PWD/${f}"
done

$PWD/schema-to-ldif.sh "$SCHEMAS"

# add converted schemas
for f in $(find schema -name \*.ldif -type f|sort); do
	log-helper debug "Processing file ${f}"
	# add schema if not already exists
	SCHEMA=$(basename "${f}" .ldif)
	echo $SCHEMA
	ADD_SCHEMA=$(is_new_schema $SCHEMA)
	if [ "$ADD_SCHEMA" -eq 1 ]; then
	  ldapadd -c -Y EXTERNAL -Q -H ldapi:/// -f $f 2>&1 | log-helper debug
	else
	  log-helper info "schema ${f} already exists"
	fi
done
rm -r schema/*
