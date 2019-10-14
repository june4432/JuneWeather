//
//  Model.swift
//  JuneWeather
//
//  Created by 이영준 on 2019/10/12.
//  Copyright © 2019 이영준. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherSummary: Codable {
    struct Weather: Codable{
        struct Minutely: Codable{
            struct Sky: Codable{
                let code: String
                let name: String
            }
            struct Temperature: Codable{
                let tc: String
                let tmax: String
                let tmin: String
            }
            let sky: Sky
            let temperature: Temperature
        }
        let minutely: [Minutely] //Minutely의 배열구조체
    }
 
    struct Result: Codable{
       let code: Int
       let message: String
    }
       
   let weather:Weather
   let result:Result
   
}

struct Forecast: Codable{
    struct Weather: Codable{
        struct Forecast3Days: Codable{
            struct Fcst3Hour: Codable{
                @objcMembers class Sky: NSObject,Codable {
                    let code4hour: String
                    let name4hour: String
                    let code7hour: String
                    let name7hour: String
                    let code10hour: String
                    let name10hour: String
                    let code13hour: String
                    let name13hour: String
                    let code16hour: String
                    let name16hour: String
                    let code19hour: String
                    let name19hour: String
                    let code22hour: String
                    let name22hour: String
                    let code25hour: String
                    let name25hour: String
                    let code28hour: String
                    let name28hour: String
                    let code31hour: String
                    let name31hour: String
                    let code34hour: String
                    let name34hour: String
                    let code37hour: String
                    let name37hour: String
                    let code40hour: String
                    let name40hour: String
                    let code43hour: String
                    let name43hour: String
                    let code46hour: String
                    let name46hour: String
                    let code49hour: String
                    let name49hour: String
                    let code52hour: String
                    let name52hour: String
                    let code55hour: String
                    let name55hour: String
                    let code58hour: String
                    let name58hour: String
                    let code61hour: String
                    let name61hour: String
                    let code64hour: String
                    let name64hour: String
                    let code67hour: String
                    let name67hour: String
                }
                
                @objcMembers class Temperature: NSObject,Codable {
                    let temp4hour: String
                    let temp7hour: String
                    let temp10hour: String
                    let temp13hour: String
                    let temp16hour: String
                    let temp19hour: String
                    let temp22hour: String
                    let temp25hour: String
                    let temp28hour: String
                    let temp31hour: String
                    let temp34hour: String
                    let temp37hour: String
                    let temp40hour: String
                    let temp43hour: String
                    let temp46hour: String
                    let temp49hour: String
                    let temp52hour: String
                    let temp55hour: String
                    let temp58hour: String
                    let temp61hour: String
                    let temp64hour: String
                    let temp67hour: String
                }
                
                let sky: Sky
                let temperature: Temperature
                
                func arrayRepresentation() -> [ForecastData] {
                    var data = [ForecastData]()
                    let now = Date()
                    
                    for hour in stride(from: 4, to: 67, by: 3) {
                        var key = "code\(hour)hour"
                        guard let skyCode = sky.value(forKey: key) as? String else {
                            continue
                        }
                        
                        key = "name\(hour)hour"
                        guard let skyName = sky.value(forKey: key) as? String else {
                            continue
                        }
                        
                        key = "temp\(hour)hour"
                        let tempStr = temperature.value(forKey: key) as? String ?? "0.0"
                        guard let temp = Double(tempStr) else {
                            continue
                        }
                        
                        let date = now.addingTimeInterval(TimeInterval(hour) * 60 * 60)
                        
                        let forecast = ForecastData(date: date, skyCode: skyCode, skyName: skyName, temperature: temp)
                        
                        data.append(forecast)
                    }
                    
                    return data
                }
            }
            let fcst3hour: Fcst3Hour
        }
        
        let forecast3days: [Forecast3Days]
        
    }
    
    struct Result: Codable{
        let code: Int
        let message: String
    }
    
    let weather: Weather
    let result: Result
}

struct ForecastData{
    let date: Date
    let skyCode: String
    let skyName: String
    let temperature: Double
}

class WeatherDataSource{
    static let shared = WeatherDataSource()
    
    private init() {}
    
    var summary: WeatherSummary?
    var forecastList = [ForecastData]()
    
    let group = DispatchGroup()
    let workQueue = DispatchQueue(label:"apiQueue", attributes: .concurrent)
    
    func fetch(location: CLLocation, completion: @escaping () -> ()){
        group.enter()
        workQueue.async {
            self.fetchSummary(lat: location.coordinate.latitude, lon: location.coordinate.longitude, completion: {
                self.group.leave()
            })
        }
        
        group.enter()
        workQueue.async{
            self.fetchForecast(lat:  location.coordinate.latitude, lon: location.coordinate.longitude, completion: {
                self.group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    func fetchSummary(lat: Double, lon: Double, completion: @escaping () -> ()){
        
        //api주소
        let apiUrl = "https://apis.openapi.sk.com/weather/current/minutely?ver=2&lat=\(lat)&lon=\(lon)&appKey=\(appKey)"

        //문자열을 기반으로 URL 인스턴스를 생성한다. 보통 api 구현할때는 알라모파이어를 사용하는데 기본 URL세션도 좋아졌기 때문에 이걸로 생성한다.
        let url = URL(string: apiUrl)!  //!는 강제추출연산자

        //공유객체를 상수객체에 저장한다.
        let session = URLSession.shared

        //dataTask 메소드를 호출한다. with는 어떤 url을 호출할지인지 설정하는 것 같음. 첫번쨰 파라미터가 url 두번째 파라미터가 closure
        //session.dataTask(with:url){ (data, response, error) in
        //데이터테스크 메소드를 호출함으로써 api 호출 결과값을 가져온다.
        let task = session.dataTask(with: url) { (data, response, error) in
            
            defer{
                DispatchQueue.main.async {
                    completion()
                }
            }
            
            //에러 파라미터를 보고 에러가 발생한 경우 에러를 호출하고 종료
            if let error = error {
                print(error)
                return
            }
            
            //응답코드를 확인해 다른 형식이 저장되어 있다면 로그를 출력하고 종료
            guard let httpResponse = response as? HTTPURLResponse else {
                print("invalid response")
                return
            }
            
            //응답코드가 200~299인 경우를 제외(즉 성공이 아닌 경우) 응답코드를 출력하고 종료한다.
            guard (200...299).contains(httpResponse.statusCode) else {
                print(httpResponse.statusCode)
                return
            }
            
            //데이터가 아닌 경우 fatalError를 출력하고 종료
            guard let data = data else {
                fatalError("invalid Data")
            }
            
            do{
                //JSONDecoder를 이용해 전달된 데이터를 파싱한다.
                let decoder = JSONDecoder()
                // decode를 실행한다. 첫번쨰 파라미터는 파싱할 형식, from은 서버에서 전달된 데이터
                self.summary = try decoder.decode(WeatherSummary.self, from: data)
                
                
                
            }catch{
                print("error occured....")
            }
        }

        //태스크를 실행한다.
        task.resume()
    }
    
    func fetchForecast(lat: Double, lon: Double, completion: @escaping () -> ()){
        forecastList.removeAll()
        
        
        
        let apiUrl = "https://apis.openapi.sk.com/weather/forecast/3days?ver=2&lat=\(lat)&lon=\(lon)&appKey=\(appKey)"

        //문자열을 기반으로 URL 인스턴스를 생성한다. 보통 api 구현할때는 알라모파이어를 사용하는데 기본 URL세션도 좋아졌기 때문에 이걸로 생성한다.
        let url = URL(string: apiUrl)!  //!는 강제추출연산자

        //공유객체를 상수객체에 저장한다.
        let session = URLSession.shared

        //dataTask 메소드를 호출한다. with는 어떤 url을 호출할지인지 설정하는 것 같음. 첫번쨰 파라미터가 url 두번째 파라미터가 closure
        //session.dataTask(with:url){ (data, response, error) in
        //데이터테스크 메소드를 호출함으로써 api 호출 결과값을 가져온다.
        let task = session.dataTask(with: url) { (data, response, error) in
            
            defer{
                DispatchQueue.main.async {
                    completion()
                }
            }
            
            //에러 파라미터를 보고 에러가 발생한 경우 에러를 호출하고 종료
            if let error = error {
                print(error)
                return
            }
            
            //응답코드를 확인해 다른 형식이 저장되어 있다면 로그를 출력하고 종료
            guard let httpResponse = response as? HTTPURLResponse else {
                print("invalid response")
                return
            }
            
            //응답코드가 200~299인 경우를 제외(즉 성공이 아닌 경우) 응답코드를 출력하고 종료한다.
            guard (200...299).contains(httpResponse.statusCode) else {
                print(httpResponse.statusCode)
                return
            }
            
            //데이터가 아닌 경우 fatalError를 출력하고 종료
            guard let data = data else {
                fatalError("invalid Data")
            }
            
            do{
                //JSONDecoder를 이용해 전달된 데이터를 파싱한다.
                let decoder = JSONDecoder()
                // decode를 실행한다. 첫번쨰 파라미터는 파싱할 형식, from은 서버에서 전달된 데이터
                let forecast = try decoder.decode(Forecast.self, from: data)
                if let list = forecast.weather.forecast3days.first?.fcst3hour.arrayRepresentation() {
                    self.forecastList = list
                }
            }catch{
                print("error occured....")
            }
        }

        //태스크를 실행한다.
        task.resume()

    }
}
