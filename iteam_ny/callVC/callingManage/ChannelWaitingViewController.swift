//
//  ChannelWaitingViewController.swift
//  ITeam_basic
//
//  Created by 김하늘 on 2021/11/30.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class ChannelWaitingViewController: UIViewController {

    var nickname: String = ""
    var position: String = ""
    var name: String = ""
    var profile: String = ""
    var callTime: String = ""
    var questionArr: [String] = []
    var fromPerson: String = ""
    var toPerson: String = ""
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var callTimeLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        nicknameLabel.text = nickname
        positionLabel.text = position
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.image = UIImage(named: "\(profile).png")
        callTimeLabel.text = "\(callTime)에"
        name = "speaker"
        // Do any additional setup after loading the view.
    }
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func showQuestionAction(_ sender: UIButton) {
        let waitingRoomQuestionVC = storyboard?.instantiateViewController(withIdentifier: "waitingRoomQuestionVC") as! CallWaitingRoomQuestionViewController
        
        waitingRoomQuestionVC.question = questionArr
        waitingRoomQuestionVC.fromPerson = fromPerson
        waitingRoomQuestionVC.toPerson = toPerson
        // MDC 바텀 시트로 설정
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: waitingRoomQuestionVC)
        if questionArr.count > 3 {
            bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = CGFloat(49*questionArr.count + 84)
        }
        else {
            bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = CGFloat(49*questionArr.count + 84)
        }
        
        present(bottomSheet, animated: true, completion: nil)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannelViewController" {
            let vc = segue.destination as! ChannelViewController
            vc.name = name
            
            if let destination = segue.destination as? ChannelViewController {
                destination.nickname = nickname
                destination.position = position
            }
        }
        if segue.identifier == "showQuestionVC" {
            let vc = segue.destination as! QuestionnaireViewController
            vc.nickname = nickname
        }
    }


}
extension ChannelWaitingViewController: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        print("바트 시트 닫힘")
    }
    
    func bottomSheetControllerDidChangeYOffset(_ controller: MDCBottomSheetController, yOffset: CGFloat) {
        // 바텀 시트 위치
        print(yOffset)
    }
}