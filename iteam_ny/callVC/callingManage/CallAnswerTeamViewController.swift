//
//  CallAnswerTeamViewController.swift
//  iteam_ny
//
//  Created by 김하늘 on 2022/05/06.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class CallAnswerTeamViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var conditionChangeBtn: UIButton!
    @IBOutlet weak var answerListTableView: UITableView!
    
    var personList: [Person] = []
    var whenIReceivedOtherPerson: [Person] = []
    var whenISendOtherTeam: [Person] = []
    var toGoSegue: String = "대기"
    let db = Database.database().reference()
    
    // [삭제 예정] 시연을 위한 변수
    var counter:Int = 0
    var name: String = "speaker"
    var myNickname = ""
    var myTeamname = "" 
    let thisStoryboard: UIStoryboard = UIStoryboard(name: "JoinPages", bundle: nil)
    var callTimeArr: [[String]] = []
    var questionArr: [[String]] = []
    var callTimeArrSend: [[String]] = []
    var questionArrSend: [[String]] = []
    var didISent: [Bool] = []
    var fetchedInputUIDToNickName: String = ""
    var teamIndex: [String] = []
    var teamIndexForSend: [String] = []
    var callTeamIndex: [String] = []
    var nowRequestedUid: String = "" {
        willSet(newValue) {
            print(newValue)
            callingOtherUid = newValue
        }
    }
    var callingOtherUid: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerListTableView.delegate = self
        answerListTableView.dataSource = self
        
        setUI()
        // 이 문제도x
       // fetchData()
        
        //fetchChangedData()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        //setUI()
        fetchData()
    }
    
    func setUI() {
        counter = 0
        name = "speaker"
        
        let requestList = UIAction(title: "요청됨", handler: { _ in print("요청내역") })
        let denied = UIAction(title: "요청수락", handler: { _ in print("거절함") })
        let canceled = UIAction(title: "통화", handler: { _ in print("취소됨") })
        let cancel = UIAction(title: "취소", attributes: .destructive, handler: { _ in print("취소") })
        
        conditionChangeBtn.menu = UIMenu(title: "상태를 선택해주세요", image: UIImage(systemName: "heart.fill"), identifier: nil, options: .displayInline, children: [requestList, denied, canceled, cancel])

        
    }
    func removeArr() {
        
        personList.removeAll()
        whenIReceivedOtherPerson.removeAll()
        whenISendOtherTeam.removeAll()
        
        callTimeArr.removeAll()
        questionArr.removeAll()
        callTimeArrSend.removeAll()
        questionArrSend.removeAll()
        didISent.removeAll()
        
        teamIndex.removeAll()
        teamIndexForSend.removeAll()
        callTeamIndex.removeAll()
        
        //answerListTableView.reloadData()
        
        toGoSegue = "대기"
        counter = 0
        name = "speaker"
        myNickname = ""
        myTeamname = ""
       
        fetchedInputUIDToNickName = ""
       
        nowRequestedUid = ""
        callingOtherUid = ""
    }
    
    func fetchData() {
        
        removeArr()
        
        let userdb = db.child("user").child(Auth.auth().currentUser!.uid)
        // 내 닉네임 받아오기
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                let teamnameValue = snap.value as? String
                
                if snap.key == "userProfile" {
                    for (key, content) in value! {
                        if key as! String == "nickname" {
                            myNickname = content as! String
                        }
                    }
                }
                if snap.key == "currentTeam" {
                    let value: String = teamnameValue!
                    myTeamname = value
                }
            }
            // 팀 알림 가져오기
            let favorTeamList = db.child("Call")
            //queryEqual(toValue: myNickname)
            favorTeamList.observeSingleEvent(of: .value) { [self] snapshot in
                var myCallTime: [[String:String]] = []
                var receiverType: [String] = []
                
                // 나와 관련된 call 가져오기
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let value = snap.value as? NSDictionary
                    
                    for (key, content) in value! {
                        
                        // 내 팀이 받는 경우를 가져오기(팀은 개인에게 보낼 수 x -> receiverType이 team이면 무조건 receiverNickname은 팀이름 )
                        if key as! String == "receiverNickname" && content as! String == myTeamname + " 팀" {
                            var newValue = value as! [String : String]
                            newValue["teamName"] = snap.key
                            myCallTime.append(newValue)
                            didISent.append(false)
                            break
                        }
                        // 내가 요청한 사람일 경우를 가져오기
                        if key as! String == "callerUid" && content as! String == Auth.auth().currentUser?.uid {
                            var newValue = value as! [String : String]
                            newValue["teamName"] = snap.key
                            myCallTime.append(newValue)
                            didISent.append(true)
                            break
                        }
                    }
                }
                // 나와 관련된 call에서 데이터 불러오기
                for i in 0..<myCallTime.count {
                    
                    for j in 0..<myCallTime[i].keys.count {
                        // 내가 받은 팀인 경우
                        if myCallTime[i]["receiverNickname"] == myTeamname + " 팀" {
                            if myCallTime[i]["receiverType"] != nil && myCallTime[i]["receiverType"] == "team" {
                                
                                // 요청옴은 따로 넘겨줘야함
                                if myCallTime[i]["stmt"] == "통화"
                                    || myCallTime[i]["stmt"] == "대기 중"
                                    || myCallTime[i]["stmt"] == "요청취소됨"
                                    || myCallTime[i]["stmt"] == "요청거절됨" {
                                    
                                    fetchUser(userUID: myCallTime[i]["callerUid"]!, stmt: myCallTime[i]["stmt"]!)
                                    fetchIReceivedOtherUser(userUID: myCallTime[i]["callerUid"]!, stmt: myCallTime[i]["stmt"]!)
                                    callTeamIndex.append(myCallTime[i]["teamName"]!)
                                }
                                else {
                                    fetchUser(userUID: myCallTime[i]["callerUid"]!, stmt: "요청옴")
                                    fetchIReceivedOtherUser(userUID: myCallTime[i]["callerUid"]!, stmt: "요청옴")
                                }
                                callTimeArr.append((myCallTime[i]["callTime"]?.components(separatedBy: ", "))!)
                                questionArr.append((myCallTime[i]["Question"]?.components(separatedBy: ", "))!)
                                if myCallTime[i]["teamName"] != nil {
                                    teamIndex.append(myCallTime[i]["teamName"]!)
                                }
                                fetchNickname(userUID: myCallTime[i]["callerUid"]!)
                                break
                            }
                        }
                        // 내가 팀에 요청한 경우
                        if myCallTime[i]["callerUid"] == Auth.auth().currentUser?.uid {
                            
                            if myCallTime[i]["receiverType"] != nil && myCallTime[i]["receiverType"] == "team" {
                             
                                if myCallTime[i]["stmt"] == "통화"
                                    || myCallTime[i]["stmt"] == "대기 중"
                                    || myCallTime[i]["stmt"] == "요청취소됨"
                                    || myCallTime[i]["stmt"] == "요청거절됨" {
                                    
                                    fetchTeam(teamname: myCallTime[i]["receiverNickname"]!, stmt: myCallTime[i]["stmt"]!)
                                }
                                else {
                                    fetchTeam(teamname: myCallTime[i]["receiverNickname"]!, stmt: "요청됨")
                                }
                                
                                callTimeArrSend.append((myCallTime[i]["callTime"]?.components(separatedBy: ", "))!)
                                questionArrSend.append((myCallTime[i]["Question"]?.components(separatedBy: ", "))!)
                                
                                if myCallTime[i]["teamName"] != nil {
                                    teamIndexForSend.append(myCallTime[i]["teamName"]!)
                                }
                                if myCallTime[i]["stmt"] == "통화" {
                                    callTeamIndex.append(myCallTime[i]["teamName"]!)
                                }
                                
                                break
                            }
                        }
                        
                    }
                    
                    
                }
            }
        }
        answerListTableView.reloadData()
        
        
        
    }
    
    // 2022.05.13 오후 03시 00분 -> 5월 13일 오후 03시 00분
    func dateFormatStringToString(dateString: String) -> String {
        
        let dateStr = dateString // Date 형태의 String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd a hh시 mm분"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        // String -> Date
        let convertDate = dateFormatter.date(from: dateStr)
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "M월 dd일 a h시 m분"
        myDateFormatter.locale = Locale(identifier:"ko_KR")
        let convertStr = myDateFormatter.string(from: convertDate!)
        
        return convertStr
        
    }
    // uid와 stmt로 user 정보 받기
    func fetchUser(userUID: String, stmt: String) {
        let userdb = db.child("user").child(userUID)
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            var nickname: String = ""
            var part: String = ""
            var partDetail: String = ""
            var purpose: String = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                
                
                if snap.key == "userProfile" {
                    for (key, content) in value! {
                        if key as! String == "nickname" {
                            nickname = content as! String
                        }
                        if key as! String == "part" {
                            part = content as! String
                        }
                        if key as! String == "partDetail" {
                            partDetail = content as! String
                        }
                    }
                    
                }
                if snap.key == "userProfileDetail" {
                    for (key, content) in value! {
                        if key as! String == "purpose" {
                            purpose = content as! String
                        }
                    }
                }
                
            }
            if part == "개발자" {
                part = partDetail + part
                
            }
            part += " • " + purpose.replacingOccurrences(of: ", ", with: "/")
            
            var person = Person(nickname: nickname, position: part, callStm: stmt, profileImg: userUID)
            
            personList.append(person)
            answerListTableView.reloadData()
        }
    }
    
    // 팀 이름으로 팀 정보 받아오기
    func fetchTeam(teamname: String, stmt: String) {
        let justTeamname = teamname.replacingOccurrences(of: " 팀", with: "")
        let userdb = db.child("Team").child(justTeamname)
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            var teamname: String = justTeamname
            var part: String = ""
            var purpose: String = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? String
                
                if snap.key as! String == "part" {
                    part = value as! String
                }
                if snap.key as! String == "purpose" {
                    purpose = value as! String
                }
            }
            purpose = purpose.replacingOccurrences(of: ", ", with: "/")
            purpose += " • " + part + " 구인 중"
            
            var person = Person(nickname: justTeamname, position: purpose, callStm: stmt, profileImg: "")
            
            personList.append(person)
            whenISendOtherTeam.append(person)
            answerListTableView.reloadData()
        }
    }
    
    // 내가 받은 경우 상대 저장
    func fetchIReceivedOtherUser(userUID: String, stmt: String) {
        let userdb = db.child("user").child(userUID)
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            var nickname: String = ""
            var part: String = ""
            var partDetail: String = ""
            var purpose: String = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                

                if snap.key == "userProfile" {
                    for (key, content) in value! {
                        if key as! String == "nickname" {
                            nickname = content as! String
                        }
                        if key as! String == "part" {
                            part = content as! String
                        }
                        if key as! String == "partDetail" {
                            partDetail = content as! String
                        }
                    }
                    
                }
                if snap.key == "userProfileDetail" {
                    for (key, content) in value! {
                        if key as! String == "purpose" {
                            purpose = content as! String
                        }
                    }
                }
                
            }
            if part == "개발자" {
                part = partDetail + part
                
            }
            part += " • " + purpose.replacingOccurrences(of: ", ", with: "/")
            var person = Person(nickname: nickname, position: part, callStm: stmt, profileImg: userUID)
            
            whenIReceivedOtherPerson.append(person)
        }
    }

 
    // uid로 user 닉네임 반환
    func fetchNickname(userUID: String)  {
        let userdb = db.child("user").child(userUID)
        
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                
                if snap.key == "userProfile" {
                    for (key, content) in value! {
                        if key as! String == "nickname" {
                            fetchedInputUIDToNickName = content as! String
                            
                        }
                    }
                }
                
            }
        }
    }
    
    
    // 바뀐 데이터 불러오기
    func fetchChangedData() {
        
        
        // 아님
        db.child("Call").observe(.childChanged, with:{ (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                self.removeArr()
                self.fetchData()
            }
        })
        // 아님
        db.child("user").child(Auth.auth().currentUser!.uid).observe(.childChanged, with:{ (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                self.removeArr()
                self.fetchData()
            }
            
        })
        db.child("Team").observe(.childChanged, with:{ (snapshot) -> Void in
            print("DB 수정됨")
            DispatchQueue.main.async {
                self.removeArr()
                self.fetchData()
            }

        })
    }
    
    // 삭제할 코드 - 유닛 테스트
    @IBAction func testSignout(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("로그아웃됨. 앱이 종료됩니다")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        sleep(2)
        exit(0)
    }
    
    
    
    // [삭제 예정] 시연을 위한 nextbutton
    @IBAction func nextBtn(_ sender: UIButton) {
        if counter == 0 {
            personList[0].callStm = "통화대기"
            answerListTableView.reloadData()
            toGoSegue = "통화대기"
            counter += 1
        }
        if counter == 1{
            personList[0].callStm = "통화시작"
            answerListTableView.reloadData()
            toGoSegue = "통화시작"
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "waitingVC" {
            if let destination = segue.destination as? ChannelWaitingViewController {
                // let cell = sender as! AnswerTableViewCell
                destination.nickname = personList[(sender as? Int)!].nickname
                // var position = personList[(sender as? Int)!].position.split(separator: "•")
                var position = personList[(sender as? Int)!].position
                destination.position = String(position)
                destination.profile = personList[(sender as? Int)!].profileImg
            }
        }
    }
    // nickname으로 uid찾기
    func fetchNickNameToUID(nickname: String)  {
        let userdb = db.child("user").queryOrdered(byChild: "userProfile/nickname").queryEqual(toValue: nickname)
        userdb.observeSingleEvent(of: .value) { [self] snapshot in
            var userUID: String = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as? NSDictionary
                
                userUID = snap.key
            }
            nowRequestedUid = userUID
        }
    }
    
}

extension CallAnswerTeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AnswerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AnswerTeamCell", for: indexPath) as! AnswerTableViewCell
        cell.nicknameLabel.text = personList[indexPath.row].nickname
        
        
        
        // 같은 학교 처리
        if cell.nicknameLabel.text == "시연" {
            cell.sameSchoolLabel.layer.borderWidth = 0.5
            cell.sameSchoolLabel.layer.borderColor = UIColor(named: "purple_184")?.cgColor
            cell.sameSchoolLabel.textColor = UIColor(named: "purple_184")
            
            cell.sameSchoolLabel.layer.cornerRadius = cell.sameSchoolLabel.frame.height/2
            cell.sameSchoolLabel.text = "같은 학교"
            cell.sameSchoolLabel.isHidden = false
            
        }
        else {
            cell.sameSchoolLabel.isHidden = true
        }
        
        cell.selectionStyle = .none

        // 기본 디자인 세팅
        cell.cancelLabel.isHidden = true
        cell.positionLabel.text = personList[indexPath.row].position
        cell.callStateBtn.setTitle("\(personList[indexPath.row].callStm)", for: .normal)
        cell.selectionStyle = .none
        
        cell.callStateBtn.layer.cornerRadius = cell.callStateBtn.frame.height/2
        cell.callStateBtn.setTitle("\(personList[indexPath.row].callStm)", for: .normal)
        cell.callingStateBtn.setTitle("\(personList[indexPath.row].callStm)", for: .normal)
        cell.callStateBtn.layer.masksToBounds = true
        
        cell.callStateBtn.backgroundColor = .clear
        cell.callStateBtn.layer.borderWidth = 0.5
        cell.callStateBtn.layer.borderColor = UIColor(named: "gray_196")?.cgColor
        cell.callStateBtn.setTitleColor(UIColor(named: "gray_196"), for: .normal)
        cell.nicknameLabel.textColor = .black
        
        cell.positionLabel.textColor = UIColor(named: "gray_121")
        cell.callStateBtn.isHidden = false
        cell.callingStateBtn.isHidden = true
        
        
        // 개인일 경우
        cell.profileImg.layer.cornerRadius = cell.profileImg.frame.height/2
        
        // 팀일 경우 디자인 세팅
        cell.teamProfileLabel.isHidden = true
        cell.circleTitleView.isHidden = true
        cell.circleTitleView.layer.cornerRadius = cell.circleTitleView.frame.height/2
        cell.circleTitleView.layer.masksToBounds = true
        print(personList[indexPath.row].callStm)
        // 버튼 색상 처리
        if personList[indexPath.row].callStm == "요청거절됨" || personList[indexPath.row].callStm == "요청취소됨" {
            cell.layer.borderWidth = 0.0
            cell.callStateBtn.backgroundColor = .systemGray6
            cell.callStateBtn.setTitleColor(.lightGray, for: .normal)
            cell.cancelLabel.text = "요청 거절됨"
            cell.cancelLabel.textColor = UIColor(named: "red_254")
            cell.nicknameToSameSchoolConst.constant = 6
            cell.cancelLabel.isHidden = false
            cell.callStateBtn.isHidden = true
            
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
                    cell.profileImg.isHidden = true
                    cell.teamProfileLabel.isHidden = false
                    cell.circleTitleView.isHidden = false
                    
                    let teamFirstName = personList[indexPath.row].nickname[personList[indexPath.row].nickname.startIndex]
                    cell.teamProfileLabel.text = String(teamFirstName)
                    
                }
            }
            // 다른 사람이 우리 팀으로 보낸 경우 -> 개인 표시
            for j in 0..<whenIReceivedOtherPerson.count {
                if whenIReceivedOtherPerson[j].nickname == personList[indexPath.row].nickname {
                    // kingfisher 사용하기 위한 url
                    let uid: String = personList[indexPath.row].profileImg
                    let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")
                    
                    // Fetch the download URL
                    starsRef.downloadURL { [self] url, error in
                        if let error = error {
                        } else {
                            cell.profileImg.kf.setImage(with: url)
                        }
                    }
                }
            }
            
            
            if personList[indexPath.row].callStm == "요청취소됨" {
                cell.nicknameLabel.textColor = .systemGray5
                cell.positionLabel.textColor = .systemGray5
                cell.profileImg.tintColor = UIColor(named: "gray_light2")
                cell.cancelLabel.text = "요청 취소됨"
                cell.cancelLabel.textColor = UIColor(named: "gray_196")
                
            }
        }
        else if personList[indexPath.row].callStm == "대기 중" {
            // 내가 팀에 보낸 경우 -> 팀 표시
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
                    cell.profileImg.isHidden = true
                    cell.teamProfileLabel.isHidden = false
                    cell.circleTitleView.isHidden = false
                    
                    let teamFirstName = personList[indexPath.row].nickname[personList[indexPath.row].nickname.startIndex]
                    cell.teamProfileLabel.text = String(teamFirstName)
                    
                }
            }
            // 다른 사람이 우리 팀으로 보낸 경우 -> 개인 표시
            for j in 0..<whenIReceivedOtherPerson.count {
                print("akak")
                if whenIReceivedOtherPerson[j].nickname == personList[indexPath.row].nickname {
                    // kingfisher 사용하기 위한 url
                    let uid: String = personList[indexPath.row].profileImg
                    print(uid)
                    let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")
                    
                    // Fetch the download URL
                    starsRef.downloadURL { [self] url, error in
                        if let error = error {
                            print("error.localizedDescription \(error.localizedDescription)")
                        } else {
                            
                            DispatchQueue.main.async {
                                cell.profileImg.kf.setImage(with: url)
                            }
                        }
                    }
                }
            }
            cell.callStateBtn.layer.borderWidth = 0
            cell.callStateBtn.backgroundColor = UIColor(named: "purple_184")
            cell.callStateBtn.setTitleColor(.white, for: .normal)
        }
        
        else if personList[indexPath.row].callStm == "요청옴" {
            for i in 0..<whenIReceivedOtherPerson.count {
                if whenIReceivedOtherPerson[i].nickname == personList[indexPath.row].nickname {
                    // kingfisher 사용하기 위한 url
                    let uid: String = personList[indexPath.row].profileImg
                    let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")
                    
                    // Fetch the download URL
                    starsRef.downloadURL { [self] url, error in
                        if let error = error {
                            print("error \(error.localizedDescription)")
                        } else {
                            cell.profileImg.kf.setImage(with: url)
                        }
                    }
                }
            }
            
            cell.callStateBtn.layer.borderWidth = 0
            cell.callStateBtn.backgroundColor = UIColor(named: "green_dark")
            cell.callStateBtn.setTitleColor(.white, for: .normal)
            
        }
        else if personList[indexPath.row].callStm == "요청됨" {
            
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
                    cell.profileImg.isHidden = true
                    cell.teamProfileLabel.isHidden = false
                    cell.circleTitleView.isHidden = false
                    
                    let teamFirstName = personList[indexPath.row].nickname[personList[indexPath.row].nickname.startIndex]
                    cell.teamProfileLabel.text = String(teamFirstName)
                    
                }
            }
            cell.callStateBtn.layer.borderWidth = 0.5
            cell.callStateBtn.layer.borderColor = UIColor(named: "gray_196")?.cgColor
            cell.callStateBtn.setTitleColor(UIColor(named: "gray_51"), for: .normal)
            cell.callStateBtn.backgroundColor = nil
            
        }
        
        else if personList[indexPath.row].callStm == "통화" {
            
            // 내가 팀에 보낸 경우 -> 팀 표시
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
                    cell.profileImg.isHidden = true
                    cell.teamProfileLabel.isHidden = false
                    cell.circleTitleView.isHidden = false
                    
                    let teamFirstName = personList[indexPath.row].nickname[personList[indexPath.row].nickname.startIndex]
                    cell.teamProfileLabel.text = String(teamFirstName)
                    
                }
            }
            // 다른 사람이 우리 팀으로 보낸 경우 -> 개인 표시
            for j in 0..<whenIReceivedOtherPerson.count {
                if whenIReceivedOtherPerson[j].nickname == personList[indexPath.row].nickname {
                    // kingfisher 사용하기 위한 url
                    let uid: String = personList[indexPath.row].profileImg
                    let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")
                    
                    // Fetch the download URL
                    starsRef.downloadURL { [self] url, error in
                        if let error = error {
                        } else {
                            cell.profileImg.kf.setImage(with: url)
                        }
                    }
                }
            }
            
            
            cell.callingStateBtn.setTitleColor(.white, for: .normal)
            cell.callingStateBtn.layer.cornerRadius = cell.callingStateBtn.frame.height/2
            cell.callingStateBtn.translatesAutoresizingMaskIntoConstraints = false
            cell.callingStateBtn.backgroundColor = UIColor(named: "purple_184")
            cell.callStateBtn.isHidden = true
            cell.callingStateBtn.isHidden = false
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 회색에서 다시 하얗게 변하도록 설정
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        
        if personList[indexPath.row].callStm == "대기 중" {
            let waitingRoomVC = thisStoryboard.instantiateViewController(withIdentifier: "waitingRoomVC") as! ChannelWaitingViewController
            waitingRoomVC.modalPresentationStyle = .fullScreen
            
            // 1. 내가 보낸 경우 -> 팀을 표시해야함
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
            
                    // 받는 사람
                    waitingRoomVC.nickname = personList[indexPath.row].nickname
                    var position = personList[indexPath.row].position
                    waitingRoomVC.position = position
                    
                    //personList[indexPath.row].
                    
                    waitingRoomVC.fromPerson = myNickname
                    waitingRoomVC.toPerson = personList[indexPath.row].nickname
                    // 대기 중, 요청됨, 통화도 보낸 사람으로 구분
                    waitingRoomVC.questionArr = questionArrSend[i]
                    waitingRoomVC.callTime = callTimeArrSend[i][0]
                    waitingRoomVC.profile = personList[indexPath.row].profileImg
                    
                }
            }
            // 2. 내가 승인한 경우
            for i in 0..<whenIReceivedOtherPerson.count {
                if whenIReceivedOtherPerson[i].nickname == personList[indexPath.row].nickname {
                
                    // 받는 사람
                    waitingRoomVC.nickname = personList[indexPath.row].nickname
                    var position = personList[indexPath.row].position
                    waitingRoomVC.position = position
                    
                    //personList[indexPath.row].
                    
                    waitingRoomVC.fromPerson = personList[indexPath.row].nickname
                    waitingRoomVC.toPerson = myNickname
                    
                    waitingRoomVC.questionArr = questionArr[i]
                    waitingRoomVC.callTime = callTimeArr[i][0]
                    waitingRoomVC.profile = personList[indexPath.row].profileImg
                    
                }
            }
            present(waitingRoomVC, animated: true, completion: nil)
            
            
        }
        else if personList[indexPath.row].callStm == "요청됨" {
            let historyVC = thisStoryboard.instantiateViewController(withIdentifier: "teamHistoryVC") as! CallRequstTeamHistoryViewController
            historyVC.modalPresentationStyle = .fullScreen
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname {
                    historyVC.callTime = callTimeArrSend[i]
                    historyVC.teamFormatPerson = personList[indexPath.row]
                    historyVC.questionArr = questionArrSend[i]
                    historyVC.teamIndex = teamIndexForSend[i]
                }
            }
            present(historyVC, animated: true, completion: nil)
        }
        else if personList[indexPath.row].callStm == "통화" {
            let callingVC = storyboard?.instantiateViewController(withIdentifier: "callingTeamVC") as! ChannelTeamViewController
            
            callingVC.nickname = personList[indexPath.row].nickname
            var position = personList[indexPath.row].position
            callingVC.position = String(position)
            
            
            var callCount: Int = -1
            print(personList[0].callStm)
            for j in 0...indexPath.row{
                if personList[j].callStm == "통화" {
                    print("추가")
                    callCount += 1
                }
            }
            
            // 보낸 거랑 어캐 구분..?
            
          
            // 내가 보냈을 때 ->
            for i in 0..<whenISendOtherTeam.count {
                if whenISendOtherTeam[i].nickname == personList[indexPath.row].nickname && whenISendOtherTeam[i].callStm == "통화" {
                    callingVC.teamIndex = callTeamIndex[callCount]
                }
            }
             
            // 내가 받았을 때
            for j in 0..<whenIReceivedOtherPerson.count {
                if whenIReceivedOtherPerson[j].nickname == personList[indexPath.row].nickname && whenIReceivedOtherPerson[j].callStm == "통화" {
                    print(j)
                    print(callCount)
                    callingVC.teamIndex = callTeamIndex[callCount]
                }
            }
           
            callingVC.nowEntryPersonUid = Auth.auth().currentUser!.uid
            callingVC.name = name
            callingVC.image = personList[indexPath.row].profileImg
            callingVC.modalPresentationStyle = .fullScreen
            present(callingVC, animated: true, completion: nil)
        }
        else if personList[indexPath.row].callStm == "요청옴" {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "CallAgree", bundle: nil)
            if let nextView = storyboard.instantiateInitialViewController() as? UINavigationController,
               let nextViewChild = nextView.viewControllers.first as? CallAgreeViewController {
              
                print(whenIReceivedOtherPerson.count)
                for j in 0..<whenIReceivedOtherPerson.count {
                    if whenIReceivedOtherPerson[j].nickname == personList[indexPath.row].nickname {
                        print(callTimeArr[0])
                        print(j)
                        nextViewChild.times = callTimeArr[j]
                        nextViewChild.questionArr = questionArr[j]
                        nextViewChild.teamName = teamIndex[j]
                        nextViewChild.callerNickname = fetchedInputUIDToNickName
                    }
                }
                
                nextView.modalPresentationStyle = .fullScreen
                self.present(nextView, animated: true, completion: nil)
            }
            
        }
        return indexPath
    }
}