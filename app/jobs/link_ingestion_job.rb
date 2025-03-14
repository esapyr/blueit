class LinkIngestionJob < ApplicationJob
  LINK_TYPE = "app.bsky.richtext.facet#link"
  TAG_TYPE = "app.bsky.richtext.facet#tag"

  queue_as :default

  def perform(raw_post)
    post = JSON.parse(raw_post).with_indifferent_access
    did = post[:did]
    rkey =  post.dig(:commit, :rkey)
    posted_at = post.dig(:commit, :record, :createdAt)

    posted_urls(post).each do |raw_url|
      url = parse_uri(follow_link_to_source raw_url)
      next if url.nil?

      cleaned_url = build_cleaned_url(
        scheme: url.scheme,
        host: url.host,
        path: url.path,
        query: clean_query_params(url.query).presence
      )

      puts cleaned_url

      Link.create!(
        url: cleaned_url.to_s,
        host: cleaned_url.host,
        did:,
        rkey:,
        posted_at:
      )
    end

    posted_tags(post).each do |tag|
      Tag.create!(
        text: tag,
        did:,
        rkey:,
        posted_at:
      )
    end

    Comment.create!(
      text: post.dig(:commit, :record, :text),
      root: true,
      did:,
      rkey:
    )
  end

  private

  def follow_link_to_source(link)
    HTTP.follow.get(link).uri.to_s
  end

  def clean_query_params(query)
    Rack::Utils
      .parse_nested_query(query)
      .reduce({}) do |cleaned, (k, v)|
        next cleaned if k =~ /^utm_/
        cleaned.merge(k => v)
    end.to_query
  end

  # TODO: Gotta be a better way to do this
  def build_cleaned_url(scheme:, host:, path:, query:)
    case scheme
    when "http"
      URI::HTTP.build(host:, path:, query:)
    when "https"
      URI::HTTPS.build(host:, path:, query:)
    else
      Rails.logger.warn("Failed to construct cleaned link due to url scheme: #{scheme}, link: #{scheme}://#{host}/#{path}?#{query}")
      nil
    end
  end

  def parse_uri(raw_link)
    URI.parse(raw_link)
  rescue URI::InvalidURIError => e
    Rails.logger.warn("Failed to parse url #{raw_link} with: #{e.full_message}")
    nil
  end

  def posted_facets(post)
    @posted_facets ||= post.dig(:commit, :record, :facets).flat_map { |p| p[:features] } || []
  end

  def posted_urls(post)
    @posted_urls ||= posted_facets(post).map do |facet|
      next if facet["$type"] != LINK_TYPE
      facet[:uri]
    end.compact
  end

  def posted_tags(post)
    @posted_tags ||= posted_facets(post).map do |facet|
      next if facet["$type"] != TAG_TYPE
      facet[:tag]
    end.compact
  end
end
