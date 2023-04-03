#!/bin/bash
Database="sample"
SQL_QUERY="DESC deqode"
TWILIO_ACCOUNT_SID="AC12106cb17225faa22fbb948b57a094e7"
TWILIO_AUTH_TOKEN="81149750cbea09fba53100dc7cb807dd"
TWILIO_PHONE_NO="+12708187806"
MY_PHONE_NUMBER="+918149349022"
TWILIO_BIN_URL="https://handler.twilio.com/twiml/EH0687c3b5743265541ab81933ef71045d"

sudo mysql -u root -D $Database -e "$SQL_QUERY"

if [ $? == 0 ]; then
    echo "SQL server is running"

else
    echo "SQL server is not running making outbound call"
    curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Calls.json \
    --data-urlencode "Url="$TWILIO_BIN_URL"" \
    --data-urlencode "To="$MY_PHONE_NUMBER"" \
    --data-urlencode "From="$TWILIO_PHONE_NO"" \
    -u $TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN
fi
