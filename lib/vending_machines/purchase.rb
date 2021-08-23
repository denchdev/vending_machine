require_relative 'helpers'

module VendingMachines
  class Purchase
    attr_accessor :product_name, :amount, :inserted_amount, :change, :start_at, :end_at, :status

    STATUSES = %w[initialized in_progress canceled successfully].freeze

    def initialize(product_name:, amount:)
      @product_name = product_name
      @amount = amount
      @start_at = Time.now
      @status = STATUSES[0]
      @inserted_amount = 0
    end

    def insert_coin(amount)
      @status = STATUSES[1] unless @status == STATUSES[1]
      @inserted_amount += amount
      @status = STATUSES[3] if paid?
    end

    def paid?
      inserted_amount >= amount
    end

    def needed_amount
      amount - inserted_amount
    end

    def need_change?
      inserted_amount - amount > 0
    end

    def currency
      '$'
    end

    def humanize_amount
      p = amount.to_f / 100
      VendingMachines::Helpers.humanize_money(p, currency)
    end

    def humanize_inserted_amount
      p = inserted_amount.to_f / 100
      VendingMachines::Helpers.humanize_money(p, currency)
    end

    def humanize_needed_amount
      p = needed_amount.to_f / 100
      VendingMachines::Helpers.humanize_money(p, currency)
    end
  end
end
