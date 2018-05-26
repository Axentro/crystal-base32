require "./spec_helper"

describe Base32 do
  it "should work with empty string" do
    assert_encode_and_decode("", "")
  end
  it "shold work with a string" do
    assert_encode_and_decode("ME======", "a")
  end
  it "should work with numbers" do
    assert_encode_and_decode("GEZDGNBV", "12345")
  end
  it "should work with letters" do
    assert_encode_and_decode("MFRGGZDF", "abcde")
  end
  it "should work with long text" do
    plaintext = "We the people of the United States, in order to form a more perfect union, establish justice, insure domestic tranquility, provide for the common defense, promote the general welfare, and secure the blessings of liberty to ourselves and our posterity, do ordain and establish this Constitution for the United States of America."
    encoded = "K5SSA5DIMUQHAZLPOBWGKIDPMYQHI2DFEBKW42LUMVSCAU3UMF2GK4ZMEBUW4IDPOJSGK4RAORXSAZTPOJWSAYJANVXXEZJAOBSXEZTFMN2CA5LONFXW4LBAMVZXIYLCNRUXG2BANJ2XG5DJMNSSYIDJNZZXK4TFEBSG63LFON2GSYZAORZGC3TROVUWY2LUPEWCA4DSN53GSZDFEBTG64RAORUGKIDDN5WW233OEBSGKZTFNZZWKLBAOBZG63LPORSSA5DIMUQGOZLOMVZGC3BAO5SWYZTBOJSSYIDBNZSCA43FMN2XEZJAORUGKIDCNRSXG43JNZTXGIDPMYQGY2LCMVZHI6JAORXSA33VOJZWK3DWMVZSAYLOMQQG65LSEBYG643UMVZGS5DZFQQGI3ZAN5ZGIYLJNYQGC3TEEBSXG5DBMJWGS43IEB2GQ2LTEBBW63TTORUXI5LUNFXW4IDGN5ZCA5DIMUQFK3TJORSWIICTORQXIZLTEBXWMICBNVSXE2LDMEXA===="
    assert_encode_and_decode(encoded, plaintext)
  end
  it "should work with other characters" do
    assert_encode_and_decode("FA======", "(")
  end
  it "should decode to bytes" do
    Base32.decode_as_bytes("NY4A5CPJZ46LXZCP").should eq([110_u8, 56_u8, 14_u8, 137_u8, 233_u8, 207_u8, 60_u8, 187_u8, 228_u8, 79_u8])
  end
  it "should produce a random_base32" do
    Base32.random_base32.should match(/^[A-Z2-7]+$/)
  end
  it "should produce a random_base32 of correct length" do
    Base32.random_base32(32).size.should eq(32)
    Base32.random_base32(40).size.should eq(40)
    Base32.random_base32(29).size.should eq(32)
  end
  it "should produce a random_base23 of correct length without padding" do
    Base32.random_base32(32, false).size.should eq(32)
    Base32.random_base32(40, false).size.should eq(40)
    Base32.random_base32(29, false).size.should eq(29)
    Base32.random_base32(1, false).should match(/^[A-Z2-7]{1}$/)
    Base32.random_base32(29, false).should match(/^[A-Z2-7]{29}$/)
  end
  it "should assign a new table" do
    new_table = "abcdefghijklmnopqrstuvwxyz234567"
    Base32.table = new_table
    new_table.should eq(Base32.table)
  end
  it "should check table length" do
    expect_raises(Exception, "Table must have 32 unique characters") { Base32.table = ("a" * 31) }
    expect_raises(Exception, "Table must have 32 unique characters") { Base32.table = ("a" * 32) }
    expect_raises(Exception, "Table must have 32 unique characters") { Base32.table = ("a" * 33) }
    expect_raises(Exception, "Table must have 32 unique characters") { Base32.table = ("abcdefghijklmnopqrstuvwxyz234567" * 2) }
  end
  it "should encode and decode with alternate table" do
    Base32.table = "abcdefghijklmnopqrstuvwxyz234567"
    assert_encode_and_decode("fa======", "(")
  end
end

def assert_decoding(encoded, plain)
  decoded = Base32.decode(encoded)
  decoded.should eq(plain)
end

def assert_encoding(encoded, plain)
  actual = Base32.encode(plain)
  actual.should eq(encoded)
end

def assert_encode_and_decode(encoded, plain)
  assert_encoding(encoded, plain)
  assert_decoding(encoded, plain)
end
