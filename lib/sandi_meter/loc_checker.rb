module SandiMeter
  class LOCChecker < Struct.new(:file_lines)

    MAX_LOC = {
      'def'   => 5,
      'class' => 100
    }

    def check(params, token)
      _, first_line, last_line = params
      locs_size(first_line, last_line) <= MAX_LOC[token]
    end

    private
    def locs_size(first_line, last_line)
      last_line - first_line - 1
    end
  end
end
