%lang starknet
from src.token_uri import _create_url_end

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
 
from starkware.cairo.common.alloc import alloc
from openzeppelin.access.ownable.library import Ownable

@external
func test_create_url{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let res: felt* = _create_url_end(197);
    assert res[0] = 0x30313937;
    return ();
}