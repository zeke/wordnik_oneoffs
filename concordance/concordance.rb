%w(rubygems wordnik benchmark).each {|lib| require lib }

Wordnik.configure do |config|
  config.api_key = ENV['WORDNIK_API_KEY']
  config.host = "api.wordnik.com"
  config.base_path = "/v4"
  config.logger = Logger.new('/dev/null')
end

class Search
  
  attr_accessor :query, :results
    
  def initialize(query, options={})
    self.query = query
    defaults = {skip: 0}
    options = defaults.merge(options)

    self.results = Wordnik.words.search_words(
      case_sensitive: false,
      min_dictionary_count: 1,
      query: query,
      skip: options[:skip],
      limit: Search.limit
    ).map {|r| r['wordstring'] }
  end

  def self.limit
    1000
  end

end

class Concordance
  
  def initialize(prefixes, output_file)
    file = File.new(output_file, "w+")
    results = Hash.new([])
    prefixes.each do |prefix|
      # Start at 1 to circumvent a bug in the search API
      skip = 1
      results[prefix] = []

      # Keep hitting the API until we have a remainder.
      # e.g. 1000, 2000, 3000, 4000, 4279, STOP!
      while results[prefix].size % Search.limit == 0
        words = Search.new(prefix, :skip => skip)
        results[prefix] += words.results

        # Add 1 to circumvent a bug in the search API
        skip = results[prefix].size + 1
      end
      
      puts "#{prefix} words: #{results[prefix].size}"
      file.write results[prefix].sort.join("\n") + "\n"
    end
    file.close
    
  end
end

Concordance.new(('a'..'z').to_a, "concordance_lowercase.txt")
Concordance.new(('A'..'Z').to_a, "concordance_uppercase.txt")

