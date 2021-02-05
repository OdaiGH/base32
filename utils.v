module base32

import math

// see PHP array_map
// basically sends each value in array through
// an anonymous function
fn array_map_with_ret_generic<T,U>(fun fn (T) U, arr []T) []U {
	mut ret := []U{len: arr.len}
	for i := 0; i < arr.len; i++ {
		ret[i] = fun(arr[i])
	}
	return ret
}

fn array_map<T>(fun fn (T) T, arr []T) []T {
	return array_map_with_ret_generic<T,T>(fun, arr)
}

fn bytes_to_binary(bytes []byte) string {
	ret := array_map_with_ret_generic<byte,string>(fn (b byte) string {
		mut ret := ''
		for i := 7; i >= 0; i-- {
			ret += if b & (1 << i) != 0 {'1'} else {'0'}
		}

		return ret
	}, bytes)
	return ret.join('')
}

fn split_into_chunks(str string) []string {
	mut padded_str := str
	// pad with zeroes
	for padded_str.len % 5 != 0 {
		padded_str += '0'
	}

	if padded_str.len == 5 {
		return [padded_str]
	}

	mut ret := []string{}
	for i := 0; i < padded_str.len; i += 5 {
		ret << padded_str[i..i+5]
	}

	return ret
}

// usually you would want n to be i128 because
// binary can get really long, but since this'll
// only be used for 5-bit chunks, this will be fine
fn bin_to_dec(n int) int {
	mut dec := 0
	mut x := n
	for i := 0; x > 0; i++ {
		rem := x % 10
		dec += int(rem*math.pow(2, i))
		x /= 10
	}
	return dec
}