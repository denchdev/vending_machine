Dir['./vending_machines/*.rb'].each { |file| require_relative file }

class VendingMachine
  attr_reader :coin_box, :product_box, :display, :available_coins, :need_preload_products, :need_preload_coins

  def initialize(need_preload_products: false, need_preload_coins: false)
    # Initialize inner component of Vending Machine
    @coin_box = VendingMachines::CoinBox.new
    @product_box = VendingMachines::ProductBox.new
    @display = VendingMachines::Display.new
    @need_preload_products = need_preload_products
    @need_preload_coins = need_preload_coins
    # Load configs and prepared data
    load_configs
    import_products
    import_coins

    # start main process
    process
  end

  def import_products
    return unless need_preload_products

    imported_products = YAML.load_file('config/products.yaml')['products']
    errors = product_box.import!(imported_products)
    errors.each { |e| display.error_message(e) }
  end

  def import_coins
    return unless need_preload_coins

    imported_coins = YAML.load_file('config/coins.yaml')['coins']
    errors = coin_box.import!(imported_coins)
    errors.each { |e| display.error_message(e) }
  end

  def process
    display.welcome_message
    loop do
      # Show table of products
      display.products_table(products: product_box.products_table)
      # Show options of products
      product = display.product_options(list: product_box.products_list)
      # Approve selection
      display.selected_product(product: product)

      purchase = VendingMachines::Purchase.new(product_name: product.name, amount: product.price)
      # process payment
      process_payment(purchase)
      # process change
      after_change_option = process_change(purchase)

      display.success_purchase(product: product) if after_change_option == 0

      break unless display.continue?
    end
    display.goodbye
  end

  def process_payment(purchase)
    # Show options of coins
    first_coin = display.coin_options(available_coins)
    insert_coin(purchase, first_coin)
    process_more_coin(purchase) if purchase.amount > first_coin
  end

  def process_more_coin(purchase)
    # Show amount of inserted coins and remaining
    display.more_coins(paid: purchase.humanize_inserted_amount, remaining: purchase.humanize_needed_amount)
    # Show options of coins
    coin = display.coin_options(available_coins)
    insert_coin(purchase, coin)
    process_more_coin(purchase) unless purchase.paid?
  end

  def process_change(purchase)
    # variable that return response code of method
    after_change_option = 0
    if purchase.need_change?
      purchase.change = purchase.inserted_amount - purchase.amount
      change = prepare_change(purchase.change)
      change_list = change[:prepared_charge].map do |k,v|
        [VendingMachines::Helpers.humanize_money(k.to_f / 100, '$'), v]
      end
      table = TTY::Table.new(header: %w[Coin Count], rows: change_list)
      puts table.render(:ascii)

      if change[:needed_change_amount] > 0
        display.error_message('Change can\'t be collected.')
        options_list = [
          { name: 'Donate change for kittens', value: 0 },
          { name: 'Return money', value: 1 }
        ]
        after_change_option = display.after_change_options(list: options_list)
        if after_change_option == 0
          display.success_message('One more kitten will be save!!!')
        elsif after_change_option == 1
          display.success_message('Please prepare needed amount of money.')
          change = prepare_change(purchase.inserted_amount)
          change_list = change[:prepared_charge].map do |k,v|
            [VendingMachines::Helpers.humanize_money(k.to_f / 100, '$'), v]
          end
          table = TTY::Table.new(header: %w[Coin Count], rows: change_list)
          puts table.render(:ascii)
        end
        change[:prepared_charge].each do |coin_value, coin_count|
          coin_count.times do
            coin_box.remove!(coin_value)
          end
        end
      end
    end
    after_change_option
  end

  def prepare_change(change_amount)
    prepared_charge = {}
    needed_change_amount = change_amount
    sorted_coin_values = coin_box.coins.keys.sort.reverse

    sorted_coin_values.each do |coin_value|
      next if needed_change_amount < coin_value

      needed_coins = needed_change_amount / coin_value
      coins_in_box = coin_box.coins[coin_value].size
      prepared_charge[coin_value] = [needed_coins, coins_in_box].min
      needed_change_amount -= coin_value * prepared_charge[coin_value]
    end

    { prepared_charge: prepared_charge, needed_change_amount: needed_change_amount }
  end

  def insert_coin(purchase, value)
    # Add inserted coin to purchase
    purchase.insert_coin(value)
    # Add inserted coin into coin box
    coin_box.add!(VendingMachines::Coin.create(value: value))
  end

  def load_configs
    @available_coins = YAML.load_file('config/available_coins.yaml')['coins']
    @available_coins.each{ |coin| coin.transform_keys!(&:to_sym) }
  rescue Errno::ENOENT
    display.error_message('Configs wasn\'t loaded')
  end
end
