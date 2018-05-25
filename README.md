# crystal-base32

This shard contains base32, A Crystal library for encoding and decoding in base32 as per RFC 3548

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-base32:
    github: SushiChain/crystal-base32
```

## Usage

```crystal
require "crystal-base32"
```

#### Simple Example

```crystal
require "base32"

encoded = Base32.encode("chunky bacon!")  #==> "MNUHK3TLPEQGEYLDN5XCC==="
decoded = Base32.decode(encoded)          #==> "chunky bacon!"

puts %Q{"#{decoded}" is "#{encoded}" in base32}
```

## Specs

```bash
> crystal spec
```

## References

* RFC 3548: http://www.faqs.org/rfcs/rfc3548.html

## Contributing

1. Fork it ( https://github.com/SushiChain/crystal-base32/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [kingsleyh](https://github.com/kingsleyh) Kingsley Hendrickse - creator, maintainer
