// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";


interface IERC20_EXTENDED {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (string memory);
}

contract PresaleUpgradeable is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {

    address private _tokenSeller;
    address private _tokenContract;
    uint256 private _price;
    
    uint256 private _totallETHCollected;
    uint256 private _totalTokenSold;

    event TokenSold(address buyers, uint256 tokenValue);

    receive() external payable {
        buy();
    }
   
   function initialize() initializer public {
        _tokenSeller = 0x48eb4052F211E7A1d9deC09aEa2254DB2FB7d40a;
        _tokenContract = 0xaBa7822Df040F1BBcCBFb9EE7dEc77717E87ec9F;
        _price = 100000000000000000000;
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function buy() public payable returns (uint256 _valueSold) {
        address _msgSender = msg.sender;
        uint256 _msgValue = msg.value;

        uint256 tokenValue  = (_msgValue * _price) / 10 ** IERC20_EXTENDED(_tokenContract).decimals();
        
        _totallETHCollected += tokenValue;
        _totalTokenSold += tokenValue;

        emit TokenSold(_msgSender, tokenValue);

        IERC20Upgradeable(_tokenContract).transferFrom(_tokenSeller, _msgSender, tokenValue);
        
        return tokenValue; 
    }

    function getTokenContract() external view returns (address _tokenContractAddress, string memory _tokenName, string memory _tokenSymbol, uint256 _tokenDecimals, address _tokenSellerAddress) {
        _tokenContractAddress = _tokenContract;
        _tokenName = IERC20_EXTENDED(_tokenContract).name();
        _tokenSymbol = IERC20_EXTENDED(_tokenContract).symbol();
        _tokenDecimals = IERC20_EXTENDED(_tokenContract).decimals();
        _tokenSellerAddress = _tokenSeller;
    }
    
    function getPresaleAnalytics() external view returns (uint256 _ethCollected, uint256 _tokenSold){
        _ethCollected = _totallETHCollected;
        _tokenSold = _totalTokenSold;
    }

    //Admin function

    function withdrawETH() external onlyOwner {
        payable(_tokenSeller).transfer(address(this).balance);
    }

    function withdrawPartialETH(address _to, uint256 _valueInwei) external onlyOwner {
        payable(_to).transfer(_valueInwei);
    }

    function withdrawTokenPartially(address _to, uint256 _valueInwei, address _tokenContractAddress) external onlyOwner {
        IERC20Upgradeable(_tokenContractAddress).transfer(_tokenSeller, _valueInwei);
    }

    function withdrawToken(address _tokenContractAddress) external onlyOwner {
        uint256 totalValue = IERC20Upgradeable(_tokenContractAddress).balanceOf(address(this));
        IERC20Upgradeable(_tokenContractAddress).transfer(_tokenSeller, totalValue);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
