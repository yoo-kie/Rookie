//
//  DetailViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var detailDate: String = ""
    var detailCharacter: String = ""
    var collectionViewHeight: CGFloat!
    
    @IBOutlet var detailDateLabel: UILabel!
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
        
        if detailDate != "" {
            detailDateLabel.text = detailDate
            
            guard let character = DBManager.shared.selectCharacterWithDate(detailDate) else {
                return
            }
            detailCharacter = character
            
            detailCollectionView.delegate = self
            detailCollectionView.dataSource = self
            detailCollectionView.register(UINib(nibName: "DetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailCell")
            
            collectionViewHeight = self.view.frame.height * 0.15
            detailCollectionView.translatesAutoresizingMaskIntoConstraints = false
            detailCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
            
            self.updateProgressView()
        }
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
        case 1..<2 :
            finishWordLabel.text = "Level 2"
            detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_2")
        case 2..<3 :
            finishWordLabel.text = "Level 3"
            detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_3")
        case 3..<4 :
            finishWordLabel.text = "Level 4"
            detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_4")
        case 4 :
            finishWordLabel.text = "Final-!!!"
            detailProgressImage.image = UIImage.init(named: "\(detailCharacter)_5")
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
    
    override func viewWillLayoutSubviews() {
        if let detailLayout = self.detailCollectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            DispatchQueue.main.async {
                detailLayout.invalidateLayout()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DBManager.shared.selectTasksWithDate(detailDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = DBManager.shared.selectTasksWithDate(detailDate)[indexPath.row]
        let title = task.title
        let doneYN = task.done_yn
            
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as? DetailCollectionViewCell else {
            return DetailCollectionViewCell()
        }
        cell.detailLabel.text = title
            
        if doneYN == "Y" {
            cell.detailLabel.textColor = .white
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            cell.detailLabel.textColor = .black
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8298448324, green: 0.8831481338, blue: 0.6543511152, alpha: 1)
        }
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task = DBManager.shared.selectTasksWithDate(self.detailDate)[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell else {
            return
        }
        
        if doneYN == "N" {
            cell.detailLabel.textColor = .white
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            DBManager.shared.updateTaskDoneYN(id, "Y")
        } else {
            cell.detailLabel.textColor = .black
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8298448324, green: 0.8831481338, blue: 0.6543511152, alpha: 1)
            DBManager.shared.updateTaskDoneYN(id, "N")
        }
            
        self.updateProgressView()
        self.detailCollectionView.reloadData()
    }
}
