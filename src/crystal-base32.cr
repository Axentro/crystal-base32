require "./crystal-base32/*"
require "big"

# Module for encoding and decoding in Base32 as per RFC 3548
class Base32
  TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  @@table = TABLE

  def self.table
    @@table
  end

  def self.chunks(str, size)
    result = [] of Chunk
    bytes = str.bytes
    while bytes.any?
      result << Chunk.new(bytes.first(size))
      bytes = bytes.skip(size)
    end
    result
  end

  def self.decode(str)
    chunks(str, 8).map(&.decode).flatten.join
  end

  def self.encode(str)
    chunks(str, 5).map(&.encode).flatten.join
  end

  def self.random_base32(length = 16, padding = true)
    random = ""
    Random::Secure.random_bytes(length).each do |b|
      random += self.table[b % 32].to_s
    end
    padding ? random.ljust(((length / 8.0).ceil * 8).to_i32, '=') : random
  end

  def self.table=(table)
    raise Exception.new("Table must have 32 unique characters") unless self.table_valid?(table)
    @@table = table
  end

  def self.table_valid?(table)
    table.bytes.to_a.size == 32 && table.bytes.to_a.uniq.size == 32
  end
end

class Chunk
  def initialize(@bytes : Array(UInt8))
  end

  def decode
    bytes = @bytes.take_while { |c| c != 61 } # strip padding
    n = (bytes.size * 5.0 / 8.0).floor.to_i64
    p = bytes.size < 8 ? 5 - (n * 8) % 5 : 0
    c = bytes.reduce(0) do |m, o|
      m = BigInt.new(m)
      i = Base32.table.index(o.chr)
      raise Exception.new("invalid character '#{o.chr}'") if i.nil?
      (m << 5) + i
    end >> p
    (0..n - 1).to_a.reverse.map { |i| ((c >> i * 8) & 0xff).to_i32.chr }
  end

  def encode
    n = (@bytes.size * 8.0 / 5.0).ceil.to_i64
    p = n < 8 ? 5 - (@bytes.size * 8) % 5 : 0
    c = @bytes.reduce(0) do |m, o|
      m = BigInt.new(m)
      (m << 8) + o
    end << p
    [(0..n - 1).to_a.reverse.map { |i| Base32.table[((c >> i * 5) & 0x1f)].to_s }, ("=" * (8 - n))]
  end
end
