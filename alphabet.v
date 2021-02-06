module base32

const(
	padding = {
		'std': rune(`=`)
		'nopad': rune(-1)
	}

	alphabets = {
		'std':			new_alphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567')
		'hex': 			new_alphabet('0123456789ABCDEFGHIJKLMNOPQRSTUV')
		'geohash':		new_alphabet_wpadc('0123456789bcdefghjkmnpqrstuvwxyz', padding['nopad'])
		'word-safe':	new_alphabet_wpadc('23456789CFGHJMPQRVWXcfghjmpqrvwx', padding['nopad'])
		'zbase':		new_alphabet_wpadc('ybndrfg8ejkmcpqxot1uwisza345h769', padding['nopad'])
	}
)

struct Alphabet {
	regex_pattern string
pub:
	encode string
	pad_char rune
mut:
	decode_map []byte = []byte{len: 256, init: 0xFF}
}

pub fn (alphabet &Alphabet) str() string {
	mut ret := []byte{}
	for entry in alphabet.encode {
		ret << entry
	}
	return ret.bytestr()
}

pub fn new_alphabet(str string) &Alphabet {
	return new_alphabet_wpadc(str, padding['std'])
}

pub fn new_alphabet_wpadc(str string, pad_char rune) &Alphabet {
	if str.len != 32 {
		panic('base32 > new_alphabet(string): string must be 32 characters in length')
	}

	if str.contains(pad_char.str()) {
		panic('base32 > new_alphabet(str string, pad_char rune): pad_char must have distinct value from str')
	}

	mut ret := &Alphabet{
		encode: str
		pad_char: pad_char
		regex_pattern: '^[$str]+${padding['std']}{0,7}$'
	}

	mut distinct := 0
	for i, b in ret.encode {
		if ret.decode_map[b] == 0xFF {
			distinct++
		}
		ret.decode_map[b] = byte(i)
	}

	if distinct != 32 {
		panic('base32 > new_alphabet(string): string cannot contain repeating characters')
	}

	return ret
}