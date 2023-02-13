%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.token.erc721.library import ERC721
from src.OpenZepplin_ERC721MintableBurnable import (
    supportsInterface,
    name,
    symbol,
    balanceOf,
    ownerOf,
    getApproved,
    isApprovedForAll,
    owner,
    approve,
    setApprovalForAll,
    transferFrom,
    safeTransferFrom,
    burn,
    setTokenURI,
    transferOwnership,
    renounceOwnership
)

from src.mint import (
    mint,
    TokenLimit, NextTokenID,
    MintCharge, PaymentTokenAddress
)

from src.whitelist import (
    whitelist_addr_arr,
    whitelist_addresses,
    freemint_addresses,
    stage_switch
)

from src.token_uri import (
    revealed,
    baseURL,
    LongURL,
    tokenURI,
    set_base_url
)

from src.royalties import royaltyInfo, setDefaultRoyalty, setTokenRoyalty


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, owner: felt, token_limit: felt, mint_charge: felt, payment_token_addr: felt
) {
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);

    // token_limit and payment token addr addr
    TokenLimit.write(token_limit);
    PaymentTokenAddress.write(payment_token_addr);
    MintCharge.write(mint_charge);
    NextTokenID.write(0); // Unnecessary but establishes semantics
    return ();
}
