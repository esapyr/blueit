# TODO: A lot, this is using a lot of OS level concurrency that we dont have *great* control over from ruby
# this works for now though
class JetstreamIngester
  JETSTREAM_SUBSCRIPTION_ENDPOINT = "wss://jetstream2.us-east.bsky.network/subscribe"

  JQ_FILTERS = [
    LANGUAGE_FILTER = 'if .commit.record.langs == null then . else select(.commit.record.langs | contains(["en"])) end',
    NOT_REPLY_FILTER = "select(.commit.record.reply | not)",
    NEW_RECORD_FILTER = 'select(.commit.operation == "create")',
    CONTAINS_LINK_FILTER = "select(isempty(.commit.record.facets[]?.features[]?.uri) | not)"
  ]

  JETSTREAM_COLLECTIONS = [
    JETSTREAM_POST = "app.bsky.feed.post"
  ]

  DEFAULT_JETSTREAM_COLLECTION = JETSTREAM_POST

  def initialize(collection: DEFAULT_JETSTREAM_COLLECTION)
    @collection = collection
  end

  def start
    puts "Starting ingestion from: #{jetstream_ws_url}"

    stream_from_jetstream do |raw_line|
      LinkIngestionJob.perform_later(raw_line)
      print "."
    end
  ensure
    puts "Ending ingestion from #{jetstream_ws_url}"
  end

  private

  def stream_from_jetstream
    fetch_cmd = "websocat \"#{jetstream_ws_url}\""
    filter_cmd = "jq -c '#{raw_stream_jq_filters}'"

    Open3.pipeline_r fetch_cmd, filter_cmd do |out, wait|
      while line = out.gets
        yield line
      end
    end
  end

  def jetstream_ws_url
    @jetstream_ws_url ||= "#{JETSTREAM_SUBSCRIPTION_ENDPOINT}?wantedCollections=#{@collection}"
  end

  def raw_stream_jq_filters
    @raw_stream_jq_filters ||= [
      # NOTE: the order here matters, we can only check the lang of new posts, etc
      NEW_RECORD_FILTER,
      NOT_REPLY_FILTER,
      LANGUAGE_FILTER,
      CONTAINS_LINK_FILTER
    ].join(" | ")
  end
end
