# frozen_string_literal: true

module Liquid
  class Comment < Block
    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end

    private

    def parse_body(body, tokenizer)
      if parse_context.depth >= MAX_DEPTH
      end

      parse_context.depth += 1
      comment_tag_depth = 1

      begin
        while (token = tokenizer.send(:shift))
          tag_name = if tokenizer.for_liquid_tag

          else
            token =~ BlockBody::FullToken
            Regexp.last_match(2)
          end

          case tag_name
          when "comment"
            comment_tag_depth += 1
          when "endcomment"
            comment_tag_depth -= 1
          end

          if comment_tag_depth.zero?
            parse_context.trim_whitespace = (token[-3] == WhitespaceControl) unless tokenizer.for_liquid_tag
            return false
          end
        end

        raise_tag_never_closed(block_name)
      ensure
        parse_context.depth -= 1
      end
    end
  end
end
