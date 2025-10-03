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
echo "PWD $(pwd)"
echo "ENV \$CHATGPT_CLI=$CHATGPT_CLI"
echo "ENV \$DEEPL_CLI=$DEEPL_CLI"
echo "TRIES $TRIES"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

# Deepl (currently disabled with `if false`)
error=false
if false; then
for l in en tr uk fr es ru; do
    dst="website/www/$l/index.html"
    for ((i = 1; i <= $TRIES; i++)); do
        echo "[Try $i / $TRIES] Start deepl translation for $l ..."
        rm -rf website/www/$l
        mkdir -p website/www/$l
        $DEEPL_CLI doc -O html -f de -t $l -o $dst website/www/de/index.html
        if [ $? -eq 0 ]; then
            if [ -e "$dst" -a -s "$dst" ]; then
                echo "Done deepl translation for $l"
                break
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

# ChatGPT — recursive translation of all HTML files
error=false
for l in en tr uk fr es ru ar fa; do
    echo "Translating site to $l ..."
    rm -rf website/www/$l
    mkdir -p website/www/$l

    find website/www/de -type f -name "*.html" | while read src; do
        rel="${src#website/www/de/}"
        dst="website/www/$l/$rel"
        mkdir -p "$(dirname "$dst")"

        success=false
        for ((i = 1; i <= $TRIES; i++)); do
            echo "[Try $i / $TRIES] Translating $src → $dst ($l)..."
            $CHATGPT_CLI --temperature=0 --track-token-usage=false \
                --model=gpt-4o \
                --role-file ./translate.prompt \
                -p "$src" \
                --query "Zielsprache: $l" \
                --max-tokens 16384 --context-window 24000 > "$dst"

            if [ $? -eq 0 ]; then
                if [ -s "$dst" ]; then
                    echo "Done ChatGPT translation for $src → $dst"
                    success=true
                    break
                else
                    echo "ERROR: Translated file $dst does not exist or is empty."
                fi
            else
                echo "ERROR: CHATGPT_CLI exited with error."
            fi
        done

        if ! $success; then
            echo "ERROR: No success after $TRIES tries for $src ($l)"
            error=true
            break
        fi
    done

    $error && exit 1
done

echo "DEEPL USAGE:"
$DEEPL_CLI --usage

exit 0
