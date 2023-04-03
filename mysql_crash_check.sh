#!/bin/bash

DB_HOST="rds.com"
DB_PASSWORD="qwerty"
DB_USER="root"
fail_attempt="2"
connection_timeout="30" #secounds
t_id="AC1fcf23e090d2712072206432fa72d26f"
t_pass="8848420ac19caf4b6ea076832fed7b52"
from_no="+19036239957"
to_no="+919604869671"

function check_db(){

	###query db
	mysql -u $DB_USER --password=$DB_PASSWORD -h $DB_HOST flaskapi -e "select('test database')" --connect-timeout=$connection_timeout

}


while [ 1 ]
do

	counter=0	

	###call method to check fb connection
	check_db
	ret="$?"

	if [ "$ret" == "1" ]; then	

		for (( i=1;i<=$fail_attempt;i++ ))
		do

			check_db
			ret="$?"
			if [ "$ret" == "1" ]; then

				###increment fail counter
				counter=$(($counter+$i))
				echo $counter
			else
				echo "db working"
				break
			fi
		done

		if [ "$counter" == "3" ]; then
			echo "db crash"
			###notify admin using phone call
			curl -X POST https://api.twilio.com/2010-04-01/Accounts/$t_id/Calls.json \
			--data-urlencode "Url=http://demo.twilio.com/docs/voice.xml" \
			--data-urlencode "To=$to_no" \
			--data-urlencode "From=$from_no" \
			-u $t_id:$t_pass

		fi
	else
		echo "db not crash"	

	fi

	break
done
