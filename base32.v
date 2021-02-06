module base32

import regex

// Encode byte array to base32 with Bitcoin alphabet
pub fn encode(input string) ?string {
	return encode_walpha(input, alphabets['std'])
}

// Encode byte array to base32 with custom aplhabet
pub fn encode_walpha(input string, alphabet &Alphabet) ?string {
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
}

pub fn decode(input string) ?string {
	return decode_walpha(input, alphabets['std'])
}

pub fn decode_walpha(input string, alphabet &Alphabet) ?string {
	if input.len == 0 {
		return error('base32 > decode_walpha(input string, ...): input cannot be empty')
	}

	// TODO: Add valididation process here.
	// Validation has temporarily been removed because
	// it doesn't work correctly with non-alphanumerics

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

pub fn validate(input string) ?bool {
	return validate_walpha(input, alphabets['std'])
}

// Regex doesn't work when you use non-alphanumeric characters.
// Going to have to rework the validation process
pub fn validate_walpha(input string, alphabet &Alphabet) ?bool {
	// created in new_alphabet(string)
	mut re := regex.regex_opt(alphabet.regex_pattern) or {
		eprintln('Err: unable to validate string')
		return error(err)
	}

	if re.find_all(input).len != 0
			&& input.len % 8 == 0 {
		return true
	}

	return false
}