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
    0
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
end
