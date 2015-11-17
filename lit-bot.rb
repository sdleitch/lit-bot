require 'tactful_tokenizer'

def merge_phrases(phrase_array)
  count = 0
  until phrase_array[count+1] == nil || phrase_array[count].length + phrase_array[count+1].length > 140
    phrase_array[count] = phrase_array[count] + " " + phrase_array[count+1]
    phrase_array.delete_at(count+1)
  end
  count += 1
  phrase_array
end

def break_sentence(sentence)
  phrases = []
  if sentence.length > 140
    if sentence =~ /.{1,140}[,:;].{1,140}/
      phrases = sentence.split(/([,:;])\s/).each_slice(2).map(&:join).map(&:strip)
    elsif sentence =~ /.{0,47}[\u201c].{1,46}[\u201d].{0,47}/
      phrases = sentence.split(/(['\u201c\u201d])/).each_slice(2).map(&:join).map(&:strip)
    else
      words = sentence.split(' ')
      pos = 0
      phrases = [""]
      phrase = ""
      words.each do |word|
        if phrase.length + word.length < 140
          phrase = phrase + " " + word
          phrases[pos] = phrase
        else
          phrase = word
          pos += 1
        end
      end
      phrases.each { |phrase| phrase.strip! }
    end
  else
    phrases << sentence
  end
  merge_phrases(phrases)
end

# s.split(/([?!.])/).each_slice(2).map(&:join).map(&:strip)

tokenizer = TactfulTokenizer::Model.new
doc = File.open('works/100YearsOfSolitude.txt')

sentences = tokenizer.tokenize_text(doc)

sentences.each do |sentence|
  break_sentence(sentence).each { |s| p(s); sleep 1 }
end
