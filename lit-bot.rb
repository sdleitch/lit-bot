require 'tactful_tokenizer'
require 'twitter'

lines = File.readlines("testfile.txt")

client = Twitter::REST::Client.new do |config|
  config.consumer_key    = lines[0]
  config.consumer_secret = lines[1]
end

# Takes an Array of Strings (phrases)
# joins them into longer Strings
# nearly, but not longer than 140 characters.
# (when the next word would make then string too long)
# Returns an Array of Strings
def merge_phrases(phrase_array)
  count = 0
  until phrase_array[count+1] == nil || phrase_array[count].length + phrase_array[count+1].length > 140
    phrase_array[count] = phrase_array[count] + " " + phrase_array[count+1]
    phrase_array.delete_at(count+1)
  end
  count += 1
  phrase_array
end

# Chops Strings at spaces, then rebuilds them until they're
# nearly, but not longer than 140 characters.
# (when the next word would make then string too long)
# Returns and Array of Strings
def chop_string(s)
  words = s.split(' ')
  pos = 0
  slices = [""]
  phrase = ""
  words.each do |word|
    if phrase.length + word.length < 140
      phrase = phrase + " " + word
      slices[pos] = phrase
    else
      phrase = word
      pos += 1
    end
  end
  slices.each { |phrase| phrase.strip! }
end

# Pass in a String,
# returns an Array of shorter Strings,
# depening on what the original contained
def break_sentence(sentence)
  phrases = []
  if sentence.length > 140
    if sentence =~ /[,:;]/
      splits = sentence.split(/([,:;])\s/).each_slice(2).map(&:join).map(&:strip)
      splits.each do |split|
        chops = chop_string(split)
        phrases << chops
      end
      phrases.flatten!
    else
      chop_string(sentence)
    end
  else
    phrases << sentence
  end
  merge_phrases(phrases)
end

tokenizer = TactfulTokenizer::Model.new
doc = File.open('works/100YearsOfSolitude.txt')

sentences = tokenizer.tokenize_text(doc)

sentences.each do |sentence|
  break_sentence(sentence).each do |s|
    puts(s)
    File.write("progfile", s)
    sleep 1
  end
end
