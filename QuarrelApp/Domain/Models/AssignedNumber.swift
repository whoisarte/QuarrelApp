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
    let buyerInformation: BuyerInformation
    
    init(state: CurrentNumberState, buyerInformation: BuyerInformation) {
        self.state = state
        self.buyerInformation = buyerInformation
    }
    
    func changeStatus(to status: CurrentNumberState) {
        self.state = status
    }
    
    enum CodingKeys: String, CodingKey {
        case buyerInformation
        case state = "numberState"
    }
}
