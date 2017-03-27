//
//  WeatherController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/15/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import Alamofire

class WeatherController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainStatusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var isTodayMode = false
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var daysArray = ["M", "T", "W", "T", "F", "S", "S"]
    var dayTemp:[String] = []
    var nightTemp:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        downloadWeather()
    }

    func setupUI() {
        navigationItem.title = "Weather"
        view.layer.contents = UIImage(named: "natureplaceholder")?.cgImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        if isTodayMode {
            tableView.alpha = 0
            topConstraint.constant = self.view.bounds.height/5
            widthConstraint.constant = 100
        }
       // tableView.tableFooterView = UIView()
    }
    
    func downloadWeather() {
        Alamofire.request(URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?q=Lviv&mode=json&cnt=7&appid=a575ffe0b2c85312ed4186cbb0392aa8")!, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let res = response.value! as? [String: Any]
                var temperatureArray = res?["list"] as? [[String: Any]]
                for item in temperatureArray! {
                    var tempDict = item["temp"] as? [String: Double]
                    self.dayTemp.append(String.init(format: "Day: %1.1f", tempDict!["day"]! -  273.15))
                    self.nightTemp.append(String.init(format: "Night: %1.1f",tempDict!["night"]! -  273.15))
                }
                DispatchQueue.main.async {
                    print(Date().dayNumberOfWeek()!)
                   self.temperatureLabel.text = self.dayTemp[Date().dayNumberOfWeek()! - 2] + " °C"
                   self.tableView.reloadData()
                }
            }
        }
    }
}

extension WeatherController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayTemp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        cell.dayLabel.text = daysArray[indexPath.row]
        cell.dayTemperatureLabel.text = dayTemp[indexPath.row]
        cell.nightTmperatureLabel.text = nightTemp[indexPath.row]
        cell.backgroundColor = cell.contentView.backgroundColor
        return cell
    }
}

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weaatherImageView: UIImageView!
    @IBOutlet weak var dayTemperatureLabel: UILabel!
    @IBOutlet weak var nightTmperatureLabel: UILabel!
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}


