//
//  AssignedNumberCell.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import UIKit

class AssignedNumberCell: UICollectionViewCell {
    static let identifier: String = "AssignedNumberCell"

    @IBOutlet weak var viewContainerNumber: UIView!
    @IBOutlet weak var labelNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewContainerNumber.layer.borderColor = UIColor.lightGray.cgColor
        self.viewContainerNumber.layer.borderWidth = 0.5
        self.viewContainerNumber.layer.cornerRadius = 10.0
    }
    
    func configureCell(with state: CurrentNumberState, number: String) {
        self.labelNumber.text = number
        self.setColor(by: state)
    }
    
    func changeState(to state: CurrentNumberState) {
        self.setColor(by: state)
    }
    
    func changeBorderWidth(to width: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.viewContainerNumber.layer.borderWidth = width
        }
    }
    
    func setColor(by state: CurrentNumberState) {
        self.changeBorderWidth(to: state == .nonSelected ? 0.5 : 0.0)
        switch state {
        case .paid:
            self.viewContainerNumber.backgroundColor = .systemGreen
        case .partialPaid:
            self.viewContainerNumber.backgroundColor = .systemOrange
        case .nonPaid:
            self.viewContainerNumber.backgroundColor = .systemRed
        case .nonSelected:
            self.viewContainerNumber.backgroundColor = .white
        }
    }
}
