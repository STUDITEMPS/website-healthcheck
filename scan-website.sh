website_url=$1
scan_text=$2
max_attempts=$3
backoff_multiplier=$4

for (( i=1; i<=$max_attempts; i++ )) do
    status_code=$(curl --silent --location --head --output /dev/null --write-out "%{http_code}" "${website_url}")
    sleep_duration=$(($i * $backoff_multiplier))

    if [ "${status_code}" != "200" ]; then
        echo "Website is unreachable (${status_code})" >&2
        sleep $sleep_duration
        continue
    fi

    if ! curl --silent --location "{$website_url}" | grep --quiet --ignore-case "${scan_text}"; then
        echo "Text was not found on website" >&2
        sleep $sleep_duration
        continue
    fi

    exit 0
done

exit 1
