# frozen_string_literal: true

module StripAttributes
  def strip_attributes(*attributes)
    before_validation do
      attributes.each do |attribute|
        normalized_value = send(attribute).try(:strip)
        send("#{attribute}=", normalized_value)
      end
    end
  end
end
