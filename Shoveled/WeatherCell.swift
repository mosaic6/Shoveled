//
//  WeatherCellCollectionViewCell.swift
//  Shoveled
//
//  Created by Joshua Walsh on 10/31/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCurrentWeather: UIImageView!
    @IBOutlet weak var lblMinMaxTemp: UILabel!
    @IBOutlet weak var lblAccumulation: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
