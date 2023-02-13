%lang starknet

from src.mint import (
    mint,
    TokenLimit, NextTokenID,
    MintCharge, PaymentTokenAddress,
    get_available_token_id, _mint
)

from src.whitelist import WhitelistedAddresses, WhitelistSaleStage, Lists

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.uint256 import Uint256

@external
func __setup__() {
  %{
    context.eth_dummy = deploy_contract("tests/assets/eth_dummy.cairo", []).contract_address
  %}

  return ();
}

@external
func test_token_id_limit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    TokenLimit.write(100);
    NextTokenID.write(101); // All tokens minted!
    %{ expect_revert() %}
    let token_id = get_available_token_id(); // This should fail, making the test pass.
    return ();
}

@external
func test_token_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    TokenLimit.write(100);
    NextTokenID.write(25);
    let token_id = get_available_token_id();
    assert token_id = 25;
    return ();
}

@external
func test__mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    TokenLimit.write(100);
    let token_id = get_available_token_id();

    // increment available token ID
    _mint( 0xf00 );

    let next_token_id = get_available_token_id();
    assert next_token_id = token_id + 1;

    return ();
}

func _test_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    caller: felt
) {
    TokenLimit.write(100);
    let dummy_token_uint = Uint256(0, 0);
    %{ stop_prank_callable = start_prank(ids.caller) %}
    mint(caller, dummy_token_uint);
    %{stop_prank_callable()%}
    return ();
}

@external
func test_minting{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Set eth dummy contract
    tempvar eth_dummy;
    %{ids.eth_dummy = context.eth_dummy%}
    PaymentTokenAddress.write( eth_dummy );

    // Test wallets
    let freemi = 0x234ca;
    let whitly = 0x8d76d;
    let johndo = 0x3c23a;
    WhitelistedAddresses.write(freemi, Lists.FREEMINT);
    WhitelistedAddresses.write(whitly, Lists.WHITELIST);

    WhitelistSaleStage.write(1);
    // Stage 1, freemint and whitelisted can mint, others can't
    _test_mint(freemi);
    %{ assert_fees_contract_called = expect_call(context.eth_dummy, "transfer", [0, 0, 0]) %}
    _test_mint(whitly);
    %{ assert_fees_contract_called() %}

    %{ expect_revert() %}
    _test_mint(johndo);

    return ();
}

@external
func test_double_minting{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    WhitelistedAddresses.write(0xf008, Lists.FREEMINT);
    WhitelistSaleStage.write(1);

    // Should work the first time
    _test_mint(0xf008);

    // Should fail after first mint
    %{ expect_revert(); %}
    _test_mint(0xf008);
    return ();
}