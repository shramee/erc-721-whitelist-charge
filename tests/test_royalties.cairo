%lang starknet

from src.mint import (
    mint,
    TokenLimit, NextTokenID,
    MintCharge, PaymentTokenAddress,
    get_available_token_id, _mint
)

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.uint256 import Uint256

from src.royalties import (royalty_initializer, royaltyInfo)

from immutablex.starknet.auxiliary.erc2981.immutable import FEE_DENOMINATOR

@external
func test_royalties_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (receiver, royalty_amount) = royaltyInfo( Uint256(0,0), Uint256(2500,0) );

    assert receiver = 0;
    assert royalty_amount = Uint256(0,0);

    return ();
}

@external
func test_royalties_info_initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let ROYALTY_HUNDREDTH_PERCENT = 500;
    let SALE_PRICE = 10000;
    let EXPECTED_ROYALTY_AMT = SALE_PRICE * ROYALTY_HUNDREDTH_PERCENT / FEE_DENOMINATOR;
    
    royalty_initializer( 0xb0b, 500 );
    
    let (receiver, royalty_amount) = royaltyInfo( Uint256(0,0), Uint256(SALE_PRICE,0) );

    assert receiver = 0xb0b;
    assert royalty_amount = Uint256(EXPECTED_ROYALTY_AMT,0);

    return ();
}
