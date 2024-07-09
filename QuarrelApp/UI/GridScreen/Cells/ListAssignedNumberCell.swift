//
//  ListAssignedNumberCell.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 09/07/24.
//

import UIKit

class ListAssignedNumberCell: UICollectionViewCell {
    static let identifier: String = "ListAssignedNumberCell"
    @IBOutlet weak var viewContainerNumber: UIView!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelBuyer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewContainerNumber.layer.borderColor = UIColor.lightGray.cgColor
        self.viewContainerNumber.layer.borderWidth = 0.5
        self.viewContainerNumber.layer.cornerRadius = 10.0
    }
    
    func configureListCell(with number: String, buyer: String, currentNumberState: CurrentNumberState) {
        self.viewContainerNumber.backgroundColor = currentNumberState == .nonSelected ? .white : currentNumberState.colorValue
        self.labelNumber.text = number
        self.labelBuyer.text = buyer
    }

}
