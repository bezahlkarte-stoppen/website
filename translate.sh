#!/bin/bash


# de Deutsch
# en English
# ar اَللُّغَةُ اَلْعَرَبِيَّة
# fa زبان فارسی
# tr Türkçe
# uk українська
# fr français
# es español
# ru русский язык

TRIES=3

echo "RUN $0"
echo "PWD `pwd`"
echo "ENV \$CHATGPT_CLI=$CHATGPT_CLI"
echo "ENV \$DEEPL_CLI=$CHATGPT_CLI"
echo "TRIES $TRIES"


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit


# Deepl
error=false
if false; then
for l in en tr uk fr es ru; do
	dst="website/www/$l/index.html"
	for ((i = 1; i <= $TRIES; i++)); do
		echo "[Try $i / $TRIES] Start deepl translation for $l ..."
		rm -rf website/www/$l
		mkdir website/www/$l
		$DEEPL_CLI doc -O html -f de -t $l -o $dst website/www/de/index.html
		if [ $? -eq 0 ]; then
			if [ -e "$dst"  -a -s "$dst" ]; then
				echo "Done deepl translation for $l"
				break;
			else
				echo "ERROR: Translated file $dst does not exist or is empty."
				error=true
			fi
		else
			echo "ERROR: DEEPL_CLI exited with error."
			error=true
		fi
	done

	$error && echo "ERROR: No success after $TRIES tries" && exit 1
done
fi

# ChatGPT
error=false
for l in en tr uk fr es ru ar fa; do
	dst="website/www/$l/index.html"
	for ((i = 1; i <= $TRIES; i++)); do
		echo "[Try $i / $TRIES] Start ChatGPT translation for $l ..."
		rm -rf website/www/$l
		mkdir website/www/$l
		$CHATGPT_CLI --temperature=0 --track-token-usage=false --model=gpt-4o --role-file ./translate.prompt -p website/www/de/index.html --query "Zielspache: $l" --max-tokens 16384 --context-window 24000  > $dst
		if [ $? -eq 0 ]; then
			if [ -e "$dst"  -a -s "$dst" ]; then
				echo "Done ChatGPT tanslation for $l"
				break;
			else
				echo "ERROR: Translated file $dst does not exist or is empty."
				error=true
			fi
		else
			echo "ERROR: CHATGPT_CLI exited with error."
			error=true
		fi
	done

	$error && echo "ERROR: No success after $TRIES tries" && exit 1
done

echo "DEEPL USAGE:"
$DEEPL_CLI --usage

exit 0
