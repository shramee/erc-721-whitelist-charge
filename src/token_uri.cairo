%lang starknet

from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.math import split_int
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.pow import pow
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import (
    assert_not_equal,
    assert_nn_le,
    assert_lt,
    assert_le,
    assert_not_zero,
    assert_lt_felt,
    unsigned_div_rem,
)
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.math_cmp import is_le_felt

from openzeppelin.token.erc721.library import ERC721_owners

// TRUE or FALSE
@storage_var
func revealed() -> (res: felt) {
}

struct LongURL {
    x : felt,
    y : felt,
    z : felt,
}

@storage_var
func baseURL() -> (res: LongURL) {
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (res_len: felt, res: felt*) {
    alloc_locals;
    let url_core = _create_url_core();
    let (_revealed) = revealed.read();

    let (exists) = ERC721_owners.read(tokenId);
    with_attr error_message("The token doesn't exist.") {
        assert_not_equal( exists, 0 );
    }

    if (_revealed == TRUE) {
        let (id_felt: felt) = _uint_to_felt(tokenId);
        let url_end = _create_url_end(id_felt);
        return concat_arr(3, url_core, 2, url_end);
    }

    return (3, url_core);
}

func _create_url_core{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt* {
    alloc_locals;
    let (url_core: felt*) = alloc();
    let (url) = baseURL.read();
    assert url_core[0] = url.x;
    assert url_core[1] = url.y;
    assert url_core[2] = url.z;
    return url_core;
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

func _create_url_end{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _id_felt: felt
) -> felt* {
    alloc_locals;
    let (url_end: felt*) = alloc();
    let id_str = felt_to_str(_id_felt);
    assert url_end[0] = id_str;
    assert url_end[1] = '.json';
    return url_end;
}
@external
func set_base_url{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    long_url: LongURL
) {
    let (_revealed) = revealed.read();
    with_attr error_message(
        "Cannot set base URL again after it has been added for reveal") {
            assert _revealed = FALSE;
        }

    baseURL.write(long_url);
    revealed.write(TRUE);
    return();

}

func concat_arr{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    arr1_len: felt, arr1: felt*, arr2_len: felt, arr2: felt*
    ) -> (
    res_len: felt, res: felt*
) {
    alloc_locals;
    let (local res: felt*) = alloc();
    memcpy(res, arr1, arr1_len);
    memcpy(res + arr1_len, arr2, arr2_len);
    return (arr1_len + arr2_len, res);
}

const high_bit_max = 0x8000000000000110000000000000000;

func _check_uint_fits_felt{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    value: Uint256
) {
    let high_clear = is_le_felt(value.high, high_bit_max - 1);
    // Only one possible value otherwise, the actual PRIME - 1;
    if (high_clear == 0) {
        assert value.high = high_bit_max;
        assert value.low = 0;
    }
    return ();
}


func _uint_to_felt{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    value: Uint256
) -> (value: felt) {
    uint256_check(value);
    _check_uint_fits_felt(value);
    return (value.high * (2 ** 128) + value.low,);
}
