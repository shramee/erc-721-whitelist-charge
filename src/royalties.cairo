%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.token.erc721.library import ERC721_owners

from src.erc2981.unidirectional_mutable import (
    ERC2981_UniDirectional_Mutable,
)

@view
func royaltyInfo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256, salePrice: Uint256
) -> (receiver: felt, royaltyAmount: Uint256) {
    let (exists) = _exists(tokenId);
    with_attr error_message("Token ID does not exist.") {
        assert exists = TRUE;
    }
    let (receiver: felt, royaltyAmount: Uint256) = ERC2981_UniDirectional_Mutable.royalty_info(
        tokenId, salePrice
    );
    return (receiver, royaltyAmount);
}

func _exists{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (res: felt) {
    let (res) = ERC721_owners.read(token_id);

    uint256_check(token_id);

    if (res == 0) {
        return (FALSE,);
    } else {
        return (TRUE,);
    }
}

@external
func setDefaultRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    receiver: felt, feeBasisPoints: felt
) {
    Ownable.assert_only_owner();
    ERC2981_UniDirectional_Mutable.set_default_royalty(receiver, feeBasisPoints);
    return ();
}

@external
func setTokenRoyalty{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256, receiver: felt, feeBasisPoints: felt
) {
    Ownable.assert_only_owner();
    let (exists) = _exists(tokenId);
    with_attr error_message("ERC721: token ID does not exist") {
        assert exists = TRUE;
    }
    ERC2981_UniDirectional_Mutable.set_token_royalty(tokenId, receiver, feeBasisPoints);
    return ();
}