%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from openzeppelin.token.erc721.presets.ERC721MintableBurnable import (
    // constructor,
    supportsInterface,
    name,
    symbol,
    balanceOf,
    ownerOf,
    getApproved,
    isApprovedForAll,
    tokenURI,
    owner,
    approve,
    setApprovalForAll,
    transferFrom,
    safeTransferFrom,
    mint as _mint,
    burn,
    setTokenURI,
    transferOwnership,
    renounceOwnership
)

@storage_var
func _whitelist( address: felt ) -> (res: felt) {
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
    return whitelist_addr_arr( address, address_len, 'whitelist' );
}