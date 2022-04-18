//
//  UploadTVC.swift
//  Bigg.ly
//
//

import UIKit
import KDCircularProgress
class UploadTVC: UITableViewCell {

    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var titleLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
