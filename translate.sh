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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

# Deepl
for l in en tr uk fr es ru; do
	rm -rf www/$l
	mkdir www/$l
	$DEEPL_CLI doc -O html -f de -t $l -o www/$l/index.html www/de/index.html
done

# ChatGPT
for l in ar fa; do
	rm -rf www/$l
	mkdir www/$l
	$CHATGPT_CLI --track-token-usage=false --model=gpt-4o --role-file ./translate.prompt -p www/de/index.html --query "Zielspache: $l" --max-tokens 16384 --context-window 24000  > www/$l/index.html
done
