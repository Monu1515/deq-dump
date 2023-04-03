#!/bin/bash
Database="sample"
SQL_QUERY="DESC deqode"
TWILIO_ACCOUNT_SID=""
TWILIO_AUTH_TOKEN=""
TWILIO_PHONE_NO=""
MY_PHONE_NUMBER=""
TWILIO_BIN_URL=""

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
