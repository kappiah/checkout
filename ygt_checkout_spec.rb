require 'rspec'

class TwoForOne
  def initialize(codes:)
    @codes = codes
  end

  def discount
    return Proc.new do |items|
      collection = items.select{|i| i.code == @codes }

      if collection.size >= 2
        collection[0].price * collection.each_slice(2).reject{|a| a.size != 2}.size
      else
        0
      end
    end
  end
end

class BulkPurchase
  def initialize(codes:)
    @codes = codes
  end

  def discount
    return Proc.new do |items|
      collection = items.select{|i| i.code == @codes }

      if collection.length >= 3
        collection.length * 0.50
      else
        0
      end
    end
  end
end

class Item
  attr_reader :code, :price

  def initialize(price:, code:)
    @price = price
    @code = code
  end
end

class Checkout
  attr_reader :items

  def initialize(pricing_rules)
    @items = []
    @pricing_rules = pricing_rules
  end

  def scan(item)
    @items << item
  end

  def total
    total = @items.inject(0.0) {|total, item | total + item.price }
    item_discounts = @pricing_rules.map {|rule| rule.discount.call(@items) }
    discounts = item_discounts.inject(0.0) {|total, discount| total + discount }

    total - discounts
  end
end

describe "Checkout" do

  it "Show a zero total when empty" do
    pricing_rules = []
    checkout = Checkout.new(pricing_rules)
    expect(checkout.total).to eq 0
  end

  it "scans items into the cart" do
    pricing_rules = []
    checkout = Checkout.new(pricing_rules)
    item = double
    checkout.scan(item)

    expect(checkout.items.length).to eq 1
  end

  it "Calcuates a total for all items in the cart" do
    pricing_rules = []
    checkout = Checkout.new(pricing_rules)
    item1 = Item.new(code: 'FR1', price: 5.0)
    item2 = Item.new(code: 'FR1', price: 3.0)
    checkout.scan(item1)
    checkout.scan(item2)

    expect(checkout.total).to eq 8.0
  end

  it "Calclates a discount for cart with mixed item purchases" do
    pricing_rules = [TwoForOne.new(codes: "FR1")]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'FR1', price: 3.11)
    item2 = Item.new(code: 'FR1', price: 3.11)
    item3 = Item.new(code: 'SR1', price: 5.00)
    checkout.scan(item1)
    checkout.scan(item2)
    checkout.scan(item3)

    expect(checkout.total).to eq 8.11
  end

  it "Calclates a discount for cart with mixed item purchases" do
    pricing_rules = [BulkPurchase.new(codes: "SR1")]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'SR1', price: 5.00)
    item2 = Item.new(code: 'SR1', price: 5.00)
    item3 = Item.new(code: 'SR1', price: 5.00)
    checkout.scan(item1)
    checkout.scan(item2)
    checkout.scan(item3)

    expect(checkout.total).to eq 13.50
  end

  it "Test data - 1 -- Calclates a discount for cart with mixed item purchases" do
    pricing_rules = [BulkPurchase.new(codes: "SR1"), TwoForOne.new(codes: "FR1")]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'FR1', price: 3.11)
    item2 = Item.new(code: 'SR1', price: 5.00)
    item3 = Item.new(code: 'FR1', price: 3.11)
    item4 = Item.new(code: 'FR1', price: 3.11)
    item5 = Item.new(code: 'CF1', price: 11.23)
    checkout.scan(item1)
    checkout.scan(item2)
    checkout.scan(item3)
    checkout.scan(item4)
    checkout.scan(item5)

    expect(checkout.total).to eq 22.45
  end

  it "Test data - 2 -- Calclates a discount for multiple item purchases" do
    pricing_rules = [BulkPurchase.new(codes: "SR1"), TwoForOne.new(codes: "FR1")]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'FR1', price: 3.11)
    item2 = Item.new(code: 'FR1', price: 3.11)
    checkout.scan(item1)
    checkout.scan(item2)

    expect(checkout.total).to eq 3.11
  end

  it "Test data - 3 -- Calclates a discount for cart with mixed item purchases" do
    pricing_rules = [BulkPurchase.new(codes: "SR1"), TwoForOne.new(codes: "FR1")]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'SR1', price: 5.00)
    item2 = Item.new(code: 'SR1', price: 5.00)
    item3 = Item.new(code: 'FR1', price: 3.11)
    item4 = Item.new(code: 'SR1', price: 5.00)
    checkout.scan(item1)
    checkout.scan(item2)
    checkout.scan(item3)
    checkout.scan(item4)

    expect(checkout.total).to eq 16.61
  end
end
