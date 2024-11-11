//
//  ViewController.swift
//  Clock2
//
//  Created by Matt Erdahl on 11/10/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var dateDisplay: UILabel!
    @IBOutlet weak var remainingDisplay: UILabel!
    @IBOutlet weak var buttonDisplay: UIButton!
    
    //used in multiple date/time calculations
    var cal = Calendar(identifier: .gregorian)
    
    //timer variables, both timeselect and timeleft so that when one timer is running, the time doesn't reset until pressing the button
    var timer = Timer()
    var timeSelect: Int?
    var timeLeft: Int?
    var pickerDate: Date?
    
    //date formatter for current date and for time remaining
    let dateFormatter = DateFormatter()
    
    //for playing music at timer end
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //format date to correct style and display it right away
        let currentDate = Date()
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm"
        dateDisplay.text = dateFormatter.string(from: currentDate)
        
        //set background whenever the app loads in case the time changes past noon
        changeBackground(currentDate)
    }
    
    func changeBackground(_ time: Date?) {
        
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        //if current time is before noon, set background to day version; if not, set to night version
        if cal.compare(time!, to: cal.date(from: components)!, toGranularity: .minute) == .orderedSame {
            background.backgroundColor = UIColor.orange
        }
        else {
            background.backgroundColor = UIColor.blue
        }
    }
    
    //when a countdown time is selected, update the time remaining
    @IBAction func countSelect(_ sender: UIDatePicker) {
        timeSelect = Int(sender.countDownDuration)
    }
    
    func secondsToHMS(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //different actions for button, depending on what's happening
    @IBAction func startStop(_ sender: UIButton) {
        //if text says 'Stop Music' set when timer ends
        if String(describing: buttonDisplay.titleLabel) == "Stop Music" {
            audioPlayer?.pause() //can't test this in macincloud
            
            //reset
            remainingDisplay.text = "Time Remaining: "
            buttonDisplay.setTitle("Start Timer", for: .normal)
        }
        else {
            timeLeft = timeSelect
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startCountDown), userInfo: nil, repeats: true)
        }
    }
    
    //check time left ever second, display the amount remaining in the correct format
    @objc func startCountDown() {
        
        if timeLeft! > 0 {
            timeLeft! -= 1
            
            let (h, m, s) = secondsToHMS(timeLeft!)
            remainingDisplay.text = "Time Remaining: \(h):\(m):\(s)"
        }
        //stop, play music; unfortunately can't test in macincloud
        else {
            timer.invalidate()
            
            do {
                let url = URL(filePath: "/Users/user264056/Desktop/Clock2/Short Skirt Long Jacket.mp3")
                //I read wrong and this isn't 5-10 sec, sorry. It's surprisingly tough to find something that long.
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                buttonDisplay.setTitle("Stop Music", for: .normal)
                }
            catch let error {
                    print(error.localizedDescription)
                }
        }
    }
}

