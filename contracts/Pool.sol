pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./DETH.sol";
contract Pool is ERC721 {
   
    enum Duration { _3_MONTHS, _12_MONTHS, _36_MONTHS}
    
    struct Voucher {
        Duration period;
        uint256 amount;
        uint256 timestamp;
    }

    DETH private _token;

    mapping (uint256 => Voucher) private _id_to_voucher;
    uint256 private _currId;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _token = new DETH("TestToken", "TT", _msgSender());
    }

    function getDETH() public view returns(address){
        return address(_token);
    }
    function getVoucher(uint256 tokenId_) public view returns (Duration, uint256, uint256){
        return (_id_to_voucher[tokenId_].period, _id_to_voucher[tokenId_].amount,  _id_to_voucher[tokenId_].timestamp);
    }

    function mintVoucher(address to, Duration period) external payable{
        _mint(to, _currId);
        _id_to_voucher[_currId++] = Voucher(period, msg.value, block.timestamp);
    }

    // burn voucher, owner of the nft receives back deth
    function burnVoucher(uint256 tokenId_) external {
        // address owner = getApproved(id);
        require(_isApprovedOrOwner(_msgSender(), tokenId_), "ERC721: burning caller is not owner nor approved");
        _burnVoucher(ownerOf(tokenId_),tokenId_);
    }

    // burn voucher, to_ receives back deth
    function burnVoucherTo(address to_, uint256 tokenId_) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId_),  "ERC721: burning caller is not owner nor approved");
        _burnVoucher(to_, tokenId_);
    }

    // assume 3 months --> 10% yield, 12 months --> 15% yield, 36 months --> 20% yield
    function _burnVoucher(address to_, uint256 tokenId_) internal {
        Voucher memory voucher = _id_to_voucher[tokenId_];
        uint256 deth_paid;
        if (voucher.period == Duration._3_MONTHS)
        {
            require(block.timestamp >= voucher.timestamp + 30 days, "Voucher requires waiting for at least 30 days to be burned");
            deth_paid = voucher.amount * 110 / 100;
        }
        else if (voucher.period == Duration._12_MONTHS)
        {
            require(block.timestamp >= voucher.timestamp + 360 days, "Voucher requires waiting for at least 12 months to be burned");
            deth_paid = voucher.amount * 115 / 100;
        }    
        else  
        {
            require(block.timestamp >= voucher.timestamp + 1080 days, "Voucher requires waiting for at least 36 months to be burned");
            deth_paid = voucher.amount * 120 / 100;
        }
        _token.transfer(to_, deth_paid);
        delete _id_to_voucher[tokenId_];
        _burn(tokenId_);
    }
}