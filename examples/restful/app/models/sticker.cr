class Sticker
  include Startram::Model

  field :id, Int32
  field :title

  @@stickers = { 1 => new({"id" => 1, "title" => "Hello There"}) }
  @@initial_id = @@stickers.length

  def self.all
    @@stickers.values
  end

  def self.find(id)
    puts @@stickers.keys
    @@stickers[id.to_s.to_i]
  end

  def self.destroy(id)
    @@stickers.delete(id.to_s.to_i)
  end

  def save
    self.id ||= @@initial_id += 1
    @@stickers[id.not_nil!] = self
  end

  def persisted?
    id
  end
end
