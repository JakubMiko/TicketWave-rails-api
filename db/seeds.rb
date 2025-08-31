require 'open-uri'

I18n.locale = :en
I18n.default_locale = :en


# Uncomment the following line if you want to clean the database before seeding
# Ticket.delete_all
# Order.delete_all
# TicketBatch.delete_all
# Event.delete_all
# User.delete_all

admin = User.find_or_create_by!(email: "admin@gmail.com") do |u|
  u.first_name = "Admin"
  u.last_name = "User"
  u.password = "password"
  u.admin = true
end

regular_user = User.find_or_create_by!(email: "regular@gmail.com") do |u|
  u.first_name = "Regular"
  u.last_name = "User"
  u.password = "password"
  u.admin = false
end

events = []

concert = Event.create!(
  name: 'XYZ Concert',
  description: "An amazing concert by the XYZ band, which will surprise you with its energy and unique sound. XYZ is a group that combines different music genres, creating unique compositions. Their concerts are not only about music, but also incredible visuals and interaction with the audience.",
  place: "Warsaw Arena",
  date: (Time.now + 2.months).change(hour: 19, min: 0, sec: 0),
  category: "music"
)
concert_img_path = Rails.root.join('app/assets/images/seed_images/concert.jpg')
if File.exist?(concert_img_path)
  concert.image.attach(
    io: File.open(concert_img_path),
    filename: 'concert.jpg',
    content_type: 'image/jpeg'
  )
end
events << concert

theater = Event.create!(
  name: "ABC Play Premiere",
  description: "A moving theater premiere that will take you into a world of emotions and reflection. ABC is a story about human nature, love, and sacrifice. The play is directed by a renowned theater director and features outstanding actors who will transport you to another dimension.",
  place: "National Theatre",
  date: (Time.now - 1.month).change(hour: 18, min: 30, sec: 0),
  category: "theater"
)
theater_img_path = Rails.root.join('app/assets/images/seed_images/theater.jpg')
if File.exist?(theater_img_path)
  theater.image.attach(
    io: File.open(theater_img_path),
    filename: 'theater.jpg',
    content_type: 'image/jpeg'
  )
end
events << theater

sports = Event.create!(
  name: "Football Match: Poland vs. Germany",
  description: "An exciting match at the stadium that will attract the attention of the whole country. The Polish national team will face the German team in a crucial qualifying match. This game may decide advancement to the next stage. Come and support the white-and-reds in this important clash!",
  place: "National Stadium",
  date: (Time.now + 3.months).change(hour: 20, min: 0, sec: 0),
  category: "sports"
)
sports_img_path = Rails.root.join('app/assets/images/seed_images/sports.jpg')
if File.exist?(sports_img_path)
  sports.image.attach(
    io: File.open(sports_img_path),
    filename: 'sports.jpg',
    content_type: 'image/jpeg'
  )
end
events << sports

festival = Event.create!(
  name: "Classical Music Festival",
  description: "A classical music festival featuring the greatest orchestras and soloists from around the world. For a week, you can enjoy unforgettable classical music concerts, from baroque to contemporary. Unique musical experiences in a beautiful setting.",
  place: "National Philharmonic",
  date: (Time.now + 5.months).change(hour: 17, min: 0, sec: 0),
  category: "festival"
)
festival_img_path = Rails.root.join('app/assets/images/seed_images/festival.jpg')
if File.exist?(festival_img_path)
  festival.image.attach(
    io: File.open(festival_img_path),
    filename: 'festival.jpg',
    content_type: 'image/jpeg'
  )
end
events << festival

ticket_batches = []
events.each do |event|
  ticket_batches << TicketBatch.create!(
    event: event,
    available_tickets: rand(50..100),
    price: rand(50..200),
    sale_start: Time.now,
    sale_end: event.date - 1.day
  )
end

orders = []
ticket_batches.each do |ticket_batch|
  order1 = Order.create!(
    user: regular_user,
    ticket_batch: ticket_batch,
    quantity: 2,
    total_price: ticket_batch.price * 2,
    status: "paid"
  )
  orders << order1

  order2 = Order.create!(
    user: admin,
    ticket_batch: ticket_batch,
    quantity: 1,
    total_price: ticket_batch.price,
    status: "paid"
  )
  orders << order2
end

orders.each do |order|
  order.quantity.times do
    Ticket.create!(
      order: order,
      user: order.user,
      event: order.ticket_batch.event,
      price: order.ticket_batch.price,
      ticket_number: SecureRandom.hex(8)
    )
  end
end

puts "Seeds created successfully"
