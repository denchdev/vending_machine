require_relative 'helpers'

module VendingMachines
  class Product
    attr_reader :name, :price

    def initialize(name:, price:)
      @name = name
      @price = price
    end

    private_class_method :new

    def currency
      '$'
    end

    def humanize_price
      p = price.to_f / 100
      VendingMachines::Helpers.humanize_money(p, currency)
    end

    def self.create(name:, price:)
      errors = []
      errors << "Price couldn't be #{price}. It should be less or equal 0." if price <= 0
      return errors.join(', ') if errors.any?

      new(name: name, price: price)
    end
  end
end
