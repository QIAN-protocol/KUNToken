pragma solidity 0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Modified from Administered
 * @author Alberto Cuesta Canada
 * @notice Implements Admin and User roles.
 */
contract MinterControl is AccessControl {
    using SafeMath for uint256;

    event AddMinter(address account, uint256 mintAllowance);
    event RemoveMinter(address account);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    mapping(address => uint256) public mintAllowances;

    /// @dev Add `root` to the admin role as a member.
    // constructor(address root) public {
    //     _setupRole(DEFAULT_ADMIN_ROLE, root);
    //     _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
    // }

    function initializeMinterControl(address admin) internal {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /// @dev Restricted to members of the admin role.
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admins.");
        _;
    }
    /// @dev Restricted to members of the minter role.
    modifier onlyMinter() {
        require(isMinter(msg.sender), "Restricted to minters.");
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public virtual view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Return `true` if the account belongs to the minter role.
    function isMinter(address account) public virtual view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    /// @dev Add an account to the minter role. Restricted to admins.
    function addMinter(address account, uint256 amount)
        public
        virtual
        onlyAdmin
    {
        grantRole(MINTER_ROLE, account);
        _approveMint(account, amount);
        emit AddMinter(account, amount);
    }

    /// @dev Remove an account from the minter role. Restricted to admins.
    function removeMinter(address account) public virtual onlyAdmin {
        revokeRole(MINTER_ROLE, account);
        _approveMint(account, 0);
        emit RemoveMinter(account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdmin(address account) public virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function increaseMintAllowance(address minter, uint256 addedValue)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _approveMint(minter, mintAllowances[minter].add(addedValue));
        return true;
    }

    function decreaseMintAllowance(address minter, uint256 subtractedValue)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _approveMint(
            minter,
            mintAllowances[minter].sub(
                subtractedValue,
                "Decreased mint-allowance below zero"
            )
        );
        return true;
    }

    function _approveMint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Approve mint to the zero address");
        mintAllowances[account] = amount;
    }
}
