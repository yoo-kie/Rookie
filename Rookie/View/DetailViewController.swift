//
//  DetailViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    private var detailModel: DetailModel = DetailModel()
    
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
    
    var detailDate: String = ""
    private var mainTasks = [Tasks]()
    private var mainDoneTasks = [Tasks]()
    private var mainRookie: String = ""
    private var collectionViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailModel.delegate = self
        
        detailDateLabel.text = detailDate
            
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        detailCollectionView.register(UINib(nibName: "DetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailCell")
            
        collectionViewHeight = self.view.frame.height * 0.15
        detailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        detailCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
        
        reloadMainTasks()
    }
    
    func reloadMainTasks() {
        detailModel.fetchMain(of: detailDate)
    }
    
    func updateTodayProgress() {
        let totalCount = mainTasks.count
        let doneCount = mainDoneTasks.count
            
        let level = Level.fetchLevel(total: totalCount, done: doneCount)
        finishWordLabel.text = level.labelText
        detailProgressImage.image = level.image
            
        UIView.animate(withDuration: 1.0) {
            self.detailProgressView.setProgress(
                Float(doneCount) / Float(totalCount),
                animated: true
            )
        }
        
        self.detailProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
}

extension DetailViewController: DetailModelDelegate {
    func detailModel(mainTasks: [Tasks], mainDoneTasks: [Tasks], mainRookie: String) {
        self.mainTasks = mainTasks
        self.mainDoneTasks = mainDoneTasks
        self.mainRookie = mainRookie
        updateTodayProgress()
        self.detailCollectionView.reloadData()
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let task = mainTasks[indexPath.row]
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
        let task = mainTasks[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell else {
            return
        }
        
        if doneYN == "N" {
            cell.detailLabel.textColor = .white
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            let updateData: [String: Any] = ["id": id, "done_yn": "Y"]
            self.detailModel.updateTask(of: updateData, completionHandler: nil)
        } else {
            cell.detailLabel.textColor = .black
            cell.detailView.backgroundColor = #colorLiteral(red: 0.8298448324, green: 0.8831481338, blue: 0.6543511152, alpha: 1)
            let updateData: [String: Any] = ["id": id, "done_yn": "N"]
            self.detailModel.updateTask(of: updateData, completionHandler: nil)
        }
            
        self.reloadMainTasks()
    }
}
