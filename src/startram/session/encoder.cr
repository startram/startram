require "openssl/hmac"

module Startram
  class Session
    class Encoder
      def initialize(@secret_key_base)
      end

      def encode(cookie_string)
        "#{cookie_string}--#{generate_digest(cookie_string)}"
      end

      def decode(cookie_string : String)
        split = cookie_string.reverse.split("--", 2)
        return "" unless split.length == 2

        digest, session_data = split
        digest = digest.reverse
        session_data = session_data.reverse
        if digest_match?(session_data, digest)
          session_data
        else
          ""
        end
      end

      private def generate_digest(cookie_string)
        OpenSSL::HMAC.hexdigest(:sha1, @secret_key_base, cookie_string)
      end

      private def digest_match?(data, digest)
        return unless data && digest

        digest == generate_digest(data)
      end
    end
  end
end
