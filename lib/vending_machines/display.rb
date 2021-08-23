%w[tty-prompt tty-table pry].each do |lib|
  require lib
end

module VendingMachines
  class Display
    PROMPT = TTY::Prompt.new(symbols: { marker: '=>' }, interrupt: :exit)

    def welcome_message
      PROMPT.ok("Welcome to the Vending Machine!")
    end

    def product_options(list:)
      product_list = list.map { |product| product_details(product: product) }
      product_list << { name: 'back', value: nil }

      PROMPT.select("Select product please", product_list)
    end

    def products_table(products:)
      table = TTY::Table.new(header: %w[Product Price Quantity], rows: products)
      puts table.render(:ascii)
    end

    def product_details(product:)
      {
        name: product.name,
        value: product
      }
    end

    def success_message(message)
      PROMPT.ok(message)
    end

    def error_message(message)
      PROMPT.error(message)
    end

    def selected_product(product:)
      PROMPT.ok("Selected #{product.name}. Please pay #{product.humanize_price}")
    end

    def coin_options(coins)
      PROMPT.select("Insert a coin", coins)
    end

    def more_coins(paid:, remaining:)
      PROMPT.ok("Paid #{paid}.")
      PROMPT.warn("#{remaining} remaining")
    end

    def after_change_options(list:)
      PROMPT.select("Would you like", list)
    end

    def success_purchase(product:)
      PROMPT.ok('#####')
      PROMPT.ok("Here is your: #{product.name}")
      PROMPT.ok('Thank you for choosing our machine!!!')
      PROMPT.ok('#####')
    end

    def continue?
      PROMPT.yes?('Continue?')
    end

    def goodbye
      PROMPT.ok("Goodbye!")
    end
  end
end
