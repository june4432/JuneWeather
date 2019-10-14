//
//  ViewController.swift
//  JuneWeather
//
//  Created by 이영준 on 10/10/2019.
//  Copyright © 2019 이영준. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let tempFormatter :NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        
        return formatter
    }()
    
    @IBOutlet weak var listTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WeatherDataSource.shared.fetchSummary(lat: 37.59063130183221, lon: 127.01762655200862){
            [weak self] in
            self?.listTableView.reloadData()
        }
    }


}


extension ViewController:UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) ->Int{
        switch section{
        case 0:
            return 1
        case 1:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: SummaryTableViewCell.identifier, for: indexPath) as! SummaryTableViewCell
            
            if let data = WeatherDataSource.shared.summary?.weather.minutely.first {
                cell.weatherImageView.image = UIImage(named: data.sky.code)
                cell.statusLabel.text = data.sky.name
                
                let max = Double(data.temperature.tmax) ?? 0.0
                let min = Double(data.temperature.tmin) ?? 0.0
                
                let maxStr = tempFormatter.string(for:max) ?? "-"
                let minStr = tempFormatter.string(for:min) ?? "-"
                
                cell.minMaxLabel.text = "최대 \(maxStr)° 최소 \(minStr)°"
                
                let tc = Double(data.temperature.tc) ?? 0.0
                let tcStr = tempFormatter.string(for:tc) ?? "-"
                
                cell.currentTemperatureLabel.text = "\(tcStr)°"
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.identifier, for: indexPath) as! ForecastTableViewCell
        return cell
    }
    
}
