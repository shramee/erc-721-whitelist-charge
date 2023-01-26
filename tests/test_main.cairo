%lang starknet
from src.main import whitelist_addresses, _whitelist
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

@external
func test_whitelist{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let (addresses: felt*) = alloc();

    assert addresses[0] = 0xf00;
    assert addresses[1] = 0xb0b;
    // assert addresses[0] = 0xace;

    whitelist_addresses( 2, addresses );
    let (foo_whitelisted) = _whitelist.read(0xf00);
    assert foo_whitelisted = 'whitelist';
    let (bob_whitelisted) = _whitelist.read(0xb0b);
    assert bob_whitelisted = 'whitelist';
    return ();
}
