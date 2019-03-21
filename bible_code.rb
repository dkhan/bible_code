# Galatians 2:20 (KJV): I am crucified with Christ: nevertheless I live; yet not I, but Christ liveth in me: and the life which I now live in the flesh I live by the faith of the Son of God, who loved me, and gave himself for me.
# verse = "χριστω συνεσταυρωμαι ζω δε ουκετι εγω ζη δε εν εμοι χριστος ο δε νυν ζω εν σαρκι εν πιστει ζω τη του υιου του θεου του αγαπησαντος με και παραδοντος εαυτον υπερ εμου"
# BibleCode.decode_all(verse)
# code = BibleCode.new(verse: verse, author: 'KHAN', value: :numeric_value, verbose: false, word_stat: true); pp code.vocabulary.sort;1
# code.break
# code.decode
# code.unique_word_count
# code.translate
# sum = 19061
# sum/7.0 => 2723.0
# 2+7+2+3 => 14 => 7*2
class BibleCode
  require 'prime'
  require 'json'

  attr_reader :verse, :author, :map, :value

  KHAN_MAP = {
    ' ' => { place_value:  0, numeric_value:   0, value:   0, vowel: false },
    'α' => { place_value:  1, numeric_value:   1, value:   2, vowel: true  },
    'β' => { place_value:  2, numeric_value:   2, value:   4, vowel: false },
    'γ' => { place_value:  3, numeric_value:   3, value:   6, vowel: false },
    'δ' => { place_value:  4, numeric_value:   4, value:   8, vowel: false },
    'ε' => { place_value:  5, numeric_value:   5, value:  10, vowel: true  },
    'ς' => { place_value:  6, numeric_value:   6, value:  12, vowel: false },
    'ζ' => { place_value:  7, numeric_value:   7, value:  14, vowel: false },
    'η' => { place_value:  8, numeric_value:   8, value:  16, vowel: true  },
    'θ' => { place_value:  9, numeric_value:   9, value:  18, vowel: false },
    'ι' => { place_value: 10, numeric_value:  10, value:  20, vowel: true  },
    'κ' => { place_value: 11, numeric_value:  20, value:  31, vowel: false },
    'λ' => { place_value: 12, numeric_value:  30, value:  42, vowel: false },
    'μ' => { place_value: 13, numeric_value:  40, value:  53, vowel: false },
    'ν' => { place_value: 14, numeric_value:  50, value:  64, vowel: false },
    'ξ' => { place_value: 15, numeric_value:  60, value:  75, vowel: false },
    'ο' => { place_value: 16, numeric_value:  70, value:  86, vowel: true  },
    'π' => { place_value: 17, numeric_value:  80, value:  97, vowel: false },
    'ϙ' => { place_value: 18, numeric_value:  90, value: 108, vowel: false },
    'ρ' => { place_value: 19, numeric_value: 100, value: 119, vowel: false },
    'σ' => { place_value: 20, numeric_value: 200, value: 220, vowel: false },
    'τ' => { place_value: 21, numeric_value: 300, value: 321, vowel: false },
    'υ' => { place_value: 22, numeric_value: 400, value: 422, vowel: true  },
    'φ' => { place_value: 23, numeric_value: 500, value: 523, vowel: false },
    'χ' => { place_value: 24, numeric_value: 600, value: 624, vowel: false },
    'ψ' => { place_value: 23, numeric_value: 700, value: 723, vowel: false },
    'ω' => { place_value: 24, numeric_value: 800, value: 824, vowel: true  },
    'ϡ' => { place_value: 25, numeric_value: 900, value: 925, vowel: false }
  }

  PANIN_MAP = {
    ' ' => { place_value:  0, numeric_value:   0, value:   0, vowel: false },
    'α' => { place_value:  1, numeric_value:   1, value:   2, vowel: true  },
    'β' => { place_value:  2, numeric_value:   2, value:   4, vowel: false },
    'γ' => { place_value:  3, numeric_value:   3, value:   6, vowel: false },
    'δ' => { place_value:  4, numeric_value:   4, value:   8, vowel: false },
    'ε' => { place_value:  5, numeric_value:   5, value:  10, vowel: true  },
    'ζ' => { place_value:  6, numeric_value:   7, value:  13, vowel: false },
    'η' => { place_value:  7, numeric_value:   8, value:  15, vowel: true  },
    'θ' => { place_value:  8, numeric_value:   9, value:  17, vowel: false },
    'ι' => { place_value:  9, numeric_value:  10, value:  19, vowel: true  },
    'κ' => { place_value: 10, numeric_value:  20, value:  30, vowel: false },
    'λ' => { place_value: 11, numeric_value:  30, value:  41, vowel: false },
    'μ' => { place_value: 12, numeric_value:  40, value:  52, vowel: false },
    'ν' => { place_value: 13, numeric_value:  50, value:  63, vowel: false },
    'ξ' => { place_value: 14, numeric_value:  60, value:  74, vowel: false },
    'ο' => { place_value: 15, numeric_value:  70, value:  85, vowel: true  },
    'π' => { place_value: 16, numeric_value:  80, value:  96, vowel: false },
    'ρ' => { place_value: 17, numeric_value: 100, value: 117, vowel: false },
    'σ' => { place_value: 18, numeric_value: 200, value: 218, vowel: false },
    'ς' => { place_value: 18, numeric_value: 200, value: 218, vowel: false },
    'τ' => { place_value: 19, numeric_value: 300, value: 319, vowel: false },
    'υ' => { place_value: 20, numeric_value: 400, value: 420, vowel: true  },
    'φ' => { place_value: 21, numeric_value: 500, value: 521, vowel: false },
    'χ' => { place_value: 22, numeric_value: 600, value: 622, vowel: false },
    'ψ' => { place_value: 23, numeric_value: 700, value: 723, vowel: false },
    'ω' => { place_value: 24, numeric_value: 800, value: 824, vowel: true  }
  }

  WORD_FORMS = {
    "ο" => %w(του τον της τους),
    "εζεκιας" => %w(εζεκιας εζεκιαν),
    "ιουδας" => %w(ιουδας ιουδαν),
    "ιωσιας" => %w(ιωσιας ιωσιαν),
    "μανασσης" => %w(μανασσης μανασση),
    "οζιας" => %w(οζιας οζιαν),
    "σολομων" => %w(σολομων σολομωνα),
    "γενναω" => %w(εγεννησεν),
    "γενεσις" => %w(γενεσεως),
    "βασιλευς" => %w(βασιλεα),
    "ιησους" => %w(ιησου),
    "χριστος" => %w(χριστου),
    "υιος" => %w(υιου),
    "αδελφος" => %w(αδελφους),
    "αυτος" => %w(αυτου),
    "ουριας" => %w(ουριου),
    "ιεχονιας" => %w(ιεχονιαν),
    "μετοικεσια" => %w(μετοικεσιας),
    "βαβυλων" => %w(βαβυλωνος),
  }

  def initialize(verse:, author: 'KHAN', value: :numeric_value, verbose: false, word_stat: true)
    @verse = verse
    @author = author
    @map = author == 'KHAN' ? KHAN_MAP : PANIN_MAP
    @value = value
    @verbose = verbose
    @word_stat = word_stat
  end

  def self.decode_all(verse)
    BibleCode.new(verse: verse, author: 'KHAN',  value: :place_value,   verbose: false, word_stat: true).decode
    BibleCode.new(verse: verse, author: 'KHAN',  value: :numeric_value, verbose: false, word_stat: false).decode
    BibleCode.new(verse: verse, author: 'KHAN',  value: :value,         verbose: false, word_stat: false).decode
    BibleCode.new(verse: verse, author: 'PANIN', value: :place_value,   verbose: false, word_stat: false).decode
    BibleCode.new(verse: verse, author: 'PANIN', value: :numeric_value, verbose: false, word_stat: false).decode
    BibleCode.new(verse: verse, author: 'PANIN', value: :value,         verbose: false, word_stat: false).decode
  end

  def analyze
    printf "The number of words:                                             %7d %50s\n", word_count,                          primes(word_count)
    printf "The number of letters:                                           %7d %50s\n", letter_count,                        primes(letter_count)
    printf "The number of vowels:                                            %7d %50s\n", vowel_count,                         primes(vowel_count)
    printf "The number of consonants:                                        %7d %50s\n", consonant_count,                     primes(consonant_count)
    printf "The number of words that begin with a vowel:                     %7d %50s\n", vowel_word_count,                    primes(vowel_word_count)
    printf "The number of words that begin with a consonant:                 %7d %50s\n", consonant_word_count,                primes(consonant_word_count)
    printf "The number of words that occur more than once:                   %7d %50s\n", words_more_than_once_count,          primes(words_more_than_once_count)
    printf "The number of vocabulary words:                                  %7d %50s\n", vocabulary_count,                    primes(vocabulary_count)
    printf "The number of vocabulary letters:                                %7d %50s\n", vocabulary_letter_count,             primes(vocabulary_letter_count)
    printf "The number of vocabulary vowels:                                 %7d %50s\n", vocabulary_vowel_count,              primes(vocabulary_vowel_count)
    printf "The number of vocabulary consonants:                             %7d %50s\n", vocabulary_consonant_count,          primes(vocabulary_consonant_count)
    printf "The number of vocabulary words that begin with a vowel:          %7d %50s\n", vocabulary_vowel_word_count,         primes(vocabulary_vowel_word_count)
    printf "The number of vocabulary words that begin with a consonant:      %7d %50s\n", vocabulary_consonant_word_count,     primes(vocabulary_consonant_word_count)
    printf "The number of vocabulary words that occur more than once:        %7d %50s\n", vocabulary_more_than_once_count,     primes(vocabulary_more_than_once_count)
    printf "The number of vocabulary words that occur in more than one form: %7d %50s\n", vocabulary_more_than_one_form_count, primes(vocabulary_more_than_one_form_count)
    printf "The number of vocabulary words that occur only in one form:      %7d %50s\n", vocabulary_only_in_one_form_count,   primes(vocabulary_only_in_one_form_count)
  end

  def words
    @words ||= verse.split(' ')
  end

  def letters
    @letters ||= verse.gsub(' ', '').chars
  end

  def letter_count
    @letter_count ||= letters.count
  end

  def vowel_count
    letters.select{ |l| map[l][:vowel] }.count
  end

  def consonant_count
    letters.reject{ |l| map[l][:vowel] }.count
  end

  def word_count
    @word_count ||= words.count
  end

  def vowel_word_count
    words.select{|w| map[w[0]][:vowel] }.count
  end

  def consonant_word_count
    words.reject{|w| map[w[0]][:vowel] }.count
  end

  def words_more_than_once_count
    unique_words.values.select{|v|v > 1}.count
  end

  def decode
    if @verbose
      words.each do |word|
        wc = BibleCode.new(verse: word, author: author, value: value)
        printf "%20s %-80s %6s %s\n", word, *wc.decode_word
      end
      puts "-"*200
    end
    puts "words: #{word_count} words primes: #{Prime.prime_division(word_count)}" if @word_stat
    printf "%-5s %-15s sum: %7d primes: #{primes}\n", author, value, sum
  end

  def decode_word
    [numbers, sum, primes]
  end

  def break
    1.upto(word_count).each do |i|
      v = words[0..-i].join(' ')
      code = BibleCode.new(verse: v, author: author, value: value)
      printf "%7d %50s #{v}\n", code.sum, code.primes
    end
  end

  def sum
    numbers.inject(0) { |s, n| s += n }
  end

  def numbers
    verse.chars.map { |l| map[l][value] }
  end

  def primes(num = sum)
    return [] if num == 0
    Prime.prime_division(num)
  end

  def unique_words
    return @unique_words if @unique_words

    @unique_words = {}
    words.each do |word|
      if @unique_words[word]
        @unique_words[word] += 1
      else
        @unique_words[word] = 1
      end
    end
    @unique_words
  end

  def unique_word_count
    unique_words.keys.count
  end

  def vocabulary
    return @vocabulary if @vocabulary

    @vocabulary = {}
    unique_words.each do |word, count|
      vw = word
      forms = []
      WORD_FORMS.each do |w, f|
        if f.include?(word)
          vw = w
          forms = f
          break
        end
      end
      if @vocabulary[vw]
        @vocabulary[vw][0] += count
      else
        @vocabulary[vw] = [count, forms]
      end
    end
    @vocabulary
  end

  def vocabulary_count
    vocabulary.keys.count
  end

  def vocabulary_letter_count
    vcode = BibleCode.new(verse: vocabulary.keys.join(' '), author: author, value: value)
    vcode.letter_count
  end

  def vocabulary_more_than_once_count
    vocabulary.values.select{|v|v[0] > 1}.count
  end

  def vocabulary_vowel_count
    vcode = BibleCode.new(verse: vocabulary.keys.join(' '), author: author, value: value)
    vcode.vowel_count
  end

  def vocabulary_consonant_count
    vcode = BibleCode.new(verse: vocabulary.keys.join(' '), author: author, value: value)
    vcode.consonant_count
  end

  def vocabulary_vowel_word_count
    vcode = BibleCode.new(verse: vocabulary.keys.join(' '), author: author, value: value)
    vcode.vowel_word_count
  end

  def vocabulary_consonant_word_count
    vcode = BibleCode.new(verse: vocabulary.keys.join(' '), author: author, value: value)
    vcode.consonant_word_count
  end

  def vocabulary_more_than_one_form_count
    vocabulary.values.select{|v|v[1].count > 1}.count
  end

  def vocabulary_only_in_one_form_count
    vocabulary.values.select{|v|v[1].count <= 1}.count
  end

  def dictionary_check
    json = File.read("dictionary.json")
    dictionary = JSON.parse(json)
    vocabulary.keys.each do |word|
      puts "#{word}: #{!dictionary[word].nil?}"
    end
  end

  def translate
    words.each do |word|
      printf "%40s %40s\n", word, Translator.translate(word, 'el-GR', 'en')
    end
    nil
  end
end

class Translator
  require 'net/http'
  require 'rubygems'
  require "uri"
  require 'json'

  def self.translate(text, from = 'el-GR', to = 'en')
    uri = URI.parse("http://mymemory.translated.net/api/get")

    response = Net::HTTP.post_form(uri, { "q" => text,"langpair" => "#{from.downcase}|#{to.downcase}", "per_page" => "50" })

    json_response_body = JSON.parse response.body

    if json_response_body['responseStatus'] == 200
      json_response_body['responseData']['translatedText']
    else
      "<#{text}>"
      # puts json_response_body['responseDetails']
    end
  rescue
    "<#{text}>"
  end
end
