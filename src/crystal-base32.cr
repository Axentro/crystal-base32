require "./crystal-base32/*"

# Module for encoding and decoding in Base32 as per RFC 3548
module Base32
  extend self
  TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  @@table = TABLE

  def table
    @@table
  end

  def table_map
    Hash.zip(@@table.chars, (0..31).to_a)
  end

  def encode(str : String) : String
    mio = IO::Memory.new((str.bytesize / 5 * 8))
    str.to_slice.each_slice(5) do |slice|
      bits = 0.to(slice.size - 1).reduce(0_u64) { |acc, i| acc | (slice[i].to_u64 << (4 - i)*8) }
      7.to(0).reduce(0x1F_u64 << 35) do |acc, i|
        mio << table[((bits & acc) >> i*5) % 32]
        acc >> 5
      end
    end

    # remove trailing chars
    while mio.buffer[mio.pos - 1] == table[0 % 32].ord
      mio.pos -= 1
    end

    # apply padding
    until (mio.pos % 8 == 0)
      mio << "="
    end

    mio.to_s
  end

  def decode(str : String) : String
    String.new(decode_as_bytes(str))
  end

  def decode_as_bytes(str : String) : Bytes
    mio = IO::Memory.new((str.bytesize / 8) * 5)
    str.to_slice.reject { |s| ['\n'.ord, '\r'.ord, '='.ord].includes?(s) }.each_slice(8) do |slice|
      bits = 0.to(slice.size - 1).reduce(0_u64) { |acc, i| acc | table_map[slice[i].chr].to_u64 << (7 - i)*5 }
      4.to(0).reduce(0xFF_u64 << 32) do |acc, i|
        mio.write_byte(((bits & acc) >> i*8).to_u8)
        acc >> 8
      end
    end

    # remove trailing zero bytes
    sl = mio.to_slice
    while sl[-1] == 0
      sl = sl[0, sl.size - 1]
    end if sl.size > 0
    sl
  end

  def random_base32(length = 16, padding = true) : String
    random = ""
    Random::Secure.random_bytes(length).each do |b|
      random += self.table[b % 32].to_s
    end
    padding ? random.ljust(((length / 8.0).ceil * 8).to_i32, '=') : random
  end

  def table=(table)
    raise Exception.new("Table must have 32 unique characters") unless self.table_valid?(table)
    @@table = table
  end

  def table_valid?(table)
    table.bytes.to_a.size == 32 && table.bytes.to_a.uniq.size == 32
  end
end
