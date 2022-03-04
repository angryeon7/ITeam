//
//  SettingPurposeViewController.swift
//  ITeam_basic
//
//  Created by 김하늘 on 2021/11/21.
//

import UIKit

class SettingPurposeViewController: UIViewController {

    // 목적 저장을 위한 변수
    var purposes: [String] = []
    
    // 목적 버튼
    @IBOutlet var purposeBtns: [UIButton]!
    @IBOutlet weak var portfolioImg: UIImageView!
    @IBOutlet weak var contestImg: UIImageView!
    @IBOutlet weak var hackathonImg: UIImageView!
    @IBOutlet weak var startupImg: UIImageView!
    @IBOutlet weak var etcImg: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextBtn.layer.cornerRadius = 8
        for i in 0...purposeBtns.count-1 {
            purposeBtns[i].layer.cornerRadius = 16
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func purposeBtn(_ sender: UIButton) {
        if purposes.contains((sender.titleLabel?.text)!) {
            switch sender.titleLabel?.text {
            case "포트폴리오":
                portfolioImg.image = nil
            case "공모전":
                contestImg.image = nil
            case "해커톤":
                hackathonImg.image = nil
            case "창업":
                startupImg.image = nil
            default:
                etcImg.image = nil
            }
            sender.backgroundColor = UIColor(named: "gray_light3")
            sender.layer.borderWidth = 0
            
            
            
            if let firstIndex = purposes.firstIndex(of: (sender.titleLabel?.text)!) {
                purposes.remove(at: firstIndex)
                print(firstIndex)
                
                // 3순위를 2순위로 바꿈
                print("aaaa")
                if purposes.count >= 1 {
                    switch purposes[0] {
                    case nil: break
                    case "포트폴리오":
                        portfolioImg.image = UIImage(systemName: "1.circle.fill")
                    case "공모전":
                        contestImg.image = UIImage(systemName: "1.circle.fill")
                    case "해커톤":
                        hackathonImg.image = UIImage(systemName: "1.circle.fill")
                    case "창업":
                        startupImg.image = UIImage(systemName: "1.circle.fill")
                    default:
                        etcImg.image = UIImage(systemName: "1.circle.fill")
                }
                }
                if purposes.count >= 2 {
                    switch purposes[1] {
                    case nil:
                        break
                    case "포트폴리오":
                        portfolioImg.image = UIImage(systemName: "2.circle.fill")
                    case "공모전":
                        contestImg.image = UIImage(systemName: "2.circle.fill")
                    case "해커톤":
                        hackathonImg.image = UIImage(systemName: "2.circle.fill")
                    case "창업":
                        startupImg.image = UIImage(systemName: "2.circle.fill")
                    default:
                        etcImg.image = UIImage(systemName: "2.circle.fill")
                    }
                }
                
            }
        }
        else {
            if purposes.isEmpty == true {
                switch sender.titleLabel?.text {
                case "포트폴리오":
                    portfolioImg.image = UIImage(systemName: "1.circle.fill")
                case "공모전":
                    contestImg.image = UIImage(systemName: "1.circle.fill")
                case "해커톤":
                    hackathonImg.image = UIImage(systemName: "1.circle.fill")
                case "창업":
                    startupImg.image = UIImage(systemName: "1.circle.fill")
                default:
                    etcImg.image = UIImage(systemName: "1.circle.fill")
                }
                sender.backgroundColor = UIColor(named: "purple_light")
                sender.layer.borderWidth = 0.5
                sender.layer.borderColor = UIColor(named: "purple_dark")?.cgColor
                
                purposes.append((sender.titleLabel?.text)!)
            }
            else if purposes.count == 1 {
                switch sender.titleLabel?.text {
                case "포트폴리오":
                    portfolioImg.image = UIImage(systemName: "2.circle.fill")
                case "공모전":
                    contestImg.image = UIImage(systemName: "2.circle.fill")
                case "해커톤":
                    hackathonImg.image = UIImage(systemName: "2.circle.fill")
                case "창업":
                    startupImg.image = UIImage(systemName: "2.circle.fill")
                default:
                    etcImg.image = UIImage(systemName: "2.circle.fill")
                }
                sender.backgroundColor = UIColor(named: "purple_light")
                sender.layer.borderWidth = 0.5
                sender.layer.borderColor = UIColor(named: "purple_dark")?.cgColor
                
                purposes.append((sender.titleLabel?.text)!)
            }
            else if purposes.count == 2 {
                switch sender.titleLabel?.text {
                case "포트폴리오":
                    portfolioImg.image = UIImage(systemName: "3.circle.fill")
                case "공모전":
                    contestImg.image = UIImage(systemName: "3.circle.fill")
                case "해커톤":
                    hackathonImg.image = UIImage(systemName: "3.circle.fill")
                case "창업":
                    startupImg.image = UIImage(systemName: "3.circle.fill")
                default:
                    etcImg.image = UIImage(systemName: "3.circle.fill")
                }
                sender.backgroundColor = UIColor(named: "purple_light")
                sender.layer.borderWidth = 0.5
                sender.layer.borderColor = UIColor(named: "purple_dark")?.cgColor
                
                purposes.append((sender.titleLabel?.text)!)
            }
        }
        

        print(purposes)
        
    }
    @IBAction func goBackBtn(_ sender: UIBarButtonItem) {
        goBack()
    }
    @objc func goBack() {
           self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}