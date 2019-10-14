//
//  ViewController.swift
//  JuneWeather
//
//  Created by 이영준 on 10/10/2019.
//  Copyright © 2019 이영준. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let tempFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "Ko_KR")
        
        return formatter
    }()
    
    @IBOutlet weak var listTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //뷰가 실행되고 나면 아래의 코드를 실행한다. 위도 경도를 갖고와서 fetchSummary와 fetchForecast를 수행한다.
        WeatherDataSource.shared.fetchSummary(lat: 37.59063130183221, lon: 127.01762655200862){
            [weak self] in
            self?.listTableView.reloadData()
        }
        
        WeatherDataSource.shared.fetchForecast(lat: 37.59063130183221, lon: 127.01762655200862){
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
            return WeatherDataSource.shared.forecastList.count
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
        
        let target = WeatherDataSource.shared.forecastList[indexPath.row]
        dateFormatter.dateFormat = "M.d (E)"
        cell.dateLabel.text = dateFormatter.string(from: target.date)
        
        dateFormatter.dateFormat = "HH:00"
        cell.timeLabel.text = dateFormatter.string(from: target.date)
        
        cell.weatherImageView.image = UIImage(named: target.skyCode)
        
        cell.statusLabel.text = target.skyName
        
        let tempStr = tempFormatter.string(for: target.temperature) ?? "-"
        cell.temperatureLabel.text = "\(tempStr)°"
        
        return cell
    }
    
}
