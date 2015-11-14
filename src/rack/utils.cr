module Rack
  module Utils
    # ParameterTypeError is the error that is raised when incoming structural
    # parameters (parsed by parse_nested_query) contain conflicting types.
    class ParameterTypeError < Exception; end

    def self.build_query(params)
      params.map do |k, v|
        if v.nil?
          escape(k)
        elsif v.is_a?(Array)
          v.map do |value|
            "#{escape(k)}=#{escape(value)}"
          end.join("&")
        else
          "#{escape(k)}=#{escape(v)}"
        end
      end.join("&")
    end

    DEFAULT_SEP = /[&;] */ # had /n option for ASCII-8BIT encoding in ruby

    # Stolen from Mongrel, with some small modifications:
    # Parses a query string by breaking it up at the '&'
    # and ';' characters.  You can also use this to parse
    # cookies by changing the characters used in the second
    # parameter (which defaults to '&;').
    def self.parse_query(query_string, separator = nil)
      if separator
        separator = /[#{separator}] */
      else
        separator = DEFAULT_SEP
      end

      params = {} of String => String | Array(String)

      query_string.to_s.split(separator).each do |part|
        next if part.empty?

        # could use `k, v = part.split("=", 2).map { |string| unescape(string) }` unstead if fix: https://goo.gl/eio5RF
        split = part.split("=", 2).map { |string| unescape(string) }
        k = split[0]?.to_s
        v = split[1]?.to_s

        if cur = params[k]?
          if cur.is_a? Array
            params[k] as Array(String) << v
          else
            params[k] = [cur as String, v]
          end
        else
          params[k] = v
        end
      end

      params
    end

    alias NestedParams = Nil | String | Array(String) | Array(NestedParams) | Hash(String, NestedParams)

    # parse_nested_query expands a query string into structural types. Supported
    # types are Arrays, Hashes and basic value types. It is possible to supply
    # query strings with parameters of conflicting types, in this case a
    # ParameterTypeError is raised. Users are encouraged to return a 400 in this
    # case.
    def self.parse_nested_query(query_string)
      params = {} of String => NestedParams

      query_string.to_s.split(DEFAULT_SEP).each do |part|
        # could use `k, v = part.split("=", 2).map { |string| unescape(string) }` unstead if fix: https://goo.gl/eio5RF
        split = part.split("=", 2).map { |string| unescape(string) }
        k = split[0]?.to_s
        v = split[1]?.to_s

        normalize_params(params, k, v)
      end

      params
    end

    # normalize_params recursively expands parameters into structural types. If
    # the structural types represented by two different parameter names are in
    # conflict, a ParameterTypeError is raised.
    private def self.normalize_params(params, name, v = nil)
      if match = name.match(%r(\A[\[\]]*([^\[\]]+)\]*))
        k = match[1]
        after = name[match[0].length..-1]
      else
        k = ""
        after = ""
      end

      return if k.empty?

      if after == ""
        params[k] = v
      elsif after == "["
        params[name] = v
      elsif after == "[]"
        params[k] ||= [] of NestedParams
        raise ParameterTypeError.new("expected Array (got #{params[k].class.name}) for param `#{k}'") unless params[k].is_a?(Array)
        params[k] as Array << v
      elsif after =~ %r(^\[\]\[([^\[\]]+)\]$) || after =~ %r(^\[\](.+)$)
        child_key = $1
        params[k] ||= [] of NestedParams
        raise ParameterTypeError.new("expected Array (got #{params[k].class.name}) for param `#{k}'") unless params[k].is_a?(Array)
        array = params[k] as Array
        if array.last?.is_a?(Hash) && !(array.last as Hash).has_key?(child_key)
          normalize_params(array.last as Hash, child_key, v)
        else
          array << normalize_params(params.class.new as Hash, child_key, v)
        end
      else
        params[k] ||= params.class.new
        raise ParameterTypeError.new("expected Hash (got #{params[k].class.name}) for param `#{k}'") unless params[k].is_a?(Hash)
        params[k] = normalize_params(params[k] as Hash, after, v)
      end

      return params
    end

    TBLENCWWWCOMP_ = {"\x00"=>"%00", "\x01"=>"%01", "\x02"=>"%02", "\x03"=>"%03", "\x04"=>"%04", "\x05"=>"%05", "\x06"=>"%06", "\a"=>"%07", "\b"=>"%08", "\t"=>"%09", "\n"=>"%0A", "\v"=>"%0B", "\f"=>"%0C", "\r"=>"%0D", "\x0E"=>"%0E", "\x0F"=>"%0F", "\x10"=>"%10", "\x11"=>"%11", "\x12"=>"%12", "\x13"=>"%13", "\x14"=>"%14", "\x15"=>"%15", "\x16"=>"%16", "\x17"=>"%17", "\x18"=>"%18", "\x19"=>"%19", "\x1A"=>"%1A", "\e"=>"%1B", "\x1C"=>"%1C", "\x1D"=>"%1D", "\x1E"=>"%1E", "\x1F"=>"%1F", " "=>"+", "!"=>"%21", "\""=>"%22", "#"=>"%23", "$"=>"%24", "%"=>"%25", "&"=>"%26", "'"=>"%27", "("=>"%28", ")"=>"%29", "*"=>"%2A", "+"=>"%2B", ","=>"%2C", "-"=>"%2D", "."=>"%2E", "/"=>"%2F", "0"=>"%30", "1"=>"%31", "2"=>"%32", "3"=>"%33", "4"=>"%34", "5"=>"%35", "6"=>"%36", "7"=>"%37", "8"=>"%38", "9"=>"%39", ":"=>"%3A", ";"=>"%3B", "<"=>"%3C", "="=>"%3D", ">"=>"%3E", "?"=>"%3F", "@"=>"%40", "A"=>"%41", "B"=>"%42", "C"=>"%43", "D"=>"%44", "E"=>"%45", "F"=>"%46", "G"=>"%47", "H"=>"%48", "I"=>"%49", "J"=>"%4A", "K"=>"%4B", "L"=>"%4C", "M"=>"%4D", "N"=>"%4E", "O"=>"%4F", "P"=>"%50", "Q"=>"%51", "R"=>"%52", "S"=>"%53", "T"=>"%54", "U"=>"%55", "V"=>"%56", "W"=>"%57", "X"=>"%58", "Y"=>"%59", "Z"=>"%5A", "["=>"%5B", "\\"=>"%5C", "]"=>"%5D", "^"=>"%5E", "_"=>"%5F", "`"=>"%60", "a"=>"%61", "b"=>"%62", "c"=>"%63", "d"=>"%64", "e"=>"%65", "f"=>"%66", "g"=>"%67", "h"=>"%68", "i"=>"%69", "j"=>"%6A", "k"=>"%6B", "l"=>"%6C", "m"=>"%6D", "n"=>"%6E", "o"=>"%6F", "p"=>"%70", "q"=>"%71", "r"=>"%72", "s"=>"%73", "t"=>"%74", "u"=>"%75", "v"=>"%76", "w"=>"%77", "x"=>"%78", "y"=>"%79", "z"=>"%7A", "{"=>"%7B", "|"=>"%7C", "}"=>"%7D", "~"=>"%7E", "\x7F"=>"%7F", "\x80"=>"%80", "\x81"=>"%81", "\x82"=>"%82", "\x83"=>"%83", "\x84"=>"%84", "\x85"=>"%85", "\x86"=>"%86", "\x87"=>"%87", "\x88"=>"%88", "\x89"=>"%89", "\x8A"=>"%8A", "\x8B"=>"%8B", "\x8C"=>"%8C", "\x8D"=>"%8D", "\x8E"=>"%8E", "\x8F"=>"%8F", "\x90"=>"%90", "\x91"=>"%91", "\x92"=>"%92", "\x93"=>"%93", "\x94"=>"%94", "\x95"=>"%95", "\x96"=>"%96", "\x97"=>"%97", "\x98"=>"%98", "\x99"=>"%99", "\x9A"=>"%9A", "\x9B"=>"%9B", "\x9C"=>"%9C", "\x9D"=>"%9D", "\x9E"=>"%9E", "\x9F"=>"%9F", "\xA0"=>"%A0", "\xA1"=>"%A1", "\xA2"=>"%A2", "\xA3"=>"%A3", "\xA4"=>"%A4", "\xA5"=>"%A5", "\xA6"=>"%A6", "\xA7"=>"%A7", "\xA8"=>"%A8", "\xA9"=>"%A9", "\xAA"=>"%AA", "\xAB"=>"%AB", "\xAC"=>"%AC", "\xAD"=>"%AD", "\xAE"=>"%AE", "\xAF"=>"%AF", "\xB0"=>"%B0", "\xB1"=>"%B1", "\xB2"=>"%B2", "\xB3"=>"%B3", "\xB4"=>"%B4", "\xB5"=>"%B5", "\xB6"=>"%B6", "\xB7"=>"%B7", "\xB8"=>"%B8", "\xB9"=>"%B9", "\xBA"=>"%BA", "\xBB"=>"%BB", "\xBC"=>"%BC", "\xBD"=>"%BD", "\xBE"=>"%BE", "\xBF"=>"%BF", "\xC0"=>"%C0", "\xC1"=>"%C1", "\xC2"=>"%C2", "\xC3"=>"%C3", "\xC4"=>"%C4", "\xC5"=>"%C5", "\xC6"=>"%C6", "\xC7"=>"%C7", "\xC8"=>"%C8", "\xC9"=>"%C9", "\xCA"=>"%CA", "\xCB"=>"%CB", "\xCC"=>"%CC", "\xCD"=>"%CD", "\xCE"=>"%CE", "\xCF"=>"%CF", "\xD0"=>"%D0", "\xD1"=>"%D1", "\xD2"=>"%D2", "\xD3"=>"%D3", "\xD4"=>"%D4", "\xD5"=>"%D5", "\xD6"=>"%D6", "\xD7"=>"%D7", "\xD8"=>"%D8", "\xD9"=>"%D9", "\xDA"=>"%DA", "\xDB"=>"%DB", "\xDC"=>"%DC", "\xDD"=>"%DD", "\xDE"=>"%DE", "\xDF"=>"%DF", "\xE0"=>"%E0", "\xE1"=>"%E1", "\xE2"=>"%E2", "\xE3"=>"%E3", "\xE4"=>"%E4", "\xE5"=>"%E5", "\xE6"=>"%E6", "\xE7"=>"%E7", "\xE8"=>"%E8", "\xE9"=>"%E9", "\xEA"=>"%EA", "\xEB"=>"%EB", "\xEC"=>"%EC", "\xED"=>"%ED", "\xEE"=>"%EE", "\xEF"=>"%EF", "\xF0"=>"%F0", "\xF1"=>"%F1", "\xF2"=>"%F2", "\xF3"=>"%F3", "\xF4"=>"%F4", "\xF5"=>"%F5", "\xF6"=>"%F6", "\xF7"=>"%F7", "\xF8"=>"%F8", "\xF9"=>"%F9", "\xFA"=>"%FA", "\xFB"=>"%FB", "\xFC"=>"%FC", "\xFD"=>"%FD", "\xFE"=>"%FE", "\xFF"=>"%FF"}

    # URI escapes. (CGI style space to +)
    def self.escape(string)
      string.to_s.gsub(/[^*\-.0-9A-Z_a-z]/, TBLENCWWWCOMP_) # implementation from rubys URI.encode_www_form_component(s)
    end

    TBLDECWWWCOMP_ = {"%00"=>"\x00", "%01"=>"\x01", "%02"=>"\x02", "%03"=>"\x03", "%04"=>"\x04", "%05"=>"\x05", "%06"=>"\x06", "%07"=>"\a", "%08"=>"\b", "%09"=>"\t", "%0A"=>"\n", "%0a"=>"\n", "%0B"=>"\v", "%0b"=>"\v", "%0C"=>"\f", "%0c"=>"\f", "%0D"=>"\r", "%0d"=>"\r", "%0E"=>"\x0E", "%0e"=>"\x0E", "%0F"=>"\x0F", "%0f"=>"\x0F", "%10"=>"\x10", "%11"=>"\x11", "%12"=>"\x12", "%13"=>"\x13", "%14"=>"\x14", "%15"=>"\x15", "%16"=>"\x16", "%17"=>"\x17", "%18"=>"\x18", "%19"=>"\x19", "%1A"=>"\x1A", "%1a"=>"\x1A", "%1B"=>"\e", "%1b"=>"\e", "%1C"=>"\x1C", "%1c"=>"\x1C", "%1D"=>"\x1D", "%1d"=>"\x1D", "%1E"=>"\x1E", "%1e"=>"\x1E", "%1F"=>"\x1F", "%1f"=>"\x1F", "%20"=>" ", "%21"=>"!", "%22"=>"\"", "%23"=>"#", "%24"=>"$", "%25"=>"%", "%26"=>"&", "%27"=>"'", "%28"=>"(", "%29"=>")", "%2A"=>"*", "%2a"=>"*", "%2B"=>"+", "%2b"=>"+", "%2C"=>",", "%2c"=>",", "%2D"=>"-", "%2d"=>"-", "%2E"=>".", "%2e"=>".", "%2F"=>"/", "%2f"=>"/", "%30"=>"0", "%31"=>"1", "%32"=>"2", "%33"=>"3", "%34"=>"4", "%35"=>"5", "%36"=>"6", "%37"=>"7", "%38"=>"8", "%39"=>"9", "%3A"=>":", "%3a"=>":", "%3B"=>";", "%3b"=>";", "%3C"=>"<", "%3c"=>"<", "%3D"=>"=", "%3d"=>"=", "%3E"=>">", "%3e"=>">", "%3F"=>"?", "%3f"=>"?", "%40"=>"@", "%41"=>"A", "%42"=>"B", "%43"=>"C", "%44"=>"D", "%45"=>"E", "%46"=>"F", "%47"=>"G", "%48"=>"H", "%49"=>"I", "%4A"=>"J", "%4a"=>"J", "%4B"=>"K", "%4b"=>"K", "%4C"=>"L", "%4c"=>"L", "%4D"=>"M", "%4d"=>"M", "%4E"=>"N", "%4e"=>"N", "%4F"=>"O", "%4f"=>"O", "%50"=>"P", "%51"=>"Q", "%52"=>"R", "%53"=>"S", "%54"=>"T", "%55"=>"U", "%56"=>"V", "%57"=>"W", "%58"=>"X", "%59"=>"Y", "%5A"=>"Z", "%5a"=>"Z", "%5B"=>"[", "%5b"=>"[", "%5C"=>"\\", "%5c"=>"\\", "%5D"=>"]", "%5d"=>"]", "%5E"=>"^", "%5e"=>"^", "%5F"=>"_", "%5f"=>"_", "%60"=>"`", "%61"=>"a", "%62"=>"b", "%63"=>"c", "%64"=>"d", "%65"=>"e", "%66"=>"f", "%67"=>"g", "%68"=>"h", "%69"=>"i", "%6A"=>"j", "%6a"=>"j", "%6B"=>"k", "%6b"=>"k", "%6C"=>"l", "%6c"=>"l", "%6D"=>"m", "%6d"=>"m", "%6E"=>"n", "%6e"=>"n", "%6F"=>"o", "%6f"=>"o", "%70"=>"p", "%71"=>"q", "%72"=>"r", "%73"=>"s", "%74"=>"t", "%75"=>"u", "%76"=>"v", "%77"=>"w", "%78"=>"x", "%79"=>"y", "%7A"=>"z", "%7a"=>"z", "%7B"=>"{", "%7b"=>"{", "%7C"=>"|", "%7c"=>"|", "%7D"=>"}", "%7d"=>"}", "%7E"=>"~", "%7e"=>"~", "%7F"=>"\x7F", "%7f"=>"\x7F", "%80"=>"\x80", "%81"=>"\x81", "%82"=>"\x82", "%83"=>"\x83", "%84"=>"\x84", "%85"=>"\x85", "%86"=>"\x86", "%87"=>"\x87", "%88"=>"\x88", "%89"=>"\x89", "%8A"=>"\x8A", "%8a"=>"\x8A", "%8B"=>"\x8B", "%8b"=>"\x8B", "%8C"=>"\x8C", "%8c"=>"\x8C", "%8D"=>"\x8D", "%8d"=>"\x8D", "%8E"=>"\x8E", "%8e"=>"\x8E", "%8F"=>"\x8F", "%8f"=>"\x8F", "%90"=>"\x90", "%91"=>"\x91", "%92"=>"\x92", "%93"=>"\x93", "%94"=>"\x94", "%95"=>"\x95", "%96"=>"\x96", "%97"=>"\x97", "%98"=>"\x98", "%99"=>"\x99", "%9A"=>"\x9A", "%9a"=>"\x9A", "%9B"=>"\x9B", "%9b"=>"\x9B", "%9C"=>"\x9C", "%9c"=>"\x9C", "%9D"=>"\x9D", "%9d"=>"\x9D", "%9E"=>"\x9E", "%9e"=>"\x9E", "%9F"=>"\x9F", "%9f"=>"\x9F", "%A0"=>"\xA0", "%a0"=>"\xA0", "%A1"=>"\xA1", "%a1"=>"\xA1", "%A2"=>"\xA2", "%a2"=>"\xA2", "%A3"=>"\xA3", "%a3"=>"\xA3", "%A4"=>"\xA4", "%a4"=>"\xA4", "%A5"=>"\xA5", "%a5"=>"\xA5", "%A6"=>"\xA6", "%a6"=>"\xA6", "%A7"=>"\xA7", "%a7"=>"\xA7", "%A8"=>"\xA8", "%a8"=>"\xA8", "%A9"=>"\xA9", "%a9"=>"\xA9", "%AA"=>"\xAA", "%aA"=>"\xAA", "%Aa"=>"\xAA", "%aa"=>"\xAA", "%AB"=>"\xAB", "%aB"=>"\xAB", "%Ab"=>"\xAB", "%ab"=>"\xAB", "%AC"=>"\xAC", "%aC"=>"\xAC", "%Ac"=>"\xAC", "%ac"=>"\xAC", "%AD"=>"\xAD", "%aD"=>"\xAD", "%Ad"=>"\xAD", "%ad"=>"\xAD", "%AE"=>"\xAE", "%aE"=>"\xAE", "%Ae"=>"\xAE", "%ae"=>"\xAE", "%AF"=>"\xAF", "%aF"=>"\xAF", "%Af"=>"\xAF", "%af"=>"\xAF", "%B0"=>"\xB0", "%b0"=>"\xB0", "%B1"=>"\xB1", "%b1"=>"\xB1", "%B2"=>"\xB2", "%b2"=>"\xB2", "%B3"=>"\xB3", "%b3"=>"\xB3", "%B4"=>"\xB4", "%b4"=>"\xB4", "%B5"=>"\xB5", "%b5"=>"\xB5", "%B6"=>"\xB6", "%b6"=>"\xB6", "%B7"=>"\xB7", "%b7"=>"\xB7", "%B8"=>"\xB8", "%b8"=>"\xB8", "%B9"=>"\xB9", "%b9"=>"\xB9", "%BA"=>"\xBA", "%bA"=>"\xBA", "%Ba"=>"\xBA", "%ba"=>"\xBA", "%BB"=>"\xBB", "%bB"=>"\xBB", "%Bb"=>"\xBB", "%bb"=>"\xBB", "%BC"=>"\xBC", "%bC"=>"\xBC", "%Bc"=>"\xBC", "%bc"=>"\xBC", "%BD"=>"\xBD", "%bD"=>"\xBD", "%Bd"=>"\xBD", "%bd"=>"\xBD", "%BE"=>"\xBE", "%bE"=>"\xBE", "%Be"=>"\xBE", "%be"=>"\xBE", "%BF"=>"\xBF", "%bF"=>"\xBF", "%Bf"=>"\xBF", "%bf"=>"\xBF", "%C0"=>"\xC0", "%c0"=>"\xC0", "%C1"=>"\xC1", "%c1"=>"\xC1", "%C2"=>"\xC2", "%c2"=>"\xC2", "%C3"=>"\xC3", "%c3"=>"\xC3", "%C4"=>"\xC4", "%c4"=>"\xC4", "%C5"=>"\xC5", "%c5"=>"\xC5", "%C6"=>"\xC6", "%c6"=>"\xC6", "%C7"=>"\xC7", "%c7"=>"\xC7", "%C8"=>"\xC8", "%c8"=>"\xC8", "%C9"=>"\xC9", "%c9"=>"\xC9", "%CA"=>"\xCA", "%cA"=>"\xCA", "%Ca"=>"\xCA", "%ca"=>"\xCA", "%CB"=>"\xCB", "%cB"=>"\xCB", "%Cb"=>"\xCB", "%cb"=>"\xCB", "%CC"=>"\xCC", "%cC"=>"\xCC", "%Cc"=>"\xCC", "%cc"=>"\xCC", "%CD"=>"\xCD", "%cD"=>"\xCD", "%Cd"=>"\xCD", "%cd"=>"\xCD", "%CE"=>"\xCE", "%cE"=>"\xCE", "%Ce"=>"\xCE", "%ce"=>"\xCE", "%CF"=>"\xCF", "%cF"=>"\xCF", "%Cf"=>"\xCF", "%cf"=>"\xCF", "%D0"=>"\xD0", "%d0"=>"\xD0", "%D1"=>"\xD1", "%d1"=>"\xD1", "%D2"=>"\xD2", "%d2"=>"\xD2", "%D3"=>"\xD3", "%d3"=>"\xD3", "%D4"=>"\xD4", "%d4"=>"\xD4", "%D5"=>"\xD5", "%d5"=>"\xD5", "%D6"=>"\xD6", "%d6"=>"\xD6", "%D7"=>"\xD7", "%d7"=>"\xD7", "%D8"=>"\xD8", "%d8"=>"\xD8", "%D9"=>"\xD9", "%d9"=>"\xD9", "%DA"=>"\xDA", "%dA"=>"\xDA", "%Da"=>"\xDA", "%da"=>"\xDA", "%DB"=>"\xDB", "%dB"=>"\xDB", "%Db"=>"\xDB", "%db"=>"\xDB", "%DC"=>"\xDC", "%dC"=>"\xDC", "%Dc"=>"\xDC", "%dc"=>"\xDC", "%DD"=>"\xDD", "%dD"=>"\xDD", "%Dd"=>"\xDD", "%dd"=>"\xDD", "%DE"=>"\xDE", "%dE"=>"\xDE", "%De"=>"\xDE", "%de"=>"\xDE", "%DF"=>"\xDF", "%dF"=>"\xDF", "%Df"=>"\xDF", "%df"=>"\xDF", "%E0"=>"\xE0", "%e0"=>"\xE0", "%E1"=>"\xE1", "%e1"=>"\xE1", "%E2"=>"\xE2", "%e2"=>"\xE2", "%E3"=>"\xE3", "%e3"=>"\xE3", "%E4"=>"\xE4", "%e4"=>"\xE4", "%E5"=>"\xE5", "%e5"=>"\xE5", "%E6"=>"\xE6", "%e6"=>"\xE6", "%E7"=>"\xE7", "%e7"=>"\xE7", "%E8"=>"\xE8", "%e8"=>"\xE8", "%E9"=>"\xE9", "%e9"=>"\xE9", "%EA"=>"\xEA", "%eA"=>"\xEA", "%Ea"=>"\xEA", "%ea"=>"\xEA", "%EB"=>"\xEB", "%eB"=>"\xEB", "%Eb"=>"\xEB", "%eb"=>"\xEB", "%EC"=>"\xEC", "%eC"=>"\xEC", "%Ec"=>"\xEC", "%ec"=>"\xEC", "%ED"=>"\xED", "%eD"=>"\xED", "%Ed"=>"\xED", "%ed"=>"\xED", "%EE"=>"\xEE", "%eE"=>"\xEE", "%Ee"=>"\xEE", "%ee"=>"\xEE", "%EF"=>"\xEF", "%eF"=>"\xEF", "%Ef"=>"\xEF", "%ef"=>"\xEF", "%F0"=>"\xF0", "%f0"=>"\xF0", "%F1"=>"\xF1", "%f1"=>"\xF1", "%F2"=>"\xF2", "%f2"=>"\xF2", "%F3"=>"\xF3", "%f3"=>"\xF3", "%F4"=>"\xF4", "%f4"=>"\xF4", "%F5"=>"\xF5", "%f5"=>"\xF5", "%F6"=>"\xF6", "%f6"=>"\xF6", "%F7"=>"\xF7", "%f7"=>"\xF7", "%F8"=>"\xF8", "%f8"=>"\xF8", "%F9"=>"\xF9", "%f9"=>"\xF9", "%FA"=>"\xFA", "%fA"=>"\xFA", "%Fa"=>"\xFA", "%fa"=>"\xFA", "%FB"=>"\xFB", "%fB"=>"\xFB", "%Fb"=>"\xFB", "%fb"=>"\xFB", "%FC"=>"\xFC", "%fC"=>"\xFC", "%Fc"=>"\xFC", "%fc"=>"\xFC", "%FD"=>"\xFD", "%fD"=>"\xFD", "%Fd"=>"\xFD", "%fd"=>"\xFD", "%FE"=>"\xFE", "%fE"=>"\xFE", "%Fe"=>"\xFE", "%fe"=>"\xFE", "%FF"=>"\xFF", "%fF"=>"\xFF", "%Ff"=>"\xFF", "%ff"=>"\xFF", "+"=>" "}

    # Unescapes a URI escaped string with +encoding+. +encoding+ will be the
    # target encoding of the string returned, and it defaults to UTF-8
    def self.unescape(string)
      string.gsub(/\+|%[0-9a-fA-F]{2}/, TBLDECWWWCOMP_) # implementation from rubys URI.decode_www_form_component
    end

    def self.parse_cookies(headers)
      # According to RFC 2109:
      #   If multiple cookies satisfy the criteria above, they are ordered in
      #   the Cookie header such that those with more specific Path attributes
      #   precede those with less specific.  Ordering with respect to other
      #   attributes (e.g., Domain) is unspecified.

      cookies = parse_query headers["Cookie"]?, ";,"

      hash = {} of String => String
      cookies.each() do |k, v|
        hash[k] = v.is_a?(Array) ? v.first : v
      end
      hash
    end

    def self.set_cookie_header!(headers, key, values,
        domain = nil,
        path = nil,
        max_age = nil,
        secure = nil,
        expires = nil,
        httponly = nil
      )
      headers["Set-Cookie"] = make_cookie_header(
        headers.get?("Set-Cookie"), key, values,
        domain: domain,
        path: path,
        max_age: max_age,
        secure: secure,
        expires: expires,
        httponly: httponly
      )
    end

    def self.delete_cookie_header!(headers, key, domain = nil, path = nil)
      new_header = make_delete_cookie_header(headers.get("Set-Cookie"), key, domain: domain, path: path)

      headers["Set-Cookie"] = make_cookie_header(
        new_header, key, "",
        path: path,
        domain: domain,
        max_age: "0",
        expires: Time.epoch(0)
      )
    end

    private def self.make_cookie_header(current_cookies, key, values,
        domain = nil,
        path = nil,
        max_age = nil,
        secure = nil,
        expires = nil,
        httponly = nil
      ) : Array(String)
      # There is an RFC mess in the area of date formatting for Cookies. Not
      # only are there contradicting RFCs and examples within RFC text, but
      # there are also numerous conflicting names of fields and partially
      # cross-applicable specifications.
      #
      # These are best described in RFC 2616 3.3.1. This RFC text also
      # specifies that RFC 822 as updated by RFC 1123 is preferred. That is a
      # fixed length format with space-date delimeted fields.
      #
      # See also RFC 1123 section 5.2.14.
      #
      # RFC 6265 also specifies "sane-cookie-date" as RFC 1123 date, defined
      # in RFC 2616 3.3.1. RFC 6265 also gives examples that clearly denote
      # the space delimited format. These formats are compliant with RFC 2822.
      #
      # For reference, all involved RFCs are:
      # RFC 822
      # RFC 1123
      # RFC 2109
      # RFC 2616
      # RFC 2822
      # RFC 2965
      # RFC 6265

      current_cookies ||= [] of String
      values = [values] unless values.is_a?(Array)
      domain  = "; domain=#{domain}" if domain
      path = "; path=#{path}" if path
      max_age = "; max-age=#{max_age}" if max_age
      expires = "; expires=#{rfc2822(expires.to_utc)}" if expires
      secure = "; secure" if secure
      httponly = "; HttpOnly" if httponly

      cookie = "#{escape(key)}=#{values.map { |v| escape v }.join('&')}#{domain}" \
        "#{path}#{max_age}#{expires}#{secure}#{httponly}"

      current_cookies.concat([cookie])
    end

    private def self.make_delete_cookie_header(current_cookies, key, domain = nil, path = nil) : Array(String)
      current_cookies.reject do |cookie|
        if domain
          cookie =~ /\A#{escape(key)}=.*domain=#{domain}/
        elsif path
          cookie =~ /\A#{escape(key)}=.*path=#{path}/
        else
          cookie =~ /\A#{escape(key)}=/
        end
      end
    end

    private def self.rfc2822(time)
      raise ArgumentError.new("time must be UTC since utc_offset isn't implemented yet") unless time.utc?

      time.to_s("%a, %d %b %Y %T -0000")
    end
  end
end
