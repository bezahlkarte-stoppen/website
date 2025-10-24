#!/usr/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

PIDFILE="deploy.pid"

if [ -f "$PIDFILE" ]; then
	MYPID=$(cat "$PIDFILE")

	if ps -p $MYPID > /dev/null 2>&1; then
		echo "Another instance of this process is running. Current log output: "
		echo
		cat deploy.log
		exit 1
	fi
	rm -f "$PIDFILE"
fi

echo $$ > "$PIDFILE"

source .env
export TMPDIR="../tmp"
rm -rf $TMPDIR
mkdir $TMPDIR
cp -r www/* $TMPDIR


PUSH="$WEBROOT/push";
if [ -f "$PUSH" ]; then
	BRANCH="`cat $PUSH`"
	if [ "$BRANCH" == "$GITHUB_BRANCH" ]; then

		exec 3>&1 4>&2
		trap 'exec 2>&4 1>&3' 0 1 2 3
		exec 1> >(tee deploy.log) 2>&1

		#./notify.sh "BZK DEPLOY INVOKE"

		echo "RUN $0"
		echo "PWD `pwd`"

		git checkout $GITHUB_BRANCH
		git pull


		./translate.sh
		if [ $? -ne 0 ]; then
			echo "Translation failed. Skipping deployment.";
			#./notify.sh "BZK DEPLOY TRANSLATION ERROR"
			exit 1
		fi

		#./notify.sh "BZK DEPLOY START"

		echo "Deploy new website..."

		cp -r $WEBROOT ../bak/$(date +%s)
		rm -rf $WEBROOT/*
		cp -r $TMPDIR/* $WEBROOT
		cp ../webhook.php $WEBROOT

		echo "Deploy done.";

		#./notify.sh "BZK DEPLOY END"
	fi
fi
rm -f "$PIDFILE"
