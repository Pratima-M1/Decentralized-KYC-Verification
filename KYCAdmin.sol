// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract KYCAdmin{
    struct Bank{
        address bankEthAddress;
        string  bankName;
         uint256 kycCount;
        bool kycPrevilege;//to perform KYC of a customer
        bool permitToAddCustomer;
        uint256 noOfCustomers;
    }

    address KYCAdministrator;
    uint noOFBank=0;

    mapping(address=>Bank)banks;
    event NewBankAdded(address,string);
    event BankRemoved(address,string);


    constructor(){
        KYCAdministrator=msg.sender;
    }
    function addNewBank(address _bankEthAddress,string memory _bankName)public onlyKYCAdmin{
       require(banks[_bankEthAddress].bankEthAddress==address(0),"Bank address already exists");
         uint256 _kycCount=0;
         bool _kycPrevilege=false;
         bool _permitToAddCustomer=false;
         uint256 _noOfCustomers=0;
         banks[_bankEthAddress]=Bank(_bankEthAddress,_bankName,_kycCount,_kycPrevilege,_permitToAddCustomer,_noOfCustomers);
         noOFBank++;
         emit NewBankAdded(_bankEthAddress,_bankName );
    }
    function removeBank(address _bankEthAddress)public onlyKYCAdmin{
        require(banks[_bankEthAddress].bankEthAddress!=address(0),"Bank address doesn't exists");
        delete banks[_bankEthAddress];
        noOFBank--;
        emit BankRemoved(_bankEthAddress,banks[_bankEthAddress].bankName);
    }

    function viewBankDetails(address _bankEthAddress)public  view returns( address ,
        string memory,
         uint256 ,
        bool ,      
          bool ,
        uint256 ) {
        require(banks[_bankEthAddress].bankEthAddress!=address(0),"Bank address doesn't exists");
        return (banks[_bankEthAddress].bankEthAddress,
        banks[_bankEthAddress].bankName,banks[_bankEthAddress].kycCount,banks[_bankEthAddress].kycPrevilege,//to perform KYC of a customer
       banks[_bankEthAddress].permitToAddCustomer,
       banks[_bankEthAddress].noOfCustomers);
    }
     function numberOfBank()public view returns(uint) {
        return noOFBank;
    }

    function isValidBankAddress(address _bankEthAddress) public view returns(bool){
        if(banks[_bankEthAddress].bankEthAddress!=address(0))
            return true;
        return false;
    }

    function blockBankToAddCustomer(address _bankEthAddress) public  onlyKYCAdmin{
      banks[_bankEthAddress].permitToAddCustomer=false;
}

function allowBankToAddCustomer(address _bankEthAddress) public onlyKYCAdmin{
      banks[_bankEthAddress].permitToAddCustomer=true;
}

function isAllowedToAddCustomer(address _bankEthAddress)public  view returns(bool){
    if( banks[_bankEthAddress].permitToAddCustomer==true)
    return true;
    return false;
}

function blockBankFromKYC(address _bankEthAddress) public  onlyKYCAdmin{
      banks[_bankEthAddress].kycPrevilege=false;
}

function allowBankFromKYC(address _bankEthAddress)public  onlyKYCAdmin{
      banks[_bankEthAddress].kycPrevilege=true;
}

function updateNoOfCustomer(address _bankEthAddress)public {
    banks[_bankEthAddress].noOfCustomers++;
}

function numberOfCustomers(address _bankEthAddress)public view returns(uint256){
    return  banks[_bankEthAddress].noOfCustomers;
}
function isAllowedToPerformKYC(address _bankEthAddress)public  view returns(bool){
    if( banks[_bankEthAddress].kycPrevilege==true)
    return true;
    return false;
}

    modifier onlyKYCAdmin(){
        require(msg.sender==KYCAdministrator,"only KYC Admin can add or remove the bank details");
        _;
    }
}