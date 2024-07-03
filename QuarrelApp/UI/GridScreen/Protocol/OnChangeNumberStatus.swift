//
//  OnChangeNumberStatus.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

protocol OnChangedNumberStatus: AnyObject {
    func onChangedNumberStatus(at index: IndexPath)
    func onRetrieveNumbers()
}
