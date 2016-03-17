require 'rspec'

class Checkout

  def total
    0
  end
end

describe "Checkout" do

  it "Show a zero total when empty" do
    checkout = Checkout.new
    expect(checkout.total).to eq 0
  end
end
