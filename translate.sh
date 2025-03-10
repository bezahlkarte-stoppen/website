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


# Deepl
for l in en tr uk fr es ru; do
	rm www/$l/index.html
	deepl doc -O html -f de -t $l -o www/$l/index.html www/de/index.html
done

# ChatGPT
for l in ar fa; do
	rm www/$l/index.html
	echo 'Übersetze diese HTML Datei in die Sprache: '"$l"' - Verändere dabei nicht die Struktur des HTML, belasse den Text in HTML Tags mit Attribut translate="no" im Original. Gib ausschließlich das HTML zurück. Benutze kein Markdown für die Ausgabe' | chatgpt -m gpt-4o -n -c www/de/index.html > www/$l/index.html
done