products = [
  {
    name: "Wireless Bluetooth Headphones",
    description: "Over-ear headphones with active noise cancellation. 30-hour battery life.",
    price_cents: 7999,
    inventory_count: 25
  },
  {
    name: "Stainless Steel Water Bottle",
    description: "Double-walled insulated bottle. Keeps drinks cold 24hrs or hot 12hrs. 750ml capacity.",
    price_cents: 2499,
    inventory_count: 50
  },
  {
    name: "Mechanical Keyboard",
    description: "RGB backlit keyboard with tactile switches. USB-C connection. Compact 75% layout.",
    price_cents: 8999,
    inventory_count: 15
  },
  {
    name: "Portable Phone Charger",
    description: "20,000mAh power bank with fast charging. Charges most phones 4-5 times.",
    price_cents: 3499,
    inventory_count: 40
  },
  {
    name: "Desk Lamp with USB Port",
    description: "LED desk lamp with adjustable brightness. Built-in USB charging port.",
    price_cents: 4499,
    inventory_count: 30
  },
  {
    name: "Canvas Backpack",
    description: "Durable everyday backpack with laptop compartment. Fits 15-inch laptops.",
    price_cents: 5999,
    inventory_count: 20
  }
]

products.each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |p|
    p.description = attrs[:description]
    p.price_cents = attrs[:price_cents]
    p.inventory_count = attrs[:inventory_count]
    p.active = true
  end
end

puts "Created #{Product.count} products"