//
//  FavorTeamCollectionViewCell.swift
//  iteam_ny
//
//  Created by 김하늘 on 2022/03/30.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class FavorTeamCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var purpose: UILabel!
    @IBOutlet weak var part: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var resizedImage: UIImage = UIImage()
    let user = Auth.auth().currentUser!
    let ref = Database.database().reference()
    
    var usersUID: [String] = [] {
        didSet {
            
            imageCollectionView.reloadData()
        }
    }
    
    // 서버에서 받아 올 사용자 이미지 데이터
    var imageData: [Data] = [] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    var likeBool: Bool = true {
        didSet(newValue) {
            if newValue == false {
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                likeButton.tintColor = UIColor(named: "gray_196")
            }
            else {
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                likeButton.tintColor = UIColor(named: "gray_196")
            }
        }
    }
    // delegate와 datasource를 내부 collectionview로 옮겨줌
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.semanticContentAttribute = .forceRightToLeft
        
        imageData = imageData.reversed()
    }
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if likeBool {
            likeBool = false
            removeDataAcion()
        }
        else {
            likeBool = true
            pullDataAcion()
        }
    }
    // 관심있는 팀에 추가
    func pullDataAcion() {
        var updateString: String = ""
        
        // 데이터 받아와서 이미 있으면 합쳐주기
        ref.child("user").child(user.uid).child("likeTeam").child("teamName").observeSingleEvent(of: .value) {snapshot in
            var lastDatas: [String] = []
            var lastData: String! = snapshot.value as? String
            lastDatas = lastData.components(separatedBy: ", ")
            if !lastDatas.contains(self.teamName.text!) {
                if snapshot.value as? String == nil || snapshot.value as? String == "" {
                    var lastData: String! = snapshot.value as? String
                    updateString = self.teamName.text!
                }
                else {
                    var lastData: String! = snapshot.value as? String
                    lastData += ", \(self.teamName.text!)"
                    updateString = lastData
                }
                let values: [String: Any] = [ "teamName": updateString ]
                // 데이터 추가
                self.ref.child("user").child(self.user.uid).child("likeTeam").updateChildValues(values)
            }
        }
    }
    
    // 관심있는 팀에서 삭제
    func removeDataAcion() {
        var updateString: String = ""
        var lastDatas: [String] = []
        
        // 데이터 받아와서 이미 있으면 지워주기
        ref.child("user").child(user.uid).child("likeTeam").child("teamName").observeSingleEvent(of: .value) {snapshot in
            if snapshot.value as? String != nil {
                var lastData: String! = snapshot.value as? String
                lastDatas = lastData.components(separatedBy: ", ")
                
                for i in 0..<lastDatas.count {
                    if lastDatas[i] == self.teamName.text! {
                        lastDatas.remove(at: i)
                        break
                    }
                }
                for i in 0..<lastDatas.count {
                    if lastDatas[i] == "" {
                        lastDatas.remove(at: i)
                        break
                    }
                    if i == 0 {
                        updateString += lastDatas[i]
                    }
                    else {
                        updateString += ", \(lastDatas[i])"
                    }
                }
            }
            let values: [String: Any] = [ "teamName": updateString ]
            // 데이터 추가
            self.ref.child("user").child(self.user.uid).child("likeTeam").updateChildValues(values)
        }
    }
        
}
extension FavorTeamCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if usersUID.count <= 3 {
            return usersUID.count
        }
        else {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorTeamImageCell", for: indexPath) as! FavorTeamImagesCollectionViewCell
        
        cell.userImages.isHidden = false
        cell.layer.cornerRadius = cell.frame.height/2
        cell.gradientView.isHidden = true
        cell.memberCountLabel.isHidden = true
        
        
        let uid: String = usersUID[indexPath.row]
        
        let starsRef = Storage.storage().reference().child("user_profile_image/\(uid).jpg")

        // Fetch the download URL
        starsRef.downloadURL { [self] url, error in
          if let error = error {
              print("에러 \(error.localizedDescription)")
          } else {
              cell.userImages.kf.setImage(with: url)
          }
        }
        // Fetch the download URL
        if usersUID.count > 3  {
            if indexPath.row == 2 {
                cell.userImages.isHidden = true
                cell.gradientView.isHidden = false
                cell.memberCountLabel.isHidden = false
                cell.memberCountLabel.text = "+\(usersUID.count-2)"
            }
        }
    
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(ciColor: .white).cgColor
        cell.layer.masksToBounds = true
        
        return cell
    }
  
    
}
extension FavorTeamCollectionViewCell: UICollectionViewDelegateFlowLayout {

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -10
        
    }

    // cell 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = 54
        let height = 54

        let size = CGSize(width: width, height: height)
        return size
    }
    
    // 중앙 정렬
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemWidth = 54
        let spacingWidth = 18
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        let cellSpacingWidth = numberOfItems * spacingWidth
        let totalCellWidth = numberOfItems * itemWidth + cellSpacingWidth
        let inset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth)) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

