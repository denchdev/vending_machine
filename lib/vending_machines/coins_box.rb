require_relative 'errors'
require_relative 'coin'

module VendingMachines
  class CoinBox
    attr_reader :coins

    def initialize
      @coins = {}
    end

    def add!(coin)
      raise Errors::IncorrectCoinError unless coin.is_a?(VendingMachines::Coin)

      @coins[coin.value] ||= []
      @coins[coin.value] << coin
    end

    def import!(coins)
      errors = []
      coins.each do |attributes|
        attributes.transform_keys!(&:to_sym)
        errors << "Count couldn't be #{attributes[:count]}. It should be less or equal 0." if attributes[:count] <= 0
        attributes[:count].times do
          coin = VendingMachines::Coin.create(value: attributes[:value])
          if coin.is_a?(String)
            errors << coin
            next
          end
          add!(coin)
        end
      end

      errors
    end

    def remove!(coin_value)
      @coins[coin_value].pop if @coins.key?(coin_value)
    end

    def remove_all!(coin_value)
      @coins[coin_value] = [] if @coins.key?(coin_value)
    end

    def empty_out!
      @coins = {}
    end
  end
end
