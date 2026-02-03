Customer.destroy_all

Customer.create!([
  { customer_name: "Jeison Poveda", address: "Bogotá, CO", orders_count: 0 },
  { customer_name: "Ana Gómez", address: "Medellín, CO", orders_count: 0 },
  { customer_name: "Carlos Pérez", address: "Cali, CO", orders_count: 0 }
])

puts "Seeded #{Customer.count} customers"
