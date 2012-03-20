%w(rubygems wordnik active_support/inflector).each {|lib| require lib }

CREDENTIALS = YAML::load_file(File.join(ENV['HOME'], ".wordnik.yml")).symbolize_keys

Wordnik.configure do |config|
  config.api_key = CREDENTIALS[:api_key]
end

LetterQuery = Struct.new(:query, :includePartOfSpeech, :excludePartOfSpeech, :plural)

letter_queries = [
  LetterQuery.new('w*', 'adjective', 'noun'),
  LetterQuery.new('o*', 'noun', nil, true),
  LetterQuery.new('r*', 'adverb', 'noun'),
  LetterQuery.new('d*', 'verb-transitive', 'noun'),
  LetterQuery.new('n*', 'adjective', 'noun'),
  LetterQuery.new('i*', 'adjective', 'noun'),
  LetterQuery.new('k*', 'noun', nil, true)
]

10.times do
  puts "\n"
  letter_queries.each do |q|
    result = Wordnik.words.search_words(
      :query => q.query,
      :includePartOfSpeech => q.includePartOfSpeech, 
      :excludePartOfSpeech => q.excludePartOfSpeech,
      :limit => 1,
      :minCorpusCount => 5_000,
      :maxCorpusCount => 100_000 + rand(500_000).to_i
    )
    word = result.first['wordstring']
    word = word.pluralize if q.plural
    puts word
  end
end