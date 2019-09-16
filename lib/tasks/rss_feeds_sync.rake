# frozen_string_literal: true

namespace :rss do
  namespace :feeds do
    desc 'Sync the rss feeds'
    task sync: :environment do
      puts "#{Time.current} -------------- Rss Feeds sync started ----------"
      RssFeed.sync do |feed|
        puts "#{Time.current}\t#{feed.url}"
      end
      puts "#{Time.current} RSS Feeds sync completed."
    end
  end
end
