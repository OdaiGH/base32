# Implementation of base32 encoding/decoding in V
Encoding/Decoding process was adapted from [tuupola/base32](https://github.com/tuupola/base32).

## Installation
V must first be installed on your machine. You can get that from [vlang/v](https://github.com/vlang/v). After installing V execute this command to install this module to your system. And that's it!

VPM:
```bash
$ v install islonely.base32
```
VPKG:
```bash
vpkg get base32
```
Manual install:
```bash
$ mkdir modules
$ cd modules
$ git clone https://github.com/is-lonely/base32
```
## Usage
The default base32 alphabet is `ABCDEFGHIJKLMNOPQRSTUVWXYZ234567` with `=` as the padding character.
```v
import base32   // if you installed with VPM, then you
                // will need to use 'import islonely.base32'

fn main() {
    input_string := 'placeholder'
    encoded := base32.encode(input_string) or {
        eprintln(err)
        exit(0)
    }
    decoded := base32.decode(encoded) or {
        eprintln(err)
        exit(0)
    }
                                        // Output
	println('Input:\t\t$input_string')  // placeholder
	println('Encoded:\t$encoded')       // OBWGCY3FNBXWYZDFOI======
	println('Decoded:\t$decoded')       // placeholder
}
```

For use with custom alphabets:
```v
import base32

fn main() {
    custom_alphabet := base32.new_alphabet_wpadc(r'`~!@#$%^&*()_-+={}[]\|;:",.?/Uwu', `>`)

    input_string := 'Lorem ipsum dolor sit.'
    encoded := base32.encode_walpha(input_string, custom_alphabet) or {
        eprintln(err)
        exit(0)
    }
    decoded := base32.decode_walpha(encoded, custom_alphabet) or {
        eprintln(err)
        exit(0)
    }
                                        // Output
	println('Input:\t\t$input_string')  // Lorem ipsum dolor sit.
	println('Encoded:\t$encoded')       // *}::#,)-#~\:`/?|-\{%&??_-U,!`/?*+{:`>>>>
	println('Decoded:\t$decoded')       // Lorem ipsum dolor sit.
}
```

### Donations
Pls, I'm broke lol

[![.NET Conf - November 10-12, 2020](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/islonely)