//
//  BuyerInformation.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

struct BuyerInformation : Codable {
    var name: String
    var selectedNumber: Int
    var paidQuantity: Double
    
    enum CodingKeys: String, CodingKey {
        case name = "buyerName"
        case selectedNumber = "buyerSelectedNumber"
        case paidQuantity = "buyerPaidQuantity"
    }
    
}
