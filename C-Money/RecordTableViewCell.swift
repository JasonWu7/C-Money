//
//  RecordTableViewCell.swift
//  C-Money
//
//  Created by Dongzheng Wu on 29/4/2023.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var recordCategoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
