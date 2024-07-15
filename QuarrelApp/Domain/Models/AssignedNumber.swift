//
//  AssignedNumber.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

class AssignedNumber: Codable {
    static let localNumbersIdentifier: String = "localNumbersIdentifier"
    var state: CurrentNumberState
    var buyerInformation: BuyerInformation
    var documentID: String? = ""
    
    init(state: CurrentNumberState, buyerInformation: BuyerInformation) {
        self.state = state
        self.buyerInformation = buyerInformation
    }
    
    init(number: AssignedNumber) {
        self.state = number.state
        self.buyerInformation = number.buyerInformation
    }
    
    func changeStatus(to status: CurrentNumberState) {
        self.state = status
    }
    
    func setQuantity(quantity: Double) {
        self.buyerInformation.paidQuantity = quantity
    }
    
    func getDocumentId() -> String {
        if let documentID,
           documentID != ""{
            return documentID
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case buyerInformation
        case state = "numberState"
        case documentID
    }
}
