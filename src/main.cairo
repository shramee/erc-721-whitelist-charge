%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
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

from src.whitelist import (
    whitelist_addr_arr,
    whitelist_addresses,
    freemint_addresses)

from src.token_uri import (
    revealed,
    baseURL,
    LongURL,
    tokenURI,
    set_base_url
)

from src.royalties import royaltyInfo, setDefaultRoyalty, setTokenRoyalty
