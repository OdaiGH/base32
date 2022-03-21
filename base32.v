module base32

// encode encodes `input` into a base32 string
pub fn encode(input string) ?string {
	return encode_walpha(input, alphabets['std'])
}

/*pub fn encode_walpha_old(input string, alphabet &Alphabet) ?string {
	if input.len == 0 {
		return error('base32 > encode_walpha(input string, ...): input cannot be empty')
	}
	
	// create binary string zeropadded to 8 bits
	mut data := input.bytes()
	mut binary := bytes_to_bin(data)

	// split into 5 bit chunks
	// trailing chunk should consist of 5 bits
	mut chunks := split_into_chunks(binary)
	
	mut encoded := ''
	for chunk in chunks {
		idx := bin_to_dec(chunk.int())
		encoded += alphabet.encode[idx].ascii_str()
	}

	// pad the encoded string
	if alphabet.pad_char != padding['nopad'] {
		if encoded.len % 8 != 0 {
			pad := 8 - encoded.len % 8
			encoded += alphabet.pad_char.str().repeat(pad)
		}
	}

	return encoded
}*/

// encode_walpha encodes `input` into a base32 string based on `alphabet`
pub fn encode_walpha(input string, alphabet &Alphabet) ?string {
	if input.len == 0 {
		return error('base32 > encode_walpha(input string, ...): input cannot be empty')
	}
	
	mut src := input.bytes()
	mut ret := ''
	mut encoded := []byte{len: 8}

	for src.len > 0 {
		mut carry := byte(0)

		match src.len {
			4 {
len4:			encoded[6] = alphabet.encode[carry|(src[3]<<3)&0x1F]
				encoded[5] = alphabet.encode[(src[3]>>2)&0x1F]
				carry = src[3] >> 7
				unsafe { goto len3 }
			}
			3 {
len3:			encoded[4] = alphabet.encode[carry|(src[2]<<1)&0x1F]
				carry = (src[2] >> 4) & 0x1F
				unsafe { goto len2 }
			}
			2 {
len2:			encoded[3] = alphabet.encode[carry|(src[1]<<4)&0x1F]
				encoded[2] = alphabet.encode[(src[1]>>1)&0x1F]
				carry = (src[1] >> 6) & 0x1F
				unsafe { goto len1 }
			}
			1 {
len1:			encoded[1] = alphabet.encode[carry|(src[0]<<2)&0x1F]
				encoded[0] = alphabet.encode[src[0]>>3]
			}
			else {
				encoded[7] = alphabet.encode[src[4]&0x1F]
				carry = src[4] >> 5
				unsafe { goto len4 }
			}
		}

		if src.len < 5 {
			if alphabet.pad_char != padding['nopad'] {
				encoded[7] = byte(alphabet.pad_char)
				if src.len < 4 {
					encoded[6] = byte(alphabet.pad_char)
					encoded[5] = byte(alphabet.pad_char)
					if src.len < 3 {
						encoded[4] = byte(alphabet.pad_char)
						if src.len < 2 {
							encoded[3] = byte(alphabet.pad_char)
							encoded[2] = byte(alphabet.pad_char)
						}
					}
				}
			}
			ret += encoded.bytestr()
			break
		}

		src = src[5..]
		ret += encoded.bytestr()
		encoded = []byte{len: 8}
	}

	return ret
}

// decode decodes `input`, a base32 string, into an ASCII string
pub fn decode(input string) ?string {
	return decode_walpha(input, alphabets['std'])
}

// decode decodes `input`, a base32 string, into an ASCII string based on `alphabet`
pub fn decode_walpha(input string, alphabet &Alphabet) ?string {
	if input.len == 0 {
		return error('base32 > decode_walpha(input string, ...): input cannot be empty')
	}

	if validate_walpha(input, alphabet) == false {
		return error('base32 > decode_walpha(input string, alphabet &Alphabet): input is an invalid base32 string')
	}

	// convert to 5-bit binary chunks
	data := input.bytes()
	mut chunks := []string{}
	for b in data {
		if rune(b) != alphabet.pad_char {
			chunks << dec_to_bin(alphabet.encode.index_byte(b))
		}
	}

	// combine 5-bit chunks and split into 8-bit chunks
	bin := chunks.join('')
	mut bin_chunks := []string{}
	for i := 0; i <= bin.len-8; i += 8 {
		bin_chunks << bin[i..i+8]
	}

	decoded := bin_to_bytes(bin_chunks)

	return decoded.bytestr()
}

// validate checks if `input` is a base32 string
pub fn validate(input string) bool {
	return validate_walpha(input, alphabets['std'])
}

// validate_walpha checks if `input` is a base32 string based on `alphabet`
pub fn validate_walpha(input string, alphabet &Alphabet) bool {
	mut is_valid := true
	for b in input {
		// if byte is in alphabet or is the padding char
		if alphabet.encode.index_byte(b) >= 0 || rune(b) == alphabet.pad_char {
			if input.index_any(alphabet.pad_char.str()) >= 0 {
				// check if every char after the first padding char is also a padding char
				padding_substr := input[input.index_any(alphabet.pad_char.str())..input.len]
				if padding_substr.contains_any(alphabet.encode) {
					is_valid = false
				}
			}
		} else {
			is_valid = false
		}
	}
	return is_valid
}