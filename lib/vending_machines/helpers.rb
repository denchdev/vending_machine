module VendingMachines
  class Helpers
    def self.humanize_money(amount, currency)
      "#{ '%.2f' % amount }#{ currency }"
    end
  end
end
