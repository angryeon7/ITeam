//
//  FavorTeamViewController.swift
//  iteam_ny
//
//  Created by 김하늘 on 2022/03/30.
//

import UIKit
import Firebase
import FirebaseStorage

class FavorTeamViewController: UIViewController {
    var teamList: [Team] = []
    var images: [String] = []
    var teamListTest: [TeamProfile] = []
    var teamNameList: [String] = []
    var memberListArr: [[String]] = [[]]
    @IBOutlet weak var collView: UICollectionView!
    var uiImages: [[UIImage]] = [[]]
    // 프로필 이미지 URL을 위한 변수
    var imageURL: URL  = NSURL() as URL
    
    let db = Database.database().reference()
    var doesFavorTeamExisted: Bool = false
    var didFetched: Bool = false {
        didSet {
            self.collView.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 삭제할 더미데이터 -> 추후 서버에서 받아와야함
        
        let firstTeamImages: [String] = ["imgUser10.png", "imgUser5.png", "imgUser4.png"]
        let firstTeam = Team(teamName: "이성책임", purpose: "공모전", part: "디자이너, 개발자 구인 중", images: firstTeamImages)
        let secondTeam = Team(teamName: "Ctrl+P", purpose: "포트폴리오", part: "모든 파트 구인 중", images: firstTeamImages)
        let thirdTeam = Team(teamName: "가온누리", purpose: "함께 논의해 봐요", part: "개발자 구인 중", images: firstTeamImages)
        
        
        
        teamList.append(firstTeam)
        teamList.append(secondTeam)
        teamList.append(thirdTeam)
        
        
        fetchData()
        
        loadImageFromFirebase()
        
        super.viewWillAppear(false)
    }
    func fetchData() {
        self.memberListArr.removeAll()

        let favorTeamList = db.child("Team")
        let query = favorTeamList.queryOrdered(byChild: "serviceType").queryEqual(toValue: "앱 서비스")
      
        query.observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value as? [String: Any] else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: Array(value.values), options: [])
                // print(jsonData)
                let teamData = try JSONDecoder().decode([TeamProfile].self, from: jsonData)
                self.teamListTest = teamData
                self.teamNameList = Array(value.keys)
                print(self.teamNameList.count)
                self.collView.reloadData()
                
                
                 
//                // 한 팀의 멤버들 UID배열
//                for i in 0..<self.teamListTest.count {
//                    self.memberListArr.append([])
//                    self.memberListArr[i].append(contentsOf: self.teamListTest[i].memberList.components(separatedBy: ", "))
//                    print("memberListArr : \(i)이지롱 \(self.memberListArr[i])")
//                    self.fetchImages(teamIndex: i)
//                }
                
                
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    func fetchImages(teamIndex: Int) {
        
        for memberIndex in 0..<memberListArr[teamIndex].count {
            print("memberListArr : \(teamIndex)의 \(memberIndex)번째 ")
            let userUID = memberListArr[teamIndex][memberIndex]
            let storage = Storage.storage().reference().child("user_profile_image").child(userUID + ".jpg")
            print(userUID + ".jpg")
            self.uiImages.append([])
            storage.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    do {
                        let data = try Data(contentsOf: url!)
                        let image = UIImage(data: data)
                        self.uiImages[teamIndex].append(image!)
                        self.collView.reloadData()
                        
                        // 리로드 완료되면 실행
                        self.collView.performBatchUpdates {
                            print("fetchImages")
                            
                            print("collView")
                            // 정상출력
                            //print("uiImages \(self.uiImages)")
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func moreTeamBtn(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "TeamPages_AllTeams", bundle: nil)
        if let allTeamNavigation = storyboard.instantiateInitialViewController() as? UINavigationController, let allTeamVC = allTeamNavigation.viewControllers.first as? AllTeamViewController {
            allTeamVC.teamKind = .favor
            allTeamNavigation.modalPresentationStyle = .fullScreen
           
            present(allTeamNavigation, animated: true, completion: nil)
        }
    }
    
    
    
    
}

extension FavorTeamViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamListTest.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorTeamCell", for: indexPath) as! FavorTeamCollectionViewCell
        
        // 셀 디자인 및 데이터 세팅
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.layer.masksToBounds = false
        
        cell.teamName.text = teamNameList[indexPath.row]
        cell.purpose.text = teamListTest[indexPath.row].purpose
        cell.part.text = teamListTest[indexPath.row].part
        cell.images.append(UIImage())
        // cell.images[0] = UIImage(named: "asset121.png")!
        cell.images = uiImages[0]
        print(uiImages[0].count)
        
        
        return cell
    }
    
    // 테스트
    func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "TeamPages_AllTeams", bundle: nil)
        if let allTeamNavigation = storyboard.instantiateInitialViewController() as? UINavigationController, let allTeamVC = allTeamNavigation.storyboard?.instantiateViewController(withIdentifier: "cellSelectedTeamProfileVC") as? TeamProfileViewController {
            // allTeamVC.teamKind = .favor
            allTeamVC.modalPresentationStyle = .fullScreen
            allTeamVC.teamName = teamNameList[indexPath.row]
            present(allTeamVC, animated: true, completion: nil)
        }
    }
    
    // 임시 테스트
    func loadImageFromFirebase() {
        let storage = Storage.storage().reference().child("user_profile_image").child(Auth.auth().currentUser!.uid + ".jpg")
        storage.downloadURL { (url, error) in
            if error != nil {
                print("이것이 에러 \(error?.localizedDescription)")
            }
            print("다운로드 성공")
            self.imageURL = url!
            let data = try? Data(contentsOf: self.imageURL)
            let resizedImage = self.resizeImage(image: UIImage(data: data!)!, width: 50, height: 50)
            DispatchQueue.main.async {
                self.uiImages[0].append(UIImage())
                self.uiImages[0][0] = resizedImage
                
                self.didFetched = true
            }
        }
    }
    
}
extension FavorTeamViewController: UICollectionViewDelegateFlowLayout {

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
        
    }

    // cell 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = 261
        let height = 198

        let size = CGSize(width: width, height: height)
        return size
    }
}

