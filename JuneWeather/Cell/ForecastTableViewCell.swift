//
//  ForecastTableViewCell.swift
//  JuneWeather
//
//  Created by 이영준 on 10/10/2019.
//  Copyright © 2019 이영준. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    static let identifier = "ForecastTableViewCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var weatherImageLabel: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var tempratureLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
