// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Lottery is Ownable, ReentrancyGuard {
    // Error messages
    error NotEnoughMoneytoBuyTicket();
    error NotEnoughTicket();
    error NotInRightState();
    error ExceededmaxamountofTicketPerson();

    // Variables
    uint256 ticketentrynumber = 1;
    uint256 ticketprice = 0.0001 * 10 ** 18;
    uint256 lotterytime = 300;
    uint256 currenttime;
    uint256 lotterystarttime;
    uint256 lotteryendtime;
    uint256 prizeamount;
    uint256 winnerTicketNumber;
    address winnerAddress;
    uint256 maxamountofticket = 20;

    // Structure to represent a ticket
    struct TicketStructure {
        address participants;
        uint256 ticketnumber;
    }

    // Arrays and mappings to store tickets and ticket-related data
    TicketStructure[] ticketbox;
    mapping(address => uint256) ticketamount;
    mapping(address => uint256[]) tickets;
    mapping(uint256 => address) tickettoholder;

    // Constructor
    constructor() {
        currenttime = block.timestamp;
    }

    event CreateLottery(uint256 startingtime, uint256 endingtime);

    // Function to create a new lottery
    function createLottery() external onlyOwner nonReentrant {
        if (lotterystarttime != 0 || lotteryendtime != 0) {
            revert NotInRightState();
        }

        lotterystarttime = block.timestamp;
        lotteryendtime = lotterystarttime + lotterytime;
        currenttime = block.timestamp;
        winnerAddress = address(0);
        winnerTicketNumber = 0;
        emit CreateLottery(lotterystarttime, lotteryendtime);
    }

    event GetTicket(uint256 amount, address indexed holder);

    // Function to allow users to get lottery tickets in exchange for tokens (ETH in this case)
    function getTickets(uint256 amount) external payable nonReentrant {
        currenttime = block.timestamp;
        if (currenttime < lotterystarttime || currenttime > lotteryendtime) {
            revert NotInRightState();
        }
        if (amount > maxamountofticket) {
            revert ExceededmaxamountofTicketPerson();
        }

        // Calculate the price for the requested number of tickets
        uint256 price = amount * ticketprice;
        prizeamount += price;

        // Check if the lottery time has ended and update the state if needed

        // Require the user to send the correct amount of ETH
        require(price == msg.value, "Not enough money to buy ticket tokens");

        (bool success, ) = owner().call{value: price}("");
        require(success, "Transaction failed");

        uint256[] memory ticketnumbers = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            // Store the ticket entry number in the array and update other data
            ticketbox.push(TicketStructure(msg.sender, ticketentrynumber));
            ticketnumbers[i] = ticketentrynumber;
            tickettoholder[ticketentrynumber] = msg.sender;
            ticketentrynumber++;
        }

        // Update the user's ticket data and token balance
        tickets[msg.sender] = ticketnumbers;
        ticketamount[msg.sender] = amount;
        emit GetTicket(amount, msg.sender);
    }

    // Function for users to get their purchased tickets
    function getMyTickets() public view returns (uint256[] memory) {
        if (currenttime < lotterystarttime || currenttime > lotteryendtime) {
            revert NotInRightState();
        }

        uint256 amount = tickets[msg.sender].length;
        uint256[] memory tempTicket = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            tempTicket[i] = tickets[msg.sender][i];
        }
        return tempTicket;
    }

    // Function for the owner to select a winner and distribute the prize
    event winnerevent(
        address indexed winneraddress,
        uint256 ticketnumber,
        uint256 prizemoney
    );

    function winner()
        external
        payable
        onlyOwner
        nonReentrant
        returns (uint256)
    {
        currenttime = block.timestamp;
        if (currenttime < lotteryendtime) {
            revert NotInRightState();
        }
        if (lotteryendtime == 0 || lotterystarttime == 0) {
            revert NotInRightState();
        }
        require(msg.value == prizeamount, "Send the right prize money");

        // Generate a random number using blockhash-based random number generator

        winnerTicketNumber = _getRandomNumber(ticketentrynumber);
        winnerAddress = tickettoholder[winnerTicketNumber];

        // Send the prize amount to the winner
        (bool success, ) = winnerAddress.call{value: msg.value}("");
        require(success, "Transaction failed");
        emit winnerevent(winnerAddress, winnerTicketNumber, prizeamount);

        // Reset lottery data for the next round
        prizeamount = 0;
        ticketentrynumber = 1;
        lotteryendtime = 0;
        lotterystarttime = 0;

        return winnerTicketNumber;
    }

    // Function to generate a random number using blockhash
    function _getRandomNumber(uint256 limit) private view returns (uint256) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        return blockValue % limit;
    }

    function getstarttime() public view returns (uint256) {
        return lotterystarttime;
    }

    function getendtime() public view returns (uint256) {
        return lotteryendtime;
    }

    function getcurrenttime() public view returns (uint256) {
        return currenttime;
    }

    function getprizeamount() public view returns (uint256) {
        return prizeamount;
    }

    function winnerticketNumber() public view returns (uint256) {
        return winnerTicketNumber;
    }

    function getwinneraddress() public view returns (address) {
        return winnerAddress;
    }

    function changeticketprice(
        uint256 newprice
    ) external onlyOwner nonReentrant {
        if (lotteryendtime != 0 || lotterystarttime != 0) {
            revert NotInRightState();
        }
        ticketprice = newprice;
    }

    function changeLotterytime(
        uint256 _newblocktime
    ) external onlyOwner nonReentrant {
        if (lotteryendtime != 0 || lotterystarttime != 0) {
            revert NotInRightState();
        }
        lotterytime = _newblocktime;
    }

    function amountofmyticket() public view returns (uint256) {
        return ticketamount[msg.sender];
    }

    function myholdingtickets() public view returns (uint256[] memory) {
        return tickets[msg.sender];
    }

    function checkticketholder(uint256 ticketId) public view returns (address) {
        return tickettoholder[ticketId];
    }

    function getLotterytime() public view returns (uint256) {
        return lotterytime;
    }

    function getticketprice() public view returns (uint256) {
        return ticketprice;
    }

    function getmaxamountofticket() public view returns (uint256) {
        return maxamountofticket;
    }

    function changemaxamountofticket(
        uint256 _newamount
    ) external onlyOwner nonReentrant {
        if (lotteryendtime != 0 || lotterystarttime != 0) {
            revert NotInRightState();
        }
        maxamountofticket = _newamount;
    }
}
