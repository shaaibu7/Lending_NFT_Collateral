// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.27;

import "../interfaces/IERC1155.sol";
import "../interfaces/IERC20.sol";
import "../libraries/LibDiamond.sol";

contract LendingFacet {

    //Custom Errors

    error LoanAmountExceeded();
    error TokenTransferFailed();
    // How to verify the market value of NFT on opensea
    //Testing:::::loan a specified amount of money for testing
    function getLoan(address NFTTokenAddress, uint256 id, uint256 amount, uint256 loanAmount) external {
        if (loanAmount > 5) {
            revert LoanAmountExceeded();
        }
        transferNFT(NFTTokenAddress, id, amount);
        address tokenAddress = LibDiamond.diamondStorage().USDTContractAddress;

        // confirm NFT transfer
        uint256 NFTBalance = IERC1155(NFTTokenAddress).balanceOf(address(this), id);

        if(NFTBalance == amount) {
            LibDiamond.diamondStorage().borrower[msg.sender] = loanAmount;
            IERC20(tokenAddress).transfer(msg.sender, loanAmount);
        }


    }

    // transfer NFT from owner to smart contract
    function transferNFT(address NFTTokenAddress, uint256 id, uint256 amount) internal {
        IERC1155(NFTTokenAddress).safeTransferFrom(msg.sender, address(this), id, amount, "");
    }

    function repayLoan() external {
        address tokenAddress = LibDiamond.diamondStorage().USDTContractAddress;
        // amount to repay
        uint256 loanAmountToPay = LibDiamond.diamondStorage().borrower[msg.sender];
        bool success = IERC20(tokenAddress).transferFrom(msg.sender, address(this), loanAmountToPay);
        if(!success) {
            revert TokenTransferFailed();
        }


    }


}