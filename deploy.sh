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


PUSH="/home/www/www011/chroot/data-www011/push";
if [ -f "$PUSH" ]; then
	BRANCH="`cat $PUSH`"
	if [ "$BRANCH" == "main" ]; then

		exec 3>&1 4>&2
		trap 'exec 2>&4 1>&3' 0 1 2 3
		exec 1> >(tee deploy.log) 2>&1

		./notify.sh "BZK DEPLOY INVOKE"

		echo "RUN $0"
		echo "PWD `pwd`"

		rm -rf website/
		git clone https://github.com/bezahlkarte-stoppen/website.git website
		source .env
		./translate.sh
		if [ $? -ne 0 ]; then
			echo "Translation failed. Skipping deployment.";
			./notify.sh "BZK DEPLOY TRANSLATION ERROR"
			exit 1
		fi

		./notify.sh "BZK DEPLOY START"

		echo "Deploy new website..."
		cp -r ../chroot/data-www011 bak/$(date +%s)
		rm -rf ../chroot/data-www011/*
		cp -r website/www/* ../chroot/data-www011
		cp webhook.php ../chroot/data-www011
		echo "Deploy done.";

		./notify.sh "BZK DEPLOY END"
	fi
fi
rm -f "$PIDFILE"
