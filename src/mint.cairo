%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.access.ownable.library import Ownable

from starkware.cairo.common.uint256 import Uint256
from openzeppelin.token.erc721.library import ERC721

from src.whitelist import can_mint

@storage_var
func TokenMeta( meta: felt ) -> (data: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, owner: felt, token_limit: felt, payment_token_addr: felt
) {
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);

    // token_limit and payment token addr addr
    TokenMeta.write('token_limit', token_limit);
    TokenMeta.write('payment_token_addr', payment_token_addr);
    TokenMeta.write('next_token_id', 0); // Unnecessary, establish semantics
    return ();
}

// Return available token ID, increment storage
func get_available_token_id() -> felt {
    // assert supply
    // @TODO Get next token ID
    // @TODO Increment next token ID
    return 0xabc; // Definitely needs changing
}

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    let (caller) = get_caller_address();
    let (i_can_mint) = can_mint( caller );

    with_attr error_message( "Sorry, you cannot mint yet. Please try again later." ) {
        assert_not_equal( i_can_mint, 0 );
    }

    let token_id = get_available_token_id();

    if ( 'freemint' == i_can_mint ) {
        // Just mint, no questions asked.
        return ERC721._mint(to, token_id);
    }

    // @TODO Charge ETH for minting, import ERC20 interface and call contract

    return ERC721._mint(to, token_id);
}