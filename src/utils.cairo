from starkware.cairo.common.math import assert_nn, assert_not_equal, split_felt, split_int
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.pow import pow

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin

func felt_to_uint256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( f: felt ) -> Uint256 {
    let (high, low) = split_felt(f);
    let val = Uint256(low=low, high=high);
    return val;
}

func felt_to_str_recursive{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sum: felt, i: felt, max_i: felt, digits: felt*) -> felt {
    if ( i == max_i ) {
        return sum;
    }
    let char_code = 48 + digits[i];
    let (place_value) = pow(256, i);
    let new_sum = char_code * place_value;
    return felt_to_str_recursive(sum+new_sum, i + 1, max_i, digits);
}

func felt_to_str{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( input: felt ) -> felt {
    alloc_locals;
    let (digits: felt*) = alloc();
    split_int( input, 4, 10, 10, digits );
    return felt_to_str_recursive(0, 0, 4, digits);
}
