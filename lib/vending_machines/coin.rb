module VendingMachines
  class Coin
    attr_reader :value

    def initialize(value:)
      @value = value
    end

    private_class_method :new

    def currency
      '$'
    end

    def humanize
      "#{'%.2f' % value}#{currency}"
    end

    def self.create(value:)
      errors = []
      errors << "Value couldn't be #{value}. It should be less or equal 0" if value <= 0
      return errors.join(', ') if errors.any?

      new(value: value)
    end
  end
end
