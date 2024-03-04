// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import {AlgebraPlugin, IAlgebraPlugin} from './base/AlgebraPlugin.sol';
import {IAlgebraPool} from '@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraPool.sol';
import {PoolInteraction} from './libraries/PoolInteraction.sol';
import {PluginConfig, Plugins} from './types/PluginConfig.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PromoHook is AlgebraPlugin, Ownable {
    error onlyPoolAllowed();

    struct SignedDiscount {
        uint16 newFeeBps;
        bytes signature;
    }

    PluginConfig private constant _defaultPluginConfig = PluginConfig.wrap(1); // dynamic fees enabled

    /// @notice the Algebra Integral pool
    IAlgebraPool public immutable pool;

    /// @notice my fee param
    uint16 public myFee;

    /// @notice promo signer
    address public promoSigner;

    mapping (bytes32 => SignedDiscount) public discounts;

    modifier onlyPool() {
        _checkOnlyPool();
        _;
    }

    constructor(address _pool, uint16 _myFee, address _promoSigner, address admin) Ownable(admin) {
        pool = IAlgebraPool(_pool);
        myFee = _myFee;
        promoSigner = _promoSigner;
    }

    function passSignerRole(address _promoSigner) external onlyOwner {
        promoSigner = _promoSigner;
    }

    function prepareDiscount(int256 amountRequired, address recipient, bool zeroToOne, uint16 newFeeBps, bytes calldata signature) external payable {
        bytes32 discountHash = keccak256(abi.encodePacked(amountRequired, recipient, zeroToOne, block.number));
        discounts[discountHash] = SignedDiscount(newFeeBps, signature);
    }

    /// @notice The hook called before a swap
    /// @param sender The initial msg.sender for the swap call
    /// @param recipient The address to receive the output of the swap
    /// @param zeroToOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountRequired The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param limitSqrtPrice The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param withPaymentInAdvance The flag indicating whether the `swapWithPaymentInAdvance` method was called
    /// @param data Data that passed through the callback
    /// @return bytes4 The function selector for the hook
    function beforeSwap(
        address sender,
        address recipient,
        bool zeroToOne,
        int256 amountRequired,
        uint160 limitSqrtPrice,
        bool withPaymentInAdvance,
        bytes calldata data
    ) external override returns (bytes4){
        bytes32 discountHash = keccak256(abi.encodePacked(amountRequired, recipient, zeroToOne, block.number));
        SignedDiscount memory discount = discounts[discountHash];
        if(discount.signature.length != 0) {
            require(ECDSA.recover(discountHash, discount.signature) == promoSigner, "PromoHook: invalid signature");
            PoolInteraction.changeFeeIfNeeded(pool, discount.newFeeBps);
        } 

        return IAlgebraPlugin.beforeSwap.selector;
    }

    /// @notice The hook called after a swap
    /// @param sender The initial msg.sender for the swap call
    /// @param recipient The address to receive the output of the swap
    /// @param zeroToOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountRequired The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param limitSqrtPrice The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @param amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    /// @param data Data that passed through the callback
    /// @return bytes4 The function selector for the hook
    function afterSwap(
        address sender,
        address recipient,
        bool zeroToOne,
        int256 amountRequired,
        uint160 limitSqrtPrice,
        int256 amount0,
        int256 amount1,
        bytes calldata data
    ) external override returns (bytes4){
        //set basic fee for the pool
        PoolInteraction.changeFeeIfNeeded(pool, myFee);
        return IAlgebraPlugin.afterSwap.selector;
    }

    function defaultPluginConfig() external pure override returns (uint8 pluginConfig) {
        return _defaultPluginConfig.unwrap();
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeInitialize(address sender, uint160 sqrtPriceX96) external onlyPool returns (bytes4) {
        sender; // suppress warning
        sqrtPriceX96; //suppress warning

        PoolInteraction.changePluginConfigIfNeeded(pool, _defaultPluginConfig);
        return IAlgebraPlugin.beforeInitialize.selector;
    }

    function _checkOnlyPool() internal view {
        if (msg.sender != address(pool)) revert onlyPoolAllowed();
    }
}
