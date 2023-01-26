%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from openzeppelin.access.ownable.library import Ownable

@storage_var
func _whitelist( address: felt ) -> (res: felt) {
}

@storage_var
func _whitelist_meta( address: felt ) -> (res: felt) {
}

func whitelist_addr_arr{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr: felt*,
    addr_left: felt,
    list: felt
) {
    if ( addr_left == 0 ) {
        return ();
    }
    _whitelist.write( addr[0], list );
    return whitelist_addr_arr( addr + 1, addr_left - 1, list );
}

@external
func whitelist_addresses{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address_len: felt,
    address: felt*,
) {
    Ownable.assert_only_owner();
    return whitelist_addr_arr( address, address_len, 'whitelist' );
}

@external
func freemint_addresses{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address_len: felt,
    address: felt*,
) {
    Ownable.assert_only_owner();
    return whitelist_addr_arr( address, address_len, 'freemint' );
}

@external
func stage_switch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (sale_stage) = _whitelist_meta.read('stage');
    _whitelist_meta.write('stage', sale_stage + 1);
    return ();
}

// Returns `0` if can't mint
// Return listed in category if they can mint.
func can_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr: felt
) -> felt {
    let (sale_stage) = _whitelist_meta.read('stage');
    let (listed) = _whitelist.read(addr);
    if ( sale_stage == 0 ) {
        if ( listed == 'freemint' ) {
            // Stage 0 only freemint can mint
            return listed;
        }
        // Stage 0 no one else can mint
        return 0;
    }
    if ( sale_stage == 1 ) {
        // Returns 1 listed addresses can mint, unlisted (0) can't
        return listed;
    }
    if ( listed == 0 ) {
        // Even unlisted can mint
        return 1;
    }
    return listed;
}