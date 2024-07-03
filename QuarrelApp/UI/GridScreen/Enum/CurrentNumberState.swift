//
//  CurrentNumberState.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

enum CurrentNumberState: String, Codable {
    case paid = "paid"
    case partialPaid = "partialPaid"
    case nonPaid = "nonPaid"
    case nonSelected = "nonSelected"
}



