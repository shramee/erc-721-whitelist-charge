%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.math import assert_nn, assert_not_equal
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.access.ownable.library import Ownable
from openzeppelin.token.erc20.IERC20 import IERC20

from src.whitelist import can_mint, Lists, WhitelistedAddresses
from src.utils import felt_to_uint256

@storage_var
func MintCharge() -> (data: felt) {
}

@storage_var
func PaymentTokenAddress() -> (data: felt) {
}

@storage_var
func TokenLimit() -> (data: felt) {
}

@storage_var
func NextTokenID() -> (data: felt) {
}

// Return available token ID, increment storage
func get_available_token_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> felt {
    let (token_limit) = TokenLimit.read();
    let (next_token_id) = NextTokenID.read();

    // Only token IDs less than supply limit can be minted
    assert_nn( next_token_id ); // This is always gonna be fine, just here for sanity
    assert_nn( token_limit - next_token_id );

    return next_token_id; // Definitely needs changing
}

func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(to: felt) {
    let tkn_id = get_available_token_id();
    NextTokenID.write(tkn_id + 1);
    WhitelistedAddresses.write( to, 0 );
    return ERC721._mint(to, felt_to_uint256(tkn_id));
}

// tokenId is ignored
@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    let (caller) = get_caller_address();
    let i_can_mint = can_mint( caller );

    with_attr error_message( "Caller not whitelisted. Please try again later." ) {
        assert_not_equal( i_can_mint, 0 );
    }

    if ( Lists.FREEMINT == i_can_mint ) {
        // Just mint, no questions asked.
        return _mint(to);
    }

    let (payment_token_addr) = PaymentTokenAddress.read();
    let (mint_charge) = MintCharge.read();
    let mint_charge_256 = felt_to_uint256(mint_charge);
    let (owner) = Ownable.owner();

    IERC20.transfer(contract_address=payment_token_addr, recipient=owner, amount=mint_charge_256);

    return _mint(to);
}
