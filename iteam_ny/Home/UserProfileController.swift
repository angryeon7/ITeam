//
//  UserProfile.swift
//  iteam_ny
//
//  Created by 성나연 on 2021/11/29.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class UserProfileController: UIViewController{
    var userprofileDetail: UserProfileDetail?
    var userprofile: UserProfile?
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var partLabel: UILabel!
    @IBOutlet weak var characterLabel1: UILabel!
    @IBOutlet weak var characterLabel2: UILabel!
    @IBOutlet weak var characterLabel3: UILabel!
    @IBOutlet weak var sameSchol: UITextField!
    
    @IBOutlet weak var Interest: UILabel!
    @IBOutlet weak var toolNlanguage: UILabel!
    
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var projectDetail: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var callTime: UILabel!
    @IBOutlet weak var contactLink: UILabel!
    @IBOutlet weak var portfolioLabel: UILabel!
    
    @IBOutlet weak var backStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.clipsToBounds = true
        
        let fancyImage = UIImage(systemName:"arrow.left")

        var fancyAppearance = UINavigationBarAppearance()
        fancyAppearance.backgroundColor = UIColor.white
        fancyAppearance.setBackIndicatorImage(fancyImage, transitionMaskImage: fancyImage)

        navigationController?.navigationBar.scrollEdgeAppearance = fancyAppearance
        
        
        backStack.layoutMargins = UIEdgeInsets(top: 15, left: 20, bottom: 30, right: 0)
        backStack.isLayoutMarginsRelativeArrangement = true
        backStack.layer.cornerRadius = 20
        
        backStack.layer.shadowColor = UIColor.black.cgColor // 색깔
        
        backStack.layer.borderWidth = 0
        backStack.layer.shadowColor = UIColor.black.cgColor
        backStack.layer.shadowOffset = CGSize(width: 0, height: 0)
        backStack.layer.shadowOpacity = 0.15
        backStack.layer.shadowRadius = 10
        
        characterLabel1.layer.cornerRadius = characterLabel1.frame.height/2
        characterLabel2.layer.cornerRadius = characterLabel2.frame.height/2
        characterLabel3.layer.cornerRadius = characterLabel3.frame.height/2
        characterLabel1.layer.borderWidth = 0.5
        characterLabel1.layer.borderColor = UIColor.lightGray.cgColor
        characterLabel2.layer.borderWidth = 0.5
        characterLabel2.layer.borderColor = UIColor.lightGray.cgColor
        characterLabel3.layer.borderWidth = 0.5
        characterLabel3.layer.borderColor = UIColor.lightGray.cgColor
        characterLabel1.clipsToBounds = true
        characterLabel2.clipsToBounds = true
        characterLabel3.clipsToBounds = true
//        backStack.layer.masksToBounds = false  // 내부에 속한 요소들이 UIView 밖을 벗어날 때, 잘라낼 것인지. 그림자는 밖에 그려지는 것이므로 false 로 설정
//        backStack.layer.shadowOffset = CGSize(width: 0, height: 4) // 위치조정
//        backStack.layer.shadowRadius = 5 // 반경
//        backStack.layer.shadowOpacity = 0.3 // alpha값
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            guard let detail = userprofileDetail else { return }
            guard let basicinfo = userprofile else { return }
        
        let char = detail.character
        let charindex = char.components(separatedBy: ", ")
        
        
        userName.text = basicinfo.nickname
        sameSchol.text = basicinfo.schoolName
        partLabel.text = basicinfo.partDetail
        purposeLabel.text = detail.purpose
        characterLabel1.text = charindex[0]
        characterLabel2.text = charindex[1]
        characterLabel3.text = charindex[2]
        if let portfolio = basicinfo.portfolio {
            toolNlanguage.text = portfolio.toolNLanguage
            Interest.text = portfolio.interest
            if let ex0 = portfolio.ex0 {
                date.text = ex0.date
                projectDetail.text = ex0.exDetail
            }
            callTime.text = portfolio.calltime
            portfolioLabel.text = portfolio.portfolioLink
            contactLink.text = portfolio.contactLink
        }
        
        
        let nickname: String = basicinfo.nickname
        print(nickname)
        
        var userUID2 :String = ""
        let userdb = Database.database().reference().child("user").queryOrdered(byChild: "userProfile/nickname").queryEqual(toValue: nickname)
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                
                userUID2 = snap.key
                
            }
            let uid: String = userUID2
//                print(fetchNickNameToUID(nickname:"우다다"))
//                print(uid)
            let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")
            // Fetch the download URL
            starsRef.downloadURL { [self] url, error in
                if let error = error {
                } else {
                    userImage.kf.setImage(with: url)
                    userImage.layer.cornerRadius = userImage.frame.height/2
                }
            }
        }
        
        if sameSchol.text == "네이버대학교" {
            sameSchol.layer.borderWidth = 0.5
            sameSchol.layer.borderColor = UIColor(named: "purple_184")?.cgColor
            sameSchol.textColor = UIColor(named: "purple_184")
            
            sameSchol.layer.cornerRadius = sameSchol.frame.height/2
            sameSchol.text = "같은 학교"
            sameSchol.isHidden = false
            
        }
        else {
            sameSchol.isHidden = true
        }
        
            
        }
    
    @IBAction func sendData(_ sender: UIButton) {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "SetATimeViewController") as? SetATimeViewController else {
                return
            }
       let userName = userName.text
        vc.senderid = userName!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
}

class ActualGradientButton2: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor(displayP3Red: 184/255, green: 98/255, blue: 255/255, alpha: 1).cgColor, UIColor(displayP3Red: 144/255, green: 255/255, blue: 201/255, alpha: 1).cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 8
        layer.insertSublayer(l, at: 0)
        return l
    }()
}

