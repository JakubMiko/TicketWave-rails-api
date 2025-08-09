require 'open-uri'

I18n.locale = :en
I18n.default_locale = :en


# Uncomment the following line if you want to clean the database before seeding
# Ticket.delete_all
# Order.delete_all
# TicketBatch.delete_all
# Event.delete_all
# User.delete_all

admin = User.create!(first_name: "Admin", last_name: "User", email: "admin@gmail.com", password: "password", role: :admin)
regular_user = User.create!(first_name: "Regular", last_name: "User", email: "regular@gmail.com", password: "password", role: :user)

events = []

concert = Event.create!(
  name: 'Koncert XYZ',
  description: "Niesamowity koncert zespołu XYZ, który zaskoczy Cię swoją energią i niepowtarzalnym brzmieniem. Zespół XYZ to grupa, która łączy różne gatunki muzyczne, tworząc unikalne kompozycje. Ich koncerty to nie tylko muzyka, ale także niesamowite wizualizacje i kontakt z publicznością.",
  place: "Arena Warszawa",
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
  name: "Premiera Sztuki ABC",
  description: "Poruszająca premiera w teatrze, która wprowadzi Cię w świat emocji i refleksji. Sztuka ABC to opowieść o ludzkiej naturze, miłości i poświęceniu. Spektakl wyreżyserowany przez znanego reżysera teatralnego, z udziałem wybitnych aktorów, którzy przeniosą Cię w inny wymiar.",
  place: "Teatr Narodowy",
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
  name: "Mecz Piłki Nożnej Polska vs. Niemcy",
  description: "Emocjonujący mecz na stadionie, który przyciągnie uwagę całego kraju. Polska reprezentacja zmierzy się z drużyną niemiecką w kluczowym meczu eliminacyjnym. To spotkanie może zadecydować o awansie do kolejnej fazy rozgrywek. Przyjdź i wspieraj biało-czerwonych w tym ważnym starciu!",
  place: "Stadion Narodowy",
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
  name: "Festiwal Muzyki Klasycznej",
  description: "Festiwal muzyki klasycznej z udziałem najwybitniejszych orkiestr i solistów z całego świata. Przez tydzień będziesz mógł uczestniczyć w niezapomnianych koncertach muzyki klasycznej, od baroku po współczesność. Wyjątkowe doznania muzyczne w pięknej scenerii.",
  place: "Filharmonia Narodowa",
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
