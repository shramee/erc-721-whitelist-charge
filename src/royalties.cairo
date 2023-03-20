%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.bool import TRUE, FALSE

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.token.erc721.library import ERC721_owners

from immutablex.starknet.auxiliary.erc2981.immutable import (
    ERC2981_Immutable, ERC2981_Immutable_royalty_info
)

func royalty_initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    receiver: felt, fee_basis_points: felt
) {
    return ERC2981_Immutable.initializer(receiver, fee_basis_points);
}

@external
func royaltyInfo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
   token_id: Uint256, sale_price: Uint256 
) -> (receiver: felt, royalty_amount: Uint256) {
    return ERC2981_Immutable.royalty_info(token_id, sale_price);
}