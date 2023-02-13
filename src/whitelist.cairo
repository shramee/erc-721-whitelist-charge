%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from openzeppelin.access.ownable.library import Ownable


@storage_var
func WhitelistedAddresses( address: felt ) -> (list: felt) {
}

@storage_var
func WhitelistSaleStage() -> (res: felt) {
}

namespace Lists {
    const WHITELIST = 'whitelist';
    const FREEMINT = 'freemint';
}

func whitelist_addr_arr{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr_len: felt,
    addr: felt*,
    list: felt
) {
    if ( addr_len == 0 ) {
        return ();
    }
    WhitelistedAddresses.write( addr[0], list );
    return whitelist_addr_arr( addr_len - 1, addr + 1, list );
}

@external
func whitelist_addresses{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address_len: felt,
    address: felt*,
) {
    Ownable.assert_only_owner();
    return whitelist_addr_arr( address_len, address, Lists.WHITELIST );
}

@external
func freemint_addresses{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address_len: felt,
    address: felt*,
) {
    Ownable.assert_only_owner();
    return whitelist_addr_arr( address_len, address, Lists.FREEMINT );
}

@view
func address_in_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( addr: felt ) -> (list: felt) {
    return WhitelistedAddresses.read( addr );
}

@external
func stage_switch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (sale_stage) = WhitelistSaleStage.read();
    WhitelistSaleStage.write(sale_stage + 1);
    return ();
}

// Returns `0` if can't mint
// Return listed in category if they can mint.
func can_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addr: felt
) -> felt {
    let (sale_stage) = WhitelistSaleStage.read();
    let (listed) = WhitelistedAddresses.read(addr);
    if ( sale_stage == 0 ) {
        if ( listed == Lists.FREEMINT ) {
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