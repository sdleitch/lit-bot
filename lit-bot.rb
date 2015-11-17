require 'tactful_tokenizer'

def merge_sentences(sentence_array)
  count = 0
  while count + 1 < sentence_array.length
    if sentence_array[count] != nil && sentence_array[count].length + sentence_array[count+1].length < 140
      sentence_array[count] = sentence_array[count..count+1].join(' ')
      sentence_array.delete_at(count+1)
    end
    count += 1
  end
  sentence_array
end

def break_sentence(sentence)
  if sentence.length > 140
    if sentence =~ /.{1,139}[,:;].{1,139}/
      sentences = sentence.split(/([,:;])\s/).each_slice(2).map(&:join).map(&:strip)
      return merge_sentences(sentences)
    elsif sentence =~ /.{0,139}["'\u201c].{1,139}["'\u201d].{0,139}/

    end
  end
end

def s_print(s)
  to_print = s
  puts to_print
  sleep 1
end

# s.split(/([?!.])/).each_slice(2).map(&:join).map(&:strip)

tokenizer = TactfulTokenizer::Model.new
doc = File.open('works/100YearsOfSolitude.txt')

sentences = tokenizer.tokenize_text(doc)

sentences.each do |sentence|
  to_print = ""
  if sentence.length <= 140
    s_print(sentence)
  elsif sentence =~ /.{1,139}[,:;].{1,139}/
    temp_arr = break_sentence(sentence)
    temp_arr.each do |s|
      s_print(s)
    end
  end
end
