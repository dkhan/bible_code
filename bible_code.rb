# Galatians 2:20 (KJV): I am crucified with Christ: nevertheless I live; yet not I, but Christ liveth in me: and the life which I now live in the flesh I live by the faith of the Son of God, who loved me, and gave himself for me.
# verse = "χριστω συνεσταυρωμαι ζω δε ουκετι εγω ζη δε εν εμοι χριστος ο δε νυν ζω εν σαρκι εν πιστει ζω τη του υιου του θεου του αγαπησαντος με και παραδοντος εαυτον υπερ εμου"
# BibleCode.decode_all(verse)
# sum = 19061
# sum/7.0 => 2723.0
# 2+7+2+3 => 14 => 7*2
class BibleCode
  require 'prime'

  attr_reader :passage, :map, :mapping, :value, :verbose

  KHAN_MAP = {
    ' ' => { place_value:  0, numeric_value:   0, value:   0 },
    'α' => { place_value:  1, numeric_value:   1, value:   2 },
    'β' => { place_value:  2, numeric_value:   2, value:   4 },
    'γ' => { place_value:  3, numeric_value:   3, value:   6 },
    'δ' => { place_value:  4, numeric_value:   4, value:   8 },
    'ε' => { place_value:  5, numeric_value:   5, value:  10 },
    'ς' => { place_value:  6, numeric_value:   6, value:  12 },
    'ζ' => { place_value:  7, numeric_value:   7, value:  14 },
    'η' => { place_value:  8, numeric_value:   8, value:  16 },
    'θ' => { place_value:  9, numeric_value:   9, value:  18 },
    'ι' => { place_value: 10, numeric_value:  10, value:  20 },
    'κ' => { place_value: 11, numeric_value:  20, value:  31 },
    'λ' => { place_value: 12, numeric_value:  30, value:  42 },
    'μ' => { place_value: 13, numeric_value:  40, value:  53 },
    'ν' => { place_value: 14, numeric_value:  50, value:  64 },
    'ξ' => { place_value: 15, numeric_value:  60, value:  75 },
    'ο' => { place_value: 16, numeric_value:  70, value:  86 },
    'π' => { place_value: 17, numeric_value:  80, value:  97 },
    'ϙ' => { place_value: 18, numeric_value:  90, value: 108 },
    'ρ' => { place_value: 19, numeric_value: 100, value: 119 },
    'σ' => { place_value: 20, numeric_value: 200, value: 220 },
    'τ' => { place_value: 21, numeric_value: 300, value: 321 },
    'υ' => { place_value: 22, numeric_value: 400, value: 422 },
    'φ' => { place_value: 23, numeric_value: 500, value: 523 },
    'χ' => { place_value: 24, numeric_value: 600, value: 624 },
    'ψ' => { place_value: 23, numeric_value: 700, value: 723 },
    'ω' => { place_value: 24, numeric_value: 800, value: 824 },
    'ϡ' => { place_value: 25, numeric_value: 900, value: 925 }
  }

  PANIN_MAP = {
    ' ' => { place_value:  0, numeric_value:   0, value:   0 },
    'α' => { place_value:  1, numeric_value:   1, value:   2 },
    'β' => { place_value:  2, numeric_value:   2, value:   4 },
    'γ' => { place_value:  3, numeric_value:   3, value:   6 },
    'δ' => { place_value:  4, numeric_value:   4, value:   8 },
    'ε' => { place_value:  5, numeric_value:   5, value:  10 },
    'ζ' => { place_value:  6, numeric_value:   7, value:  13 },
    'η' => { place_value:  7, numeric_value:   8, value:  15 },
    'θ' => { place_value:  8, numeric_value:   9, value:  17 },
    'ι' => { place_value:  9, numeric_value:  10, value:  19 },
    'κ' => { place_value: 10, numeric_value:  20, value:  30 },
    'λ' => { place_value: 11, numeric_value:  30, value:  41 },
    'μ' => { place_value: 12, numeric_value:  40, value:  52 },
    'ν' => { place_value: 13, numeric_value:  50, value:  63 },
    'ξ' => { place_value: 14, numeric_value:  60, value:  74 },
    'ο' => { place_value: 15, numeric_value:  70, value:  85 },
    'π' => { place_value: 16, numeric_value:  80, value:  96 },
    'ρ' => { place_value: 17, numeric_value: 100, value: 117 },
    'σ' => { place_value: 18, numeric_value: 200, value: 218 },
    'ς' => { place_value: 18, numeric_value: 200, value: 218 },
    'τ' => { place_value: 19, numeric_value: 300, value: 319 },
    'υ' => { place_value: 20, numeric_value: 400, value: 420 },
    'φ' => { place_value: 21, numeric_value: 500, value: 521 },
    'χ' => { place_value: 22, numeric_value: 600, value: 622 },
    'ψ' => { place_value: 23, numeric_value: 700, value: 723 },
    'ω' => { place_value: 24, numeric_value: 800, value: 824 }
  }

  def initialize(passage, mapping = 'KHAN', value = :numeric_value, verbose = false)
    @passage = passage
    @mapping = mapping
    @map = mapping == 'KHAN' ? KHAN_MAP : PANIN_MAP
    @value = value
    @verbose = verbose
  end

  def self.decode_all(verse)
    BibleCode.new(verse, 'KHAN', :place_value, false).decode
    BibleCode.new(verse, 'KHAN', :numeric_value, false).decode
    BibleCode.new(verse, 'KHAN', :value, false).decode
    BibleCode.new(verse, 'PANIN', :place_value, false).decode
    BibleCode.new(verse, 'PANIN', :numeric_value, false).decode
    BibleCode.new(verse, 'PANIN', :value, false).decode
  end

  def words
    @words ||= passage.split(' ')
  end

  def word_count
    @word_count ||= words.count
  end

  def decode
    if verbose
      words.each do |word|
        wc = BibleCode.new(word, map, value)
        printf "%20s %-80s %6s %s\n", word, *wc.decode_word
      end
      puts "-"*200
    end
    puts "words: #{word_count} words primes: #{Prime.prime_division(word_count)}"
    puts "#{mapping} #{value} sum: #{sum} sum primes: #{primes}"
  end

  def decode_word
    [numbers, sum, primes]
  end

  def break
    1.upto(words(verse).length).each do |i|
      v = words(verse)[0..-i].join(' ')
      puts "#{sum(v)} #{primes(v)} #{v}"
    end
  end

  def sum
    numbers.inject(0) { |s, n| s += n }
  end

  def numbers
    passage.chars.map { |l| map[l][value] }
  end

  def primes
    Prime.prime_division(sum)
  end
end
