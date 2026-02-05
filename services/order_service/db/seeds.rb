# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Creando órdenes..."

products = [
  "Café Premium", "Azúcar Morena", "Arroz Integral", "Aceite de Oliva", "Sal Marina",
  "Harina de Trigo", "Leche Entera", "Pan Integral", "Queso Mozzarella", "Yogurt Natural",
  "Jugo de Naranja", "Agua Mineral", "Galletas de Avena", "Chocolate Oscuro", "Miel de Abeja",
  "Pasta Italiana", "Salsa de Tomate", "Atún en Lata", "Sardinas", "Mermelada de Fresa"
]

statuses = ["created", "processing", "completed", "cancelled"]

120.times do |i|
  Order.create!(
    customer_id: rand(1..5),
    product_name: products.sample,
    quantity: rand(1..10),
    price: rand(1000.0..50000.0).round(2),
    status: statuses.sample
  )
end

puts "#{Order.count} órdenes creadas exitosamente!"

