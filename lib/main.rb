require 'ferrum'
require 'nokogiri'
require 'uri'

URL = 'https://ww2.hakush.in/weapon'

browser = Ferrum::Browser.new(timeout: 30)
browser.goto(URL)

# Чекаємо, поки сторінка завантажиться
browser.network.wait_for_idle

# Отримуємо HTML після генерації JS
html = browser.body
doc = Nokogiri::HTML(html)

# Парсимо контейнер
container = doc.at_css('div.grid.grid-cols-4')

if container.nil?
  puts 'Контейнер не знайдено!'
  browser.quit
  exit
end

# Витягуємо кнопки
container.css('a.btn').each do |a|
  href  = a['href']
  title = a.css('div').text.strip

  # робимо абсолютне посилання
  abs = URI.join(URL, href).to_s

  puts "#{title} -> #{abs}"
end

browser.quit
