#! /bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../

fail=0

for k in maps/*; do
	map=${k#maps/}
	if [[ -e maps/$map/$map.dm ]]; then
		echo "Testing map '$map'..."
		./scripts/dm.sh -M$map baystation12.dme
		if [[ $? != 0 ]]; then
			fail=$((fail+1))
		fi
	fi
done

exit $fail
