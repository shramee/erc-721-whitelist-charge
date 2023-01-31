%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.math import assert_nn, assert_not_equal
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.access.ownable.library import Ownable

from src.whitelist import can_mint, Lists

@storage_var
func TokenMeta( meta: felt ) -> (data: felt) {
}

// Return available token ID, increment storage
func get_available_token_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> felt {
    let (token_limit) = TokenMeta.read('token_limit');
    let (next_token_id) = TokenMeta.read('next_token_id');

    // Only token IDs less than supply limit can be minted
    assert_nn( next_token_id ); // This is always gonna be fine, just here for sanity
    assert_nn( token_limit - next_token_id );

    return next_token_id; // Definitely needs changing
}

func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(to: felt) {
    let tkn_id = get_available_token_id();
    TokenMeta.write('next_token_id', tkn_id + 1);
    return ERC721._mint(to, Uint256(low=tkn_id, high=0));
}

@contract_interface
namespace ERC20 {
    func transfer(recipient: felt, amount: Uint256) -> (success: felt) {
    }
}

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    let (caller) = get_caller_address();
    let i_can_mint = can_mint( caller );

    with_attr error_message( "Sorry, you cannot mint yet. Please try again later." ) {
        assert_not_equal( i_can_mint, 0 );
    }

    if ( Lists.FREEMINT == i_can_mint ) {
        // Just mint, no questions asked.
        return _mint(to);
    }

    let (payment_token_addr) = TokenMeta.read('payment_token_addr');
    let (mint_charge) = TokenMeta.read('mint_charge');
    let mint_charge_256 = Uint256(low=mint_charge, high=0);
    let (owner) = Ownable.owner();

    // @TODO Charge ETH for minting, import ERC20 interface and call contract
    ERC20.transfer(contract_address=payment_token_addr, recipient=owner, amount=mint_charge_256);

    return _mint(to);
}