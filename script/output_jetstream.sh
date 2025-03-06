COLLECTION="${COLLECTION:-app.bsky.feed.post}"
# eventually use newsyslog to rotate logs
# have job that reads them clean them up
websocat "wss://jetstream2.us-east.bsky.network/subscribe?wantedCollections=${COLLECTION}" |
  jq '. |
    {text: .commit.record.text, type: .commit.record."$type", did: .did, rkey: .commit.rkey, link: .commit.record.facets[]?.features[]?.uri, kind: .kind, op: .commit.operation, langs: .commit.record.langs}
    | select(.link != null)'
