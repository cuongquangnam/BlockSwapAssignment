pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DETH is ERC20 {
    address _minter;
    constructor (string memory name_, string memory symbol_, address minter_) ERC20(name_, symbol_) {
        _minter = minter_;
    }

    modifier onlyMinter {
        require(msg.sender == _minter);
        _;
    }

    function mint(address account, uint256 amount) external onlyMinter{
        _mint(account, amount);
    }
}


