//
//  DetailViewController.swift
//  RPG
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var detailDate: String = "2020.08.20"
    var detailCharacter: String = ""
    
    @IBOutlet var detailTitleLabel: UILabel!
    @IBOutlet var finishWordLabel: UILabel!
    @IBOutlet var detailProgressImage: UIImageView!
    @IBOutlet var detailProgressView: UIProgressView!
    @IBOutlet var detailProgressLabel: UILabel!
    
    @IBOutlet var detailCollectionView: UICollectionView! = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: "detailCell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTitleLabel.text = detailDate
        detailCharacter = DBManager.shared.selectCharacterWithDate(detailDate)
        
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        detailCollectionView.register(UINib(nibName: "DetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailCell")
        
        self.updateProgressView()
    }

    @IBAction func clickDimissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController {
    
    func updateProgressView() {
        let totalCount = DBManager.shared.selectTasksWithDate(self.detailDate).count
        let doneCount = DBManager.shared.selectDoneTasksWithDate(self.detailDate).count
        
        let level = (4.0 &/ Float(totalCount)) * Float(doneCount)
        
        switch level {
            case 0..<1 :
                finishWordLabel.text = "Level 1"
                detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_1")
                break
            case 1..<2 :
                finishWordLabel.text = "Level 2"
                detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_2")
                break
            case 2..<3 :
                finishWordLabel.text = "Level 3"
                detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_3")
                break
            case 3..<4 :
                finishWordLabel.text = "Level 4"
                detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_4")
                break
            case 4 :
                finishWordLabel.text = "Final-!!!"
                detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_5")
                break
            default:
                print("no more level up")
        }
        
        UIView.animate(withDuration: 1.0) {
            self.detailProgressView.setProgress(Float(doneCount) &/ Float(totalCount), animated: true)
        }
        
        self.detailProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
    
}

extension DetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height/1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DBManager.shared.selectTasksWithDate(detailDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = DBManager.shared.selectTasksWithDate(detailDate)[indexPath.row]
        let title = task.title
        let doneYN = task.done_yn
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailCollectionViewCell
        cell.detailLabel.text = title
            
        if doneYN == "Y" {
            cell.detailLabel.textColor = .white
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            cell.detailLabel.textColor = .black
            cell.detailView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        }
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task = DBManager.shared.selectTasksWithDate(self.detailDate)[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
        
        let cell = collectionView.cellForItem(at: indexPath) as! DetailCollectionViewCell
            
        if doneYN == "N" {
            cell.detailLabel.textColor = .white
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            DBManager.shared.updateTask(id, "Y")
        } else {
            cell.detailLabel.textColor = .black
            cell.detailView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            DBManager.shared.updateTask(id, "N")
        }
            
        self.updateProgressView()
    }
    
}
