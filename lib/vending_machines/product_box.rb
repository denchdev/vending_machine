require_relative 'errors'
require_relative 'product'

module VendingMachines
  class ProductBox
    attr_reader :products

    def initialize
      @products = {}
    end

    def add!(product)
      raise Errors::IncorrectProductError unless product.is_a?(VendingMachines::Product)

      @products[product.name] ||= []
      @products[product.name] << product
    end

    def import!(products)
      errors = []
      products.each do |attributes|
        attributes.transform_keys!(&:to_sym)
        errors << "Price couldn't be #{attributes[:count]}. It should be less or equal 0." if attributes[:count] <= 0
        attributes[:count].times do
          product = VendingMachines::Product.create(name: attributes[:name], price: attributes[:price])
          if product.is_a?(String)
            errors << product
            next
          end
          add!(product)
        end
      end

      errors
    end

    def remove!(product_name)
      @coins[product_name].pop if @coins.key?(product_name)
    end

    def remove_all!(product_name)
      @coins[product_name] = [] if @coins.key?(product_name)
    end

    def empty_out!
      @products = {}
    end

    def products_list
      products.values.map(&:first)
    end

    def products_table
      products.values.map do |products_array|
        [products_array.first.name, products_array.first.humanize_price, products_array.size]
      end
    end
  end
end
