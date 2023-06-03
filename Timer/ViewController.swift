//
//  ViewController.swift
//  Timer
//
//  Created by binee on 2023/05/11.
//

import UIKit
import AudioToolbox

enum TimerSatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var progreesView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var TimerLabel: UILabel!
    
    var duration =  60 //타이머에 설정된 시간을 초로 저장하는 프로퍼티
    var timerStatus: TimerSatus = .end // 타이머의 상태를 가지고있는 프로퍼티
    var timer: DispatchSourceTimer?
    var currentSeconds = 0 // 현재 카운트다운되고 있는 시간을 초로 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    func setTimerInforViewVisble(isHidden: Bool) {
        self.TimerLabel.isHidden = isHidden
        self.progreesView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minute = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.TimerLabel.text = String(format: "%02d:%02d:%02d", hour,minute,seconds)
                self.progreesView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()//타이머 종료
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        } // nil을 바로 넣으면 에러뜸 그래서 이것 작성함.
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        self.setTimerInforViewVisble(isHidden: true)
        self.datePicker.isHidden = false
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil // nil을 활용하여 메모리 삭제를 해야함.
    }
    
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default :
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            self.setTimerInforViewVisble(isHidden: false)
            self.datePicker.isHidden = true
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            let countDown = Int(datePicker.countDownDuration)
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
            
        default:
            break
        }
    }
}

