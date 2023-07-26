// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract GoverToken is ERC20, ERC20Votes {
    uint256 constant maxTokensupply = 10000000 * 10 ** 18;
    uint256 constant tokenPerUser = 1000 * 10 ** 18;

    constructor(
        uint256 percentages
    ) ERC20("GoverToken", "GT") ERC20Permit("GoverToken") {
        uint256 keep = (maxTokensupply * percentages) / 100;
        _mint(msg.sender, maxTokensupply);
        uint256 amount = maxTokensupply - keep;
        _transfer(msg.sender, address(this), amount);
    }

    address[] public tokenholders;
    mapping(address => bool) public havetoken;
    event GETfreeToken(address from, address to, uint256 amount);
    event AddHolder(address indexed holder);

    function getMyfreeToken() external {
        require(havetoken[msg.sender] != true, "Already got the token");
        _transfer(address(this), msg.sender, tokenPerUser);
        havetoken[msg.sender] = true;
        tokenholders.push(msg.sender);
        emit AddHolder(msg.sender);
        emit GETfreeToken(address(this), msg.sender, tokenPerUser);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
