//
//  ViewController.swift
//  JuneWeather
//
//  Created by 이영준 on 10/10/2019.
//  Copyright © 2019 이영준. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController{
    func show(message: String){
        let alert = UIAlertController(title:"알림", message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title:"확인", style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated:true, completion:nil)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    
    lazy var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        return m
    }()
    
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
    
    
    //뷰가 로드될때 한번만 실행된다.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationLabel.text = "업데이트 중..."
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                updateCurrentLocation()
            case .denied, .restricted:
                show(message:"위치 서비스를 사용할 수 없습니다.")
            default:
                break
            }
        }else{
            show(message: "위치서비스가 꺼져있습니다.")
        }
    }
    
    var topInset: CGFloat = 0.0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if topInset == 0.0 {
            let first = IndexPath(row:0, section:0)
            if let cell = listTableView.cellForRow(at: first) {
                topInset = listTableView.frame.height - cell.frame.height
                listTableView.contentInset = UIEdgeInsets(top:topInset, left:0, bottom:0, right:0)
            }
            
        }
    }

}


extension ViewController: CLLocationManagerDelegate {
    
    func updateCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            print(loc.coordinate)
            
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(loc){[weak self] (placemarks, error) in
                if let place = placemarks?.first {
                    if let gu = place.locality, let dong = place.subLocality {
                        self?.locationLabel.text = "\(gu) \(dong)"
                    }else{
                        self?.locationLabel.text = place.name
                    }
                    
                }
                
            }
        }
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        show(message: error.localizedDescription)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            updateCurrentLocation()
        default:
            break
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
