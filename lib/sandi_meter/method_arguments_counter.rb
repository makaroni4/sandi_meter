module SandiMeter
  class MethodArgumentsCounter
    def initialize
      reset!
    end

    def count(args_add_block_sexp)
      reset!

      @count += args_add_block_sexp[1].size
      @count += 1 if args_add_block_sexp.last == true
      bypass_sexp(args_add_block_sexp)

      return [@count, @lines.uniq.sort.first]
    end

    def reset!
      @count = 0
      @lines = []
    end

    private
    def bypass_sexp(args_add_block_sexp)
      args_add_block_sexp.each do |sexp|
        next unless sexp.kind_of?(Array)

        case sexp.first
        when :bare_assoc_hash
          @count += sexp[1].size - 1
        when :@int, :@ident
          @lines << sexp.last.first
        end

        bypass_sexp(sexp)
      end
    end
  end
end
