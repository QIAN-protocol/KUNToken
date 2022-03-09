pragma solidity 0.6.2;

import "./lib/ERC20Capped.sol";
import "./lib/MinterControl.sol";
import "./lib/VersionedInitializable.sol";

contract KUN is ERC20Capped, MinterControl, VersionedInitializable {
    using SafeMath for uint256;

    uint256 public constant maxSupply = 12000000000000000000000000;

    event DestroyedBlackFunds(address account, uint256 balance);
    event AddedBlackList(address account);
    event RemovedBlackList(address account);

    mapping(address => bool) public isBlackListed;

    function initialize(address admin) public initializer {
        initializeMinterControl(admin);
        initializeERC20Capped("QIAN governance token", "KUN", 18, maxSupply);
    }
    
    function addBlackList(address account) public onlyAdmin {
        isBlackListed[account] = true;
        emit AddedBlackList(account);
    }

    function removeBlackList(address account) public onlyAdmin {
        isBlackListed[account] = false;
        emit RemovedBlackList(account);
    }

    function destroyBlackFunds(address account) public onlyAdmin {
        require(isBlackListed[account], "account not in blacklist");
        uint256 dirtyFunds = balanceOf(account);
        _burn(account, dirtyFunds);
        emit DestroyedBlackFunds(account, dirtyFunds);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(!isBlackListed[msg.sender], "blacklist");
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!isBlackListed[sender], "blacklist");
        return super.transferFrom(sender, recipient, amount);
    }

    function mint(address account, uint256 amount) public onlyMinter {
        _mint(account, amount);
        _approveMint(
            _msgSender(),
            mintAllowances[_msgSender()].sub(
                amount,
                "Mint amount exceeds allowance"
            )
        );
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function getRevision() internal override pure returns (uint256) {
        return uint256(0x1);
    }
}
