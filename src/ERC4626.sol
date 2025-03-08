
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract MySimpleVault is ERC4626 {

    // The underlying asset (e.g., USDC)
    ERC20 public immutable asset;

    constructor(ERC20 _asset, string memory _name, string memory _symbol)
        ERC20(_name, _symbol) // The vault's share token is an ERC20
        ERC4626()
    {
        asset = _asset;
    }

    // IMPORTANT:  You MUST implement these two functions.
    //  They MUST be accurate, or your vault will break.
    function totalAssets() public view override returns (uint256) {
        // In this *super* simple example, we assume no yield strategies.
        // The total assets are simply the vault's balance of the underlying asset.
        return asset.balanceOf(address(this));
    }

     function _asset() internal view virtual override returns (ERC20) {
        return asset;
    }

     // Deposit (simplified)
    function deposit(uint256 _assets, address _receiver) public override returns (uint256 shares)
    {
        //preview checks
        require(_assets <= maxDeposit(_receiver), "Deposit exceeds maximum");
        shares = previewDeposit(_assets);
        require(shares > 0, "Zero shares");

        // Transfer the underlying asset from the user to the vault.
        asset.transferFrom(msg.sender, address(this), _assets);

        // Mint shares to the receiver.
        _mint(_receiver, shares);

        emit Deposit(msg.sender, _receiver, _assets, shares);
    }

    // Withdraw (simplified)
    function withdraw(uint256 _assets, address _receiver, address _owner) public override returns (uint256 shares)
    {
        //preview checks
        require(_assets <= maxWithdraw(_owner), "Withdraw exceeds maximum");
        shares = previewWithdraw(_assets);
        require(shares > 0, "Zero shares");
        if (msg.sender != _owner) {
            _spendAllowance(_owner, msg.sender, shares);
        }
        // Burn shares from the owner.
        _burn(_owner, shares);

        // Transfer the underlying asset from the vault to the receiver.
        asset.transfer(_receiver, _assets);
        emit Withdraw(_owner, _receiver, _owner, _assets, shares);
    }

    // Example of previewDeposit (very simplified)
    function previewDeposit(uint256 _assets) public view override returns (uint256) {
        // If no assets are in the vault, 1 asset = 1 share.
        if (totalAssets() == 0) {
            return _assets;
        }
        // Otherwise, calculate shares based on the current ratio.
        return (_assets * totalSupply()) / totalAssets();
    }

     // Example of previewWithdraw (very simplified)
    function previewWithdraw(uint256 _shares) public view virtual override returns (uint256) {
      if (totalSupply() == 0) {
            return _shares;
        }
        return (_shares * totalAssets()) / totalSupply();
    }

    // In a real vault, you'd likely have yield-generating logic,
    // which would affect totalAssets() and the conversion rates.

    // ... other ERC-4626 functions (maxDeposit, etc.) ...
    // You MUST implement all the required ERC-4626 functions!
}
