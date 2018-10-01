# Log with text messages
import requests
from requests.auth import HTTPBasicAuth

from os import environ

# TODO retrieve from environment
fr = environ['TEXTLOG_FROM'] if 'TEXTLOG_FROM' in environ else ''
to = environ['TEXTLOG_TO'] if 'TEXTLOG_TO' in environ else ''
account = environ['TEXTLOG_ACCOUNT'] if 'TEXTLOG_ACCOUNT' in environ else ''
token = environ['TEXTLOG_TOKEN'] if 'TEXTLOG_TOKEN' in environ else ''

def textSetup (fr=fr, to=to, account=account, token=token, prefix = ''):
    if fr != '' and to != '' and account != '' and token != '':
        return lambda text: requests.post(f'https://api.twilio.com/2010-04-01/Accounts/{account}/Messages.json',
            data = {
                'To': to,
                'From': fr,
                'Body': prefix + text
            },
            auth=HTTPBasicAuth(account, token)
        )
    else:
        print('Twilio not configured, SMS logging will be no-op')
        return lambda text: None

if __name__ == '__main__':
    fr = input('from> ')
    acc = input('account> ')
    token = input('token> ')
    to = input('to> ')
    txt = textSetup(fr, to, acc, token)
    while True:
        txt(input('msg> '))
