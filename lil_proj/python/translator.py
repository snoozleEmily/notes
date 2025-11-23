import requests

def translate(text, target='es', source='auto'):
    r = requests.post('https://libretranslate.de/translate',
                      data={'q': text, 'source': source, 'target': target, 'format': 'text'})
    return r.json()['translatedText']

print(translate("Hello world", target='pt')) 
