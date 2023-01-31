%lang starknet
from src.whitelist import (
    _whitelist_meta,
    _whitelist,
    whitelist_addresses,
    freemint_addresses,
    stage_switch,
    can_mint,
    Lists
)
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
 
from starkware.cairo.common.alloc import alloc
from openzeppelin.access.ownable.library import Ownable

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return Ownable.initializer(0xad317);
}

func get_arr( item1: felt, item2: felt, item3: felt ) -> felt* {
    alloc_locals;

    let (ar: felt*) = alloc();

    assert ar[0] = item1;
    assert ar[1] = item2;
    assert ar[2] = item3;

    return (ar);
}

@external
func test_whitelist{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let addresses: felt* = get_arr( 0xf00, 0xb0b, 0);

    %{ stop_prank_callable = start_prank(0xad317) %}
    whitelist_addresses( 2, addresses );
    let (foo_whitelisted) = _whitelist.read(0xf00);
    assert foo_whitelisted = Lists.WHITELIST;
    let (bob_whitelisted) = _whitelist.read(0xb0b);
    assert bob_whitelisted = Lists.WHITELIST;
    %{ stop_prank_callable() %}
    return ();
}

@external
func test_freemint{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let addresses: felt* = get_arr( 0xf00, 0xb0b, 0);

    %{ stop_prank_callable = start_prank(0xad317) %}
    freemint_addresses( 2, addresses );
    let (foo_whitelisted) = _whitelist.read(0xf00);
    assert foo_whitelisted = Lists.FREEMINT;
    let (bob_whitelisted) = _whitelist.read(0xb0b);
    assert bob_whitelisted = Lists.FREEMINT;
    %{ stop_prank_callable() %}
    return ();
}

@external
func test_address_in_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    %{ stop_prank_callable = start_prank(0xad317) %}
    let addresses: felt* = get_arr( 0xf00, 0xb0b, 0);
    freemint_addresses( 2, addresses );
    %{ stop_prank_callable() %}

    let (listed) = address_in_list( 0xf00 );
    assert listed = Lists.FREEMINT;
    let (listed) = address_in_list( 0xbae );
    assert listed = 0; // Not listed
}

@external
func test_sale_stage{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (sale_stage) = _whitelist_meta.read('stage');
    assert 0 = sale_stage;

    stage_switch();

    let (sale_stage) = _whitelist_meta.read('stage');
    assert 1 = sale_stage;

    return ();
}

func assert_can_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( addr: felt, expect: felt ) {
    let i_can_mint = can_mint( addr );
    assert i_can_mint = expect;
    return ();
}

func assert_can_mint_ne{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( addr: felt, expect: felt ) {
    let i_can_mint = can_mint( addr );
    assert_not_equal(i_can_mint, expect);
    return ();
}

@external
func test_can_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let freemi = 0x234ca;
    let whitly = 0x8d76d;
    let johndo = 0x3c23a;
    _whitelist.write(freemi, Lists.FREEMINT);
    _whitelist.write(whitly, Lists.WHITELIST);

    _whitelist_meta.write('stage', 0);
    // Stage 0, freemint can mint, others can't
    assert_can_mint_ne( freemi, 0 ); // freemi can mint, not equals 0
    assert_can_mint( whitly, 0 ); // whitly can't mint, equals 0
    assert_can_mint( johndo, 0 ); // johndo can't mint, equals 0

    _whitelist_meta.write('stage', 1);
    // Stage 1, freemint and whitelisted can mint, others can't
    assert_can_mint_ne( freemi, 0 ); // freemi can mint, not equals 0
    assert_can_mint_ne( whitly, 0 ); // whitly can mint, not equals 0
    assert_can_mint( johndo, 0 ); // johndo can't mint, equals 0

    _whitelist_meta.write('stage', 2);
    // Stage 2, everyone can mint
    assert_can_mint_ne( freemi, 0 ); // freemi can mint, not equals 0
    assert_can_mint_ne( whitly, 0 ); // whitly can mint, not equals 0
    assert_can_mint_ne( johndo, 0 ); // johndo can mint, not equals 0

    return ();
}
