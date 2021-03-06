require 'rss'
require 'open-uri'
require 'parallel'
require 'crawlers/helpers/content'

module Crawlers
  class Rss
    include Helpers::Content

    def initialize(rss_url)
      @rss_url = rss_url
    end

    def articles
      articles = Parallel.map(rss_feed_items) do |feed_item|
        crawl_article(feed_item)
      end
      articles.reject(&:empty?)
    end

    private

    def rss_feed_items
      rss_feed = page_content(@rss_url)
      parse_feed(rss_feed)
    end

    def parse_feed(rss_feed)
      RSS::Parser.parse(rss_feed)&.items
    rescue RSS::Error
      []
    end

    def crawl_article(feed_item)
      page_with_article = page_content(feed_item.link)
      extract_primary_content(page_with_article)
    end

    def page_content(page_url)
      open(page_url).read
    rescue StandardError
      ''
    end
  end
end
