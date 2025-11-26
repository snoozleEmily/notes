import requests

LANGUAGES = ["pt", "es", "fr", "de", "it"]

def translate(text, lang_index=1, source='auto'):
    target = LANGUAGES[lang_index]

    r = requests.post(
        'https://libretranslate.de/translate',
        data={
            'q': text,
            'source': source,
            'target': target,
            'format': 'text'
        }
    )

    raw = r.text  
    key = '"translatedText":"'
    start = raw.find(key) + len(key)
    end = raw.find('"', start)
    return raw[start:end]

print(translate("Hello world", lang_index=1))
