# frozen_string_literal: true

class Numeric
  def to_human(len = 3)
    num = to_human_simple

    len += 1 if num.index('.')&.send(:<, len)
    return num if num.length <= len

    format('%<str>g', str: num.first(len)) + num.match(/[A-Z]$/).to_s
  end

  private

  def to_human_simple
    case
    when self < 1_000 then to_human_format(1, '%g')
    when self < 1_000_000 then to_human_format(1_000, '%gK')
    when self < 1_000_000_000 then to_human_format(1_000_000, '%gM')
    when self < 1_000_000_000_000 then to_human_format(1_000_000_000, '%gG')
    else to_human_format(1_000_000_000_000, '%gT')
    end
  end

  def to_human_format(denominator, format)
    format format, (to_f / denominator)
  end
end
