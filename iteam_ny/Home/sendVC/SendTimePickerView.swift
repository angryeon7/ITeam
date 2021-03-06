//
//  SendTimePickerView.swift
//  iteam_ny
//
//  Created by 성나연 on 2022/04/23.
//

import UIKit

class SendTimePickerView:UIViewController{
    @IBOutlet weak var saveBtn: UIButton!
    var select_Time: String = ""
    var dataN : Int = 0
    var numberI : String = ""
    var delegate : SendTimeDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    func setUI() {
        self.view.layer.cornerRadius = 30
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a hh시 mm분"
        sender.minimumDate = Date()
        
        if dataN == 0{
            numberI = "첫번째"
        }
        if dataN == 1{
            numberI = "두번째"
        }
        if dataN == 2{
            numberI = "세번째"
        }
        select_Time = formatter.string(from: datePickerView.date)
//        self.delegate?.SendTimeDataDelegate(data: select_Time)
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if select_Time.isEmpty{
            saveBtn.isEnabled = false
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.delegate?.SendTimeData(data: numberI + select_Time )
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}
protocol SendTimeDataDelegate {
    func SendTimeData(data: String)
}
