//
//  EmailManager.swift
//  SoSueMe
//
//  Created by Pavlo Dumyak on 3/1/17.
//  Copyright © 2017 Inoxoft. All rights reserved.
//

import UIKit

class EmailManager: NSObject {

    static let sharedInstance = EmailManager()
    var generalEmail = Email()
    
    func setup(name: String, email: String, country: String, city: String) {
        generalEmail.firstName = name
        generalEmail.lastName = name
        generalEmail.contactEmail = email
        generalEmail.country = country
        generalEmail.city = city
    }
    
    func setup(claimList: String) {
        generalEmail.claimList = claimList
    }
    
    func setup(personalName: String, personalAddress: String, defendantName: String, defendantAddress: String, amount: String, transactionDate: String, transactionPlace: String, primaryReason: String) {
        generalEmail.personalName = personalName
        generalEmail.personalAddres = personalAddress
        generalEmail.defendantName = defendantName
        generalEmail.defendantAddress = defendantAddress
        generalEmail.amount = amount
        generalEmail.transactionDate = transactionDate
        generalEmail.primaryReason = primaryReason
    }
    
    func setup(claimText: String) {
        generalEmail.textOfClaim = claimText
    }
    
    func getEmailBody() -> String {
        var body = ""
        body += "First Name:" + generalEmail.firstName + "\n" + "Last Name:" + generalEmail.lastName + "\n" + "Personal email:" + generalEmail.contactEmail + "\n" + "Country:" + generalEmail.country + "\n" + "City:" + generalEmail.city + "\n\n Claim list:" + generalEmail.claimList + "\n\n Personal Info:\n" + generalEmail.personalName + "\n" + generalEmail.personalAddres + "\n\n Defendant'sinfo:\n" + generalEmail.defendantName + "\n" + generalEmail.defendantAddress + "\n \n \n" + "Claim info:\n" + "Amount:" + generalEmail.amount + "\n Date of transaction/occurance:" + generalEmail.transactionDate + "\n Place of transaction/occurance:" + generalEmail.transactionPlace + "\n Primary reason for claim:" + generalEmail.primaryReason + "\n\n\n Claim text:\n\n\n" + generalEmail.textOfClaim
        return body
    }
}
