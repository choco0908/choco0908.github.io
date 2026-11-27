# frozen_string_literal: true

require "date"
require "jekyll"
require "json"
require "net/http"
require "time"
require "uri"

def canonical_path(path)
  URI::DEFAULT_PARSER.unescape(path).delete_suffix("/index.html").delete_suffix("/")
end

def fetch_hits(endpoint, token, start_time, end_time)
  excluded_ids = []

  loop do
    endpoint.query = URI.encode_www_form(
      start: start_time.iso8601, end: end_time.iso8601, limit: 100,
      exclude_paths: excluded_ids.join(",")
    )
    request = Net::HTTP::Get.new(endpoint)
    request["Authorization"] = "Bearer #{token}"
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"

    response = Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
      http.request(request)
    end
    abort "GoatCounter statistics returned HTTP #{response.code}." unless response.is_a?(Net::HTTPSuccess)

    page = JSON.parse(response.body)
    hits = page.fetch("hits") || []
    hits.each { |hit| yield hit }
    break unless page.fetch("more")

    new_ids = hits.map { |hit| Integer(hit.fetch("path_id")) } - excluded_ids
    abort "GoatCounter pagination did not advance." if new_ids.empty?

    excluded_ids.concat(new_ids)
  end
end

def refresh_popular_posts
  token = ENV.fetch("GOATCOUNTER_API_TOKEN", "").strip
  abort "GOATCOUNTER_API_TOKEN is missing." if token.empty?

  site = Jekyll::Site.new(Jekyll.configuration("quiet" => true))
  site.read
  posts = site.posts.docs.to_h { |post| [canonical_path(post.url), post] }

  tracker = site.config.fetch("analytics").fetch("goatcounter").fetch("endpoint")
  endpoint = URI.join(tracker, "/api/v0/stats/hits")
  abort "GoatCounter statistics require HTTPS." unless endpoint.is_a?(URI::HTTPS)

  today = Time.now.getlocal("+09:00").to_date
  first_day = today - 30
  last_day = today - 1
  counts = Hash.new(0)
  fetch_hits(endpoint, token, Time.new(first_day.year, first_day.month, first_day.day, 0, 0, 0, "+09:00"),
             Time.new(last_day.year, last_day.month, last_day.day, 23, 59, 59, "+09:00")) do |hit|
    next if hit["event"]

    path = canonical_path(hit.fetch("path"))
    count = Integer(hit.fetch("count"))
    counts[path] += count if posts.key?(path) && count.positive?
  end

  ranked = counts.sort_by { |path, count| [-count, -posts.fetch(path).date.to_i, path] }.first(4)
  result = { posts: ranked.map { |path, _count| { post: posts.fetch(path).url } } }
  File.write("_data/home_popular.json", JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
  puts "Saved #{ranked.length} popular posts."
end

refresh_popular_posts if $PROGRAM_NAME == __FILE__
