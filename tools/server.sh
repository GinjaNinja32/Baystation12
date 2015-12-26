#! /bin/bash

DME=baystation12 # DME file/BYOND project to compile and run
PORT=5000 # Port to run Dream Daemon on
GIT=false # true, false, or any valid command; return value decides whether git is used
REPO=upstream # Repo to fetch and pull from when updating
BRANCH=dev # Branch to pull when updating

cd ../ # serverdir/

exec 5>&1 # duplicate fd 5 to fd 1 (stdout); this allows us to echo the log during compilation, but also capture it for saving to logs in the case of a failure

setmap() {
	if [[ -e use_map ]]; then
		MAP="$(cat use_map)"
		if [[ ! -e "maps/$MAP/$MAP.dm" ]]; then
			MAP="exodus"
		fi
	else
		MAP="exodus"
	fi
	echo "Setting map: '$MAP'"
	echo "#include \"$MAP/$MAP.dm\"" > maps/use_map.dm
}

echo "Running server..."
DreamDaemon $DME $PORT -trusted &
pid=$!
trap "kill -s SIGTERM $pid" EXIT

[[ -e stopserver ]] && rm stopserver
while [[ ! -e stopserver ]]; do
	while [[ ! -e reboot_called ]] && ps -p $pid > /dev/null; do
		sleep 15
	done
	[[ -e reboot_called ]] && rm reboot_called
	if [[ -e atupdate && -x atupdate ]]; then
		eval "$(cat atupdate)" # in THIS ENVIRONMENT, i.e. branch changes can be done by `echo 'BRANCH=dev-freeze' > atupdate`
		rm atupdate
	fi
	if $GIT; then
		git fetch $REPO
		git checkout $BRANCH && git pull $REPO $BRANCH
	fi
	setmap
	echo "Compiling..."
	DMoutput="$(DreamMaker $DME | tee /dev/fd/5)" # duplicate output to fd 5 (which is redirected to stdout at the top of this script)
	if [[ $? != 0 ]]; then
		d="$(date '+%X %x')"
		echo "Compilation failed; saving log to 'data/logs/compile_failure_$d.txt'!"
		echo $DMoutput > "data/logs/compile_failure_$d.txt"
	else
		echo "Compilation successful."
	fi
	if ! ps -p $pid > /dev/null; then
		DreamDaemon $DME $PORT -trusted &
		pid=$!
		trap "kill -s SIGTERM $pid" EXIT
	else
		kill -s SIGUSR1 $pid # Reboot DD
	fi
done

kill -s SIGTERM $pid
