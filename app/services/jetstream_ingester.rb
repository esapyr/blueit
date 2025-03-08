# TODO: A lot, this is using a lot of OS level concurrency that we dont have *great* control over from ruby
# this works for now though
class JetstreamIngester
  JETSTREAM_SUBSCRIPTION_ENDPOINT = "wss://jetstream2.us-east.bsky.network/subscribe"
  DEFAULT_JETSTREAM_COLLECTION = "app.bsky.feed.post"

  def initialize(collection: DEFAULT_JETSTREAM_COLLECTION)
    @collection = collection
  end

  def start
    Rails.logger.info("Starting ingestion from: #{jetstream_ws_url}")

    stream_from_jetstream do |raw_line|
      post = JSON.parse(raw_line, symbolize_names: true)

      begin
        url = URI.parse(post[:link])
      rescue URI::InvalidURIError => e
        Rails.logger.warn("Failed to parse url #{post[:link]} with: #{e.full_message}")
        next
      end

      Link.create!(
        url: url.to_s,
        created_at: post[:created_at],
        scheme: url.scheme,
        host: url.host,
        path: url.path,
        query: url.query
      )
    end

  ensure
    Rails.logger.info("Ending ingestion from #{jetstream_ws_url}")
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
      ".",
      '{text: .commit.record.text, type: .commit.record."$type", did: .did, rkey: .commit.rkey, link: .commit.record.facets[]?.features[]?.uri, kind: .kind, op: .commit.operation, langs: .commit.record.langs, createdAt: .commit.record.createdAt}',
      'select(.kind == "commit")',
      "select(.link != null)"
    ].join(" | ")
  end
end
