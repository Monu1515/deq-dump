#!/bin/bash
###log file dir
basename=$(basename -- "$0")
logfile="/tmp/$basename.log"

echo "*************" >> $logfile
date >> $logfile
endpoint="$1"
index_name="$2"


if [[ ! -z "$endpoint" && ! -z "$index_name" ]]; then

    current_date=$(date +"%Y%m")
    echo "Current Year and Month : $current_date" >> $logfile

    ## to fetch existing indices in elastic search
    existing_index=$(curl -s -X GET "$endpoint"/_cat/indices? | grep -i $index_name | awk '{ print $3 }' | awk -F '-' '{ print $3 }' > /tmp/existing_indices.out )

    latest_index_in_elastic_search=$( cat /tmp/existing_indices.out | sort -r /tmp/existing_indices.out | sed -n '1p')

    index_to_be_deleted=$( cat /tmp/existing_indices.out | sort /tmp/existing_indices.out | sed -n '1p')

    new_index="$index_name-$current_date"
    delete_index="$index_name-$index_to_be_deleted"

    ###define REST APIs methods
    put="PUT"
    post="POST"
    del="DELETE"

    ###Form Payload for REST APIs
    put_payload='{
        "settings": {
            "index":{
                "number_of_shards": 31,
                "number_of_replicas": 1,
                "refresh_interval": "15s"
            }
        }
    }'

    ###remove old alias & add new alias payload
    post_payload1='{
        "actions": [{
            "add":{
             "index": "'${index_name}'-'${current_date}'",
             "is_write_index": true,
             "alias": "'${index_name}'"
            }
        },
        {
            "add":{
                "index": "'${index_name}'-'${latest_index_in_elastic_search}'",
                "is_write_index": false,
                "alias": "'${index_name}'"
            }
        }
        ]
    }'
    
    manage_index()
    {
        method="$1"
        current_index="$2"
        payload="$3"
        output="$4"
        endpoint="$5"

        response=$( curl -s -X "$method" "$endpoint"/"$current_index" -H "Content-Type: application/json" -d "$payload" --write-out "%{http_code}" -o "$output" )
        echo $response

    }

    operate_index()
    {
        method="$1"
        current_index="$2"
        output="$3"
        endpoint="$4"

        response=$( curl -s -X "$method" "$endpoint"/"$current_index" --write-out "%{http_code}" -o "$output")
        echo $response
    }


    ### checking indices count already present in elastic search
    index_count=$(curl -s -X GET "$endpoint"/_cat/indices? | grep -iwc "$index_name" )
    if [[ "$index_count" -lt 3 ]];then

        #create a new index
        put_response_code=$(manage_index "$put" "$new_index" "$put_payload" "/tmp/put_response.out" "$endpoint")
        if [[ "$put_response_code" -eq 200 ]]; then
            echo "index $new_index created successfully" >> $logfile

            ##updated aliases
            post_response_code1=$(manage_index "$post" "_aliases" "$post_payload1" "/tmp/post_response.out" "$endpoint")

            if [[ "$post_response_code1" -eq 200 ]]; then
                echo "is_write_index value updated for latest index" >> $logfile
            else   
                echo "is_write_index not updated for latest index"  >> $logfile
                exit
            fi
        else
            echo "index $new_index creation failed " >> $logfile
            exit
        fi
        
    else

        ###create a new index
        put_response_code=$(manage_index "$put" "$new_index" "$put_payload" "/tmp/put_response.out" "$endpoint")
        if [[ "$put_response_code" -eq 200 ]]; then

            echo "index $new_index created successfully" >> $logfile

            ##update asiases
            post_response_code2=$(manage_index "$post" "_aliases" "$post_payload1" "/tmp/post_response.out" "$endpoint")
            if [[ "$post_response_code2" -eq 200 ]]; then
                echo "is_write_index value updated for new index" >> $logfile

                ###delete older index
                del_response_code=$(operate_index "$del" "$delete_index" "/tmp/del_response.out" "$endpoint")
                if [[ "$del_response_code" -eq 200 ]]; then
                    echo "'$delete_index' deleted successfully" >> $logfile
                else
                    echo "fail '$delete_index'to delete " >> $logfile
                    exit
                fi
            else
                echo "is_write_index not updated for latest index"  >> $logfile
                exit
            fi

        else
            echo "index $new_index creation failed " >> $logfile
            exit
        fi

    fi

    ###remove tmp files
    rm -f /tmp/put_response.out /tmp/get_response.out /tmp/post_response.out /tmp/del_response.out /tmp/existing_indices.out

else

    echo "Provide the ES endpoint and index pattern"

fi