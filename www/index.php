<?php

// Define the supported languages
$supported_languages = [
    'de' => 'de/',
    'en' => 'en/',
    'ar' => 'ar/',
    'fa' => 'fa/',
    'tr' => 'tr/',
    'uk' => 'uk/',
    'fr' => 'fr/',
    'es' => 'es/',
    'ru' => 'ru/'
];

// Function to detect the preferred browser language
function getPreferredLanguage($available_languages, $default = 'de') {
    if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
        $langs = explode(',', $_SERVER['HTTP_ACCEPT_LANGUAGE']);
        foreach ($langs as $lang) {
            $lang = substr($lang, 0, 2);
            if (in_array($lang, array_keys($available_languages))) {
                return $lang;
            }
        }
    }
    return $default;
}

// Detect the preferred language
$language = getPreferredLanguage($supported_languages);

// Redirect to the corresponding language page
header('Location: ' . $supported_languages[$language]);
exit();

?>
