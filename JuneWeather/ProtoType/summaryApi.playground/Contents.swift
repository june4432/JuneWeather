import UIKit

//API에서 받아오는 JSON 형태대로 구조체를 만든다.
/*
 {
     "weather": {
         "minutely": [
             {
                 "sky": {
                     "code": "SKY_A03",
                     "name": "구름많음"
                 },
                 "temperature": {
                     "tc": "15.20",
                     "tmax": "16.00",
                     "tmin": "9.00"
                 }
             }
         ]
     },
     "result": {
         "code": 9200,
         "message": "성공"
     }
 }
 */
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

//api주소
let apiUrl = "https://apis.openapi.sk.com/weather/current/minutely?ver=2&lat=37.59063130183221&lon=127.01762655200862&appKey=4f3f4118-08e1-4193-a892-b0d642821a2e"

//문자열을 기반으로 URL 인스턴스를 생성한다. 보통 api 구현할때는 알라모파이어를 사용하는데 기본 URL세션도 좋아졌기 때문에 이걸로 생성한다.
let url = URL(string: apiUrl)!  //!는 강제추출연산자

//공유객체를 상수객체에 저장한다.
let session = URLSession.shared

//dataTask 메소드를 호출한다. with는 어떤 url을 호출할지인지 설정하는 것 같음. 첫번쨰 파라미터가 url 두번째 파라미터가 closure
//session.dataTask(with:url){ (data, response, error) in
//데이터테스크 메소드를 호출함으로써 api 호출 결과값을 가져온다.
let task = session.dataTask(with: url) { (data, response, error) in
    
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
        return
    }
    
    do{
        //JSONDecoder를 이용해 전달된 데이터를 파싱한다.
        let decoder = JSONDecoder()
        // decode를 실행한다. 첫번쨰 파라미터는 파싱할 형식, from은 서버에서 전달된 데이터
        let summary = try decoder.decode(WeatherSummary.self, from: data)
        
        summary.result.code
        summary.result.message
        
        summary.weather.minutely.first?.sky.code
        summary.weather.minutely.first?.sky.name

        summary.weather.minutely.first?.temperature.tc
        summary.weather.minutely.first?.temperature.tmax
        summary.weather.minutely.first?.temperature.tmin
        
    }catch{
        print("error occured....")
    }
}

//태스크를 실행한다.
task.resume()
