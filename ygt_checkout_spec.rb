require 'rspec'

class Checkout
  attr_reader :items

  def initialize
    @items = []
  end

  def scan(item)
    @items << item
  end

  def total
    @items.inject(0.0) {|total, item | total + item.price }
  end
end

describe "Checkout" do

  it "Show a zero total when empty" do
    checkout = Checkout.new
    expect(checkout.total).to eq 0
  end

  it "scans items into the cart" do
    checkout = Checkout.new
    item = double
    checkout.scan(item)

    expect(checkout.items.length).to eq 1
  end

  it "Calcuates a total for all items in the cart" do
    checkout = Checkout.new
    item1 = double(price: 5.0)
    item2 = double(price: 3.0)
    checkout.scan(item1)
    checkout.scan(item2)

    expect(checkout.total).to eq 8.0
  end
end
