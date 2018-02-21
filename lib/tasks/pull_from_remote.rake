require "net/http"
require "uri"

namespace :db_admin do
  desc 'Import data from the Heroku site into your local DB'
  task pull_data: :environment do
    listings = (1..20).map do |page|
      uri = URI("https://legalhousing.herokuapp.com/listings.json")
      uri.query = URI.encode_www_form({:page => page + 1 })
      resp = Net::HTTP.get_response(uri)

      if resp.code == "200"
        JSON.parse(resp.body)
      else
        []
      end
    end

    all_listings = listings.reduce(&:+)

    all_listings.each do |listing|
      if !Listing.new(listing).save()
        print "Imported failed to create listing for data: #{listing}"
      end
    end
  end
end
