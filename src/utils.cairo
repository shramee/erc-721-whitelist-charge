from starkware.cairo.common.math import assert_nn, assert_not_equal, split_felt
from starkware.cairo.common.uint256 import Uint256

func felt_to_uint256( f: felt ) -> Uint256 {
    let (high, low) = split_felt(f);
    return Uint256(low=low, high=high);
}
