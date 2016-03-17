require 'rspec'
require 'pry'

class TwoForOne
  def discount
    return Proc.new do |items|
      collection = items.select{|i| i.code == "FR1" }

      #TODO: The below should calculate on multiples of two
      if collection.length == 2
        items[0].price
      else
        0
      end
    end
  end
end

class BulkPurchase
  def discount
    return Proc.new do |items|
      collection = items.select{|i| i.code == "SR1" }

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

  it "Calclates a discount for multiple item purchases" do
    pricing_rules = [TwoForOne.new]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'FR1', price: 3.11)
    item2 = Item.new(code: 'FR1', price: 3.11)
    checkout.scan(item1)
    checkout.scan(item2)

    expect(checkout.total).to eq 3.11
  end

  it "Calclates a discount for cart with mixed item purchases" do
    pricing_rules = [TwoForOne.new]
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
    pricing_rules = [BulkPurchase.new]
    checkout = Checkout.new(pricing_rules)

    item1 = Item.new(code: 'SR1', price: 5.00)
    item2 = Item.new(code: 'SR1', price: 5.00)
    item3 = Item.new(code: 'SR1', price: 5.00)
    checkout.scan(item1)
    checkout.scan(item2)
    checkout.scan(item3)

    expect(checkout.total).to eq 13.50
  end
end
