//
//  TeamViewController.swift
//  iteam_ny
//
//  Created by 김하늘 on 2022/03/30.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TeamViewController: UIViewController {

    @IBOutlet weak var favorTeamViewHeight: NSLayoutConstraint!
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var myteamView: UIView!
    @IBOutlet weak var myteamBtn: UIButton!
    
    var hasFavorTeam = false {
        willSet(newValue) {
            if newValue {
                favorTeamViewHeight.constant = 280
            }
            else {
                favorTeamViewHeight.constant = 166
            }
            
        }
    }
    // 팀 프로필이 존재하는지
    var haveTeamProfile: Bool = false {
        willSet(newValue) {
            if newValue {
                if haveMember {
                    explainLabel.text = "팀 프로필 업데이트를 통해 매칭률을 높여보세요"
                    print("팀프로필, 팀원 있음")
                }
            }
        }
    }
    
    // 현재 모은 팀원이 존재하는지
    var haveMember: Bool = true {
        willSet(newValue) {
            if newValue {
                if haveTeamProfile == false {
                    explainLabel.text = "팀 프로필 생성을 통해 팀원을 모집해 보세요"
                    print("팀프로필 없고 팀원 있음")
                }
                else {
                    explainLabel.text = "팀 프로필 업데이트를 통해 매칭률을 높여보세요"
                    print("팀프로필, 팀원 있음")
                }
            }
            else {
                
                print("팀원 없음")
            }
        }
    }
    var userTeamUIDList: [String] = []
    let thisStoryboard: UIStoryboard = UIStoryboard(name: "TeamPages", bundle: nil)
    let teamCallStoryboard: UIStoryboard = UIStoryboard(name: "TeamCallRequest", bundle: nil)
    
    let db = Database.database().reference()
    var memberList: [String] = []
    var teamName: String = "" {
        willSet {
            if newValue != "" {
                checkMyTeamProfile()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUI()
        // 바뀐 데이터 불러오기
        fetchChangedData()
        
        let popupVC = teamCallStoryboard.instantiateViewController(withIdentifier: "endPopUpVC") as! TeamCallRequestPopupViewController
        popupVC.delegate = self
    }
    
    func setUI() {
        myteamBtn.backgroundColor = .white
        myteamBtn.layer.cornerRadius = 20
        myteamBtn.layer.borderColor = UIColor.black.cgColor
        myteamBtn.layer.borderWidth = 0
        myteamBtn.layer.shadowColor = UIColor.black.cgColor
        myteamBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        myteamBtn.layer.shadowOpacity = 0.2
        myteamBtn.layer.shadowRadius = 10
        self.navigationController?.isNavigationBarHidden = true
        
        
        fetchMyTeamname()
        //exmplainLabel.text = fdsa
      //  checkMyTeamProfile()
        checkMyTeamMember()
        fetchFavorTeam()
        
    }
    func fetchMyTeamname() {
        db.child("user").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { [self] (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? String
                
                if snap.key == "currentTeam" {
                    if let value = value {
                        teamName = value
                    }
                }
            }
        })
    }
    // 팀 프로필을 생성했는지 검사
    func checkMyTeamProfile() {
        let teamdb = db.child("Team")
        
        teamdb.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let values = snapshot.value
            let dic = values as! [String: [String:Any]]
            if !memberList.contains(Auth.auth().currentUser!.uid) {
                memberList.insert(Auth.auth().currentUser!.uid, at: 0)
            }
     
            var count = 0
            for index in dic{
                let memberlistString = index.value["memberList"] as! String
                var memberListArr = memberlistString.components(separatedBy: ", ")
                if index.key == teamName {
                    userTeamUIDList = memberlistString.replacingOccurrences(of: Auth.auth().currentUser!.uid, with: "").components(separatedBy: ", ").filter({ $0 != "" })
                    haveTeamProfile = true
                    count += 1
                }
            }
            if count == 0 {
                haveTeamProfile = false
            }
        })
    }
    // 팀원이 있는지 검사
    func checkMyTeamMember() {
        let teamdb = db.child("user").child(Auth.auth().currentUser!.uid)
        teamdb.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            
            var userTeamExist: Bool = false
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? String
                

                if snap.key == "userTeam" {
                    userTeamExist = true
                    // 꾸린 팀원이 없을 때
                    if value == nil || value == "" {
                        haveMember = false
                    }
                    // 꾸린 팀원이 있을 때
                    else {
                        haveMember = true
                        memberList = (value?.components(separatedBy: ", "))!
                        var count = 0
                        
                        // 수정해야함 - 안돌음
                        // 팀프로필에 있는 팀원과 현재 꾸리고 있는 내 팀이 같은지 비교
                        // 같으면 이미 프로필 만든 것, 다르면 프로필 안만든 것
                        memberList.diffIndicesNotConsideringOrder(from: userTeamUIDList).forEach {_ in
                            count += 1
                             // print("diff value: \(memberList![$0])")
                        }
                        if count == 0 {
                            haveTeamProfile = false
                        }
                    }
                }
            }
            if userTeamExist == false {
                haveMember = false
            }
        
        })
    }
    // 바뀐 데이터 불러오기
    func fetchChangedData() {
        db.child("Team").observe(.childChanged, with:{ [self] (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                fetchMyTeamname()
                checkMyTeamProfile()
                checkMyTeamMember()
            }
        })
        db.child("user").child(Auth.auth().currentUser!.uid).observe(.childChanged, with:{ [self] (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                fetchMyTeamname()
                checkMyTeamProfile()
                checkMyTeamMember()
            }
        })
        db.child("user").child(Auth.auth().currentUser!.uid).child("likeTeam").observe(.childChanged, with:{ [self] (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                fetchFavorTeam()
            }
        })
    }
    
    // [Button Action] 나의 팀 생성 버튼
    @IBAction func createMyTeam(_ sender: UIButton) {
        
        // 1. 팀원, 프로필 없을 때 팀원 추가 alert
        // 2. 팀원이 있고 프로필은 없을 때 팀 프로필 생성
        // 3. 팀원, 프로필이 모두 있을 때 업데이트 페이지로
        
        
        // 팀원이 있을 때
        if haveMember {
            // 프로필이 모두 있을 때 업데이트 페이지로
            if haveTeamProfile {
                let teamProfileVC = thisStoryboard.instantiateViewController(withIdentifier: "teamProfileVC") as! CreateTeamProfileViewController
                teamProfileVC.modalPresentationStyle = .fullScreen
                
                teamProfileVC.memberList = memberList
                teamProfileVC.haveTeamProfile = true
                teamProfileVC.teamname = teamName
                present(teamProfileVC, animated: true, completion: nil)
            }
            // 팀원이 있고 프로필은 없을 때 팀 프로필 생성
            else {
                let teamProfileVC = thisStoryboard.instantiateViewController(withIdentifier: "teamProfileVC") as! CreateTeamProfileViewController
                
                teamProfileVC.memberList = memberList
                
                teamProfileVC.modalPresentationStyle = .fullScreen
                present(teamProfileVC, animated: true, completion: nil)
            }
        }
        // 팀원, 프로필 없을 때 팀원 추가 alert
        else {
            let addTeamAlertVC = thisStoryboard.instantiateViewController(withIdentifier: "addTeamAlertVC") as! TeamAddAlertViewController
            addTeamAlertVC.modalPresentationStyle = .overFullScreen
            present(addTeamAlertVC, animated: false, completion: nil)
        }
        
        
    }
    
    // 관심 팀있는지 검사, 뷰 크기 조절
    func fetchFavorTeam() {
        
        let favorTeamList = db.child("user").child(Auth.auth().currentUser!.uid).child("likeTeam").child("teamName")
        
        favorTeamList.observeSingleEvent(of: .value) { [self] favorSnapshot in
            
            let value = favorSnapshot.value as? String ?? "none"
            if value == "none" || value == "" {
                hasFavorTeam = false
            }
            else {
                hasFavorTeam = true
            }
            
        }
    }
    
}
extension TeamViewController: SendCallPageDelegate {
    func sendGotoCallPageSignal() {
        self.tabBarController?.selectedIndex = 2
    }
    
    
}

