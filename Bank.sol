// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KYCAdmin.sol";
contract Bank{
   
     struct Customer{
        uint256 customerId;
        string customerName;
         uint256 customerData;
        address customerBank;
        KYCStatus kycStatus;
        uint256 KYC;
    }

    enum KYCStatus{
       registered,
       underProcess,
       onHold,
       rejected,
       notAvailable,
       generated
    }
   mapping(uint256=>Customer) customers;
address bankAdmin;
KYCAdmin private kycAdmin;
event customerAdded(uint256,string);
event KYCGenerated(uint256,string);
event customerdataUpdated(uint256,string);
event customerRemoved(uint256);

constructor(address _kycAdminAddress){
    bankAdmin=msg.sender;
    kycAdmin=KYCAdmin(_kycAdminAddress);
}


function addNewCustomerToBank(uint256 _customerId,string memory _customerName,uint256 _data)public  onlyBank(){
     require(kycAdmin.isValidBankAddress(bankAdmin),"Not a valid bank address");
  //Permission to add customer
  require(kycAdmin.isAllowedToAddCustomer(bankAdmin),"Not allowed to add any customer");
    // require(customers[_customerId].customerName==_customerName,"customer already exists");
    address _customerBank=msg.sender;
    KYCStatus _kycStatus=KYCStatus.notAvailable;
    uint256 _KYC=0;
    customers[_customerId]=Customer(_customerId,_customerName,_data,_customerBank,_kycStatus,_KYC);
    kycAdmin.updateNoOfCustomer(bankAdmin);
    emit customerAdded(_customerId,_customerName);
}

function removeCustomer(uint _customerId)public onlyBank(){
    delete customers[_customerId];
    emit customerRemoved(_customerId);
}

function viewCustomerDetails(uint256 _customerId)public view returns(uint256 ,
        string memory,
         uint256 ,       
          address ,
        KYCStatus ,
        uint256 ){
            require(customers[_customerId].customerId!=0,"Invalid customer ID");
     return (customers[_customerId].customerId,customers[_customerId].customerName,customers[_customerId].customerData,customers[_customerId].customerBank,customers[_customerId].kycStatus,customers[_customerId].KYC);
}

function addNewCustomerRequestForKYC(uint256 _customerId)public{
        require(customers[_customerId].kycStatus==KYCStatus.notAvailable,"Please check the KYC Status");
        customers[_customerId].kycStatus=KYCStatus.registered;
}

function performKYCOfTheCustomer(uint256 _customerId)public{
      require( kycAdmin.isValidBankAddress(bankAdmin),"Not a valid bank address");
     //is Bank allowed to perform KYC??
    require( kycAdmin.isAllowedToPerformKYC(bankAdmin)!=false,"Bank is not allowed to perform the KYC of the customer");
    Customer storage performCustomerKYC=customers[_customerId];
    require(performCustomerKYC.kycStatus==KYCStatus.registered,"customer has not requested for the KYC");
    //perform KYC
     performCustomerKYC.KYC= (uint(keccak256(abi.encodePacked(performCustomerKYC.customerId,performCustomerKYC.customerName,performCustomerKYC.customerData,performCustomerKYC.customerBank))))%10**10;
    performCustomerKYC.kycStatus=KYCStatus.generated;
    emit KYCGenerated(_customerId,performCustomerKYC.customerName );
}

function updateCustomerData(uint256 _newCustomerData,uint256 _customerId)public onlyBank(){
    require(kycAdmin.isAllowedToAddCustomer(bankAdmin),"Not allowed to add any customer");
    Customer storage updateCustomer=customers[_customerId];
    updateCustomer.customerData=_newCustomerData;
    //update the KYC
    updateCustomer.KYC= (uint(keccak256(abi.encodePacked(updateCustomer.customerId,updateCustomer.customerName,updateCustomer.customerData,updateCustomer.customerBank))))%10**10;
     emit customerdataUpdated(_customerId,updateCustomer.customerName );
}

modifier onlyBank(){
    msg.sender==bankAdmin;
    _;
}

}