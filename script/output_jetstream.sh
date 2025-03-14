COLLECTION="${COLLECTION:-app.bsky.feed.post}"
# eventually use newsyslog to rotate logs
# have job that reads them clean them up
websocat "wss://jetstream2.us-east.bsky.network/subscribe?wantedCollections=${COLLECTION}" | jq '.'
