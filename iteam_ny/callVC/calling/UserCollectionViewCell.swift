//
//  UserCollectionViewCell.swift
//  ITeam_basic
//
//  Created by 김하늘 on 2021/11/26.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var otherMemberNameTF: UILabel!
    @IBOutlet weak var otherMemberPartTF: UILabel!
    
    func setUI(image:String, nickname: String, position: String) {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.image = UIImage(named: image)
        otherMemberNameTF.text = nickname
        otherMemberPartTF.text = position
        }
    
}