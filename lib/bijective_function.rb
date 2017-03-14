# REF: https://gist.github.com/zumbojo/1073996

# Simple bijective function
# Basically encodes any integer into a base(n) string, where n is ALPHABET.length.
# Based on pseudocode from http://stackoverflow.com/questions/742013/how-to-code-a-url-shortener/742047#742047

ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//)

class BijectiveFunction
  def self.encode(i)
    # REF: http://refactormycode.com/codes/125-base-62-encoding (with only minor modification)
    return ALPHABET[0] if i == 0
    s = ''
    base = ALPHABET.length
    while i > 0
      s << ALPHABET[i.modulo(base)]
      i /= base
    end
    s.reverse
  end
  
  def self.decode(s)
    # REF: Based on base2dec() in Tcl translation at http://rosettacode.org/wiki/Non-decimal_radices/Convert#Ruby
    i = 0
    base = ALPHABET.length
    s.each_char { |c| i = i * base + ALPHABET.index(c) }
    i
  end
end
