require 'tactful_tokenizer'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["TOKEN"]
  config.access_token_secret = ENV["SECRET"]
end

tokenizer = TactfulTokenizer::Model.new #new tokenizer
doc = File.open('works/100YearsOfSolitude.txt') #read the .txt file
sentences = tokenizer.tokenize_text(doc) #break it into sentences

def merge_phrases(phrase_array)
  count = 0
  until phrase_array[count+1] == nil || (phrase_array[count] + phrase_array[count+1]).length > 139
    phrase_array[count] = phrase_array[count..count+1].join(" ")
    phrase_array.delete_at(count+1)
  end
  count += 1
  phrase_array
end

def chop_string(s)
  words = s.split(' ')
  pos, slices, phrase = 0, [""], ""
  words.each do |word|
    if (phrase + word).length < 140
      phrase = phrase + " " + word
      slices[pos] = phrase
    else
      phrase = word
      pos += 1
    end
  end
  slices.each { |phrase| phrase.strip! }
end

def break_sentence(sentence)
  phrases = []
  if sentence.length > 140
    if sentence =~ /[,:;]/
      splits = sentence.split(/([,:;])\s/).each_slice(2).map(&:join).map(&:strip)
      splits.each { |split| phrases << chop_string(split) }
      phrases.flatten!
    else
      chop_string(sentence)
    end
  else
    phrases << sentence
  end
  merge_phrases(phrases)
end

#Break each sentence
to_print = []
sentences.each do |sentence|
  break_sentence(sentence).each { |s| to_print << s }
end

# start_point = File.read('progfile').to_i #Find place to begin
tweet = to_print[to_print.index(client.user_timeline.first.full_text) + 1]
if rand(7) == 6
  puts "Should tweet: #{tweet}"
  sleep rand(400)
  # client.update(to_print[start_point])
  client.update(tweet)
  # File.write('progfile', start_point + 1)
  # puts (start_point + 1).to_s
else
  puts "MISS: Would have tweeted: #{tweet}"
end
