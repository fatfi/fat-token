pragma solidity ^0.6.0;

import './owner/Operator.sol';
import './lib/BEP20Burnable.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Token is BEP20Burnable, Operator {

    uint256 private _cap = 120000000e18; // 120.000.000;

    uint256 private teamAllocation = _cap.mul(4).div(100); // The Team will hold 4% (4,800,000) of FATs.
    uint256 private adviserAllocation = _cap.mul(4).div(100); // Advisors will hold 4% (4,800,000) of FATs.
    uint256 private farmingAllocation = _cap.mul(17).div(100); // 17% (20,400,000) FATs will be staking rewards reserve
    uint256 private marketingAllocation = _cap.mul(4).div(100); // 4% (4,800,000) of FATs will be used for marketing & pr
    uint256 private privateSaleAllocation = _cap.mul(67).div(100); // Private Sale will hold 67% (80,400,000) of FATs.
    uint256 private publicSaleAllocation = _cap.mul(4).div(100); // Public Sale will hold 4% (4,800,000) of FATs.

    uint256 private teamReleased = 0;
    uint256 private adviserReleased = 0;
    uint256 private farmingReleased = 0;
    uint256 private marketingReleased = 0;
    uint256 private privateSaleReleased = 0;
    uint256 private publicSaleReleased = 0;


    uint private lastTeamReleased = now + 180 days; // 6 months after TGE
    uint private lastAdviserReleased = now + 180 days; // 6 months after TGE
    uint private lastMarketingReleased = now + 90 days; // unlock 25% every 3 months
    uint private lastPrivateSaleReleased = now + 90 days; // unlock 25% every 3 months


    uint256 private amountEachTeamRelease = teamAllocation.mul(5).div(100);
    uint256 private amountEachAdviserRelease = adviserAllocation.mul(5).div(100);
    uint256 private amountEachMarketingRelease = marketingAllocation.mul(25).div(100);
    uint256 private amountEachPrivateSaleRelease = privateSaleAllocation.mul(25).div(100);

    /**
     * @notice Constructs the Fat Token BEP-20 contract.
     */
    constructor(
        address _publicSaleTGEAddress,
        address _privateSaleTGEAddress
    ) public BEP20('Fatfi Protocol', 'FAT', 18) {
        _mint(_privateSaleTGEAddress,amountEachPrivateSaleRelease);
        privateSaleReleased = privateSaleReleased.add(amountEachPrivateSaleRelease);
        _mint(_publicSaleTGEAddress,publicSaleAllocation);
        publicSaleReleased = publicSaleReleased.add(publicSaleAllocation);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function releaseTeamAllocation(address _receiver) public onlyOperator {
        require(teamReleased.add(amountEachTeamRelease) <= teamAllocation, 'Max team allocation released');
        require(now - lastTeamReleased >= 1 days, 'Please wait to next checkpoint');
        _mint(_receiver,amountEachTeamRelease);
        teamReleased = teamReleased.add(amountEachTeamRelease);
        lastTeamReleased = lastTeamReleased + 30 days;
    }

    function releaseAdviserAllocation(address _receiver) public onlyOperator {
        require(adviserReleased.add(amountEachAdviserRelease) <= adviserAllocation, 'Max adviser allocation released');
        require(now - lastAdviserReleased >= 1 days, 'Please wait to next checkpoint');
        _mint(_receiver,amountEachAdviserRelease);
        adviserReleased = adviserReleased.add(amountEachAdviserRelease);
        lastAdviserReleased = lastAdviserReleased + 30 days;
    }

    function releaseMarketingAllocation(address _receiver) public onlyOperator {
        require(marketingReleased.add(amountEachMarketingRelease) <= marketingAllocation, 'Max marketing allocation released');
        require(now - lastMarketingReleased >= 1 days, 'Please wait to next checkpoint');
        _mint(_receiver,amountEachMarketingRelease);
        marketingReleased = marketingReleased.add(amountEachMarketingRelease);
        lastMarketingReleased = lastMarketingReleased + 90 days;
    }

    function releasePrivateSaleAllocation(address _receiver) public onlyOperator {
        require(privateSaleReleased.add(amountEachPrivateSaleRelease) <= privateSaleAllocation, 'Max privateSale allocation released');
        require(now - lastPrivateSaleReleased >= 1 days, 'Please wait to next checkpoint');
        _mint(_receiver,amountEachPrivateSaleRelease);
        privateSaleReleased = privateSaleReleased.add(amountEachPrivateSaleRelease);
        lastPrivateSaleReleased = lastPrivateSaleReleased + 90 days;
    }

    function releaseFarmAllocation(address _farmAddress, uint256 _amount) public onlyOperator {
        require(farmingReleased.add(_amount) <= farmingAllocation, 'Max farming allocation released');
        _mint(_farmAddress,_amount);
        farmingReleased = farmingReleased.add(_amount);
    }

    /**
     * @notice Operator mints Fat bonds to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of Fat bonds to mint to
     * @return whether the process has been done
     */

    function mint(address recipient_, uint256 amount_)
    public
    onlyOperator
    returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override onlyOperator {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
    public
    override
    onlyOperator
    {
        super.burnFrom(account, amount);
    }


    /**
     * @dev See {BEP20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // When minting tokens
            require(totalSupply().add(amount) <= cap(), "BEP20Capped: cap exceeded");
        }
    }
}
