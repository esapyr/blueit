namespace :jetstream do
  desc "read and create links directly from jetstream post data"
  task ingest_links: :environment do
    JetstreamIngester.new.start
  end
end
