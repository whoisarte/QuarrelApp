//
//  CurrentNumberState.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation
import UIKit

enum CurrentNumberState: String, Codable {
    case paid = "paid"
    case partialPaid = "partialPaid"
    case nonPaid = "nonPaid"
    case nonSelected = "nonSelected"
    
    var colorValue: UIColor {
        switch self {
        case .paid:
            return UIColor.systemGreen
        case .partialPaid:
            return UIColor.systemOrange
        case .nonPaid:
            return UIColor.systemRed
        case .nonSelected:
            return UIColor.systemPink
        }
    }
    
    var statusValue: String {
        switch self {
        case .paid:
            return "Pagado"
        case .partialPaid:
            return "Pendiente de completar pago"
        case .nonPaid:
            return "Sin pagar"
        case .nonSelected:
            return "Sin comprador"
        }
    }
}



