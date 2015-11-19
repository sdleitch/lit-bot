require 'tactful_tokenizer'
require 'chatterbot/dsl'

chatterbot = Chatterbot::Bot #new bot

#authenticate bot with Twitter API
config = YAML::load(File.open('100YearsOf.yml'))
chatterbot.consumer_key config[:consumer_key]
chatterbot.consumer_secret config[:consumer_secret]
chatterbot.secret config[:secret]
chatterbot.token config[:token]

tokenizer = TactfulTokenizer::Model.new #new tokenizer
doc = File.open('works/100YearsOfSolitude.txt') #read the .txt file
sentences = tokenizer.tokenize_text(doc) #break it into sentences

def merge_phrases(phrase_array)
  count = 0
  until phrase_array[count+1] == nil || (phrase_array[count] + phrase_array[count+1]).length > 140
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

start_point = File.read('progfile').to_i #Find place to begin

#Print each sentence then sleep for random intervals
to_print[(start_point + 1)..to_print.length].each do |s|
  # chatterbot.tweet s
  puts s
  File.write("progfile", to_print.index(s))
  sleep 1 #rand(600..2400)
end
