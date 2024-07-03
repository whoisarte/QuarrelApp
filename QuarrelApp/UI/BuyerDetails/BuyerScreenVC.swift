//
//  BuyerScreenVC.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import UIKit

class BuyerScreenVC: UIViewController {
    static let identifier: String = "BuyerScreenVC"
    static let storyboard: String = "Main"
    var indexPath: IndexPath?
    var number: AssignedNumber?
    var didUpdateNumber: ((AssignedNumber) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurateNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configurateNavigationBar() {
        self.navigationItem.title = "Número \(self.number?.buyerInformation.selectedNumber ?? 9999999)"
        self.navigationController?.navigationBar.tintColor = .systemPink
        self.navigationController?.navigationBar.barTintColor = .systemPink
    }
    
}
