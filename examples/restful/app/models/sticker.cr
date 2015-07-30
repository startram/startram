class Sticker
  property id
  property title

  def initialize(@title, @id = nil)
  end

  @@stickers = { 1 => new("Hello There", 1) }
  @@initial_id = @@stickers.length

  def self.all
    @@stickers.values
  end

  def self.find(id)
    @@stickers[id.to_i]
  end

  def self.destroy(id)
    @@stickers.delete(id.to_i)
  end

  def save
    @id ||= @@initial_id += 1
    @@stickers[@id.to_i] = self
  end
end
