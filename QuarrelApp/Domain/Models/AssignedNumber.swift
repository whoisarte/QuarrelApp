//
//  AssignedNumber.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

struct AssignedNumber: Codable {
    static let localNumbersIdentifier: String = "localNumbersIdentifier"
    let state: CurrentNumberState
    let buyerInformation: BuyerInformation
    
    init(state: CurrentNumberState, buyerInformation: BuyerInformation) {
        self.state = state
        self.buyerInformation = buyerInformation
    }
    
    enum CodingKeys: String, CodingKey {
        case buyerInformation
        case state = "numberState"
    }
}
