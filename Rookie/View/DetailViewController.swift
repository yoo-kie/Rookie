//
//  DetailViewController.swift
//  Rookie
//
//  Created by 유연주 on 2020/08/19.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    @IBOutlet var dateTitleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var detailProgressView: UIProgressView!
    @IBOutlet var detailProgressLabel: UILabel!
    @IBOutlet var detailCollectionView: UICollectionView!
    
    var detailDate: String = ""
    private var todoTasks: [Tasks] = []
    private var todoDoneTasks: [Tasks] = []
    private var rookie: String = ""
    private var collectionViewHeight: CGFloat!
    
    private var detailModel: DetailModel = DetailModel()
    lazy var todoUICollectionDataSource = TodoUICollectionDataSource { indexPath in
        let task = self.todoTasks[indexPath.row]
        let id = task.id
        let doneYN = task.done_yn
        
        let toggle = doneYN == "Y" ? "N" : "Y"
        let updateData: [String: Any] = ["id": id, "done_yn": toggle]
        self.detailModel.updateTask(of: updateData) {
            self.fetchTasks()
            
            guard let cell = self.detailCollectionView.cellForItem(at: indexPath) as? TodayCollectionViewCell
            else { return }
            
            cell.update(doneYN: doneYN)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setEditUI()
        fetchTasks()
    }
    
    func configureCollectionView() {
        detailCollectionView.delegate = self.todoUICollectionDataSource
        detailCollectionView.dataSource = self.todoUICollectionDataSource
        detailCollectionView.register(
            UINib(nibName: "TodayCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "todayCell"
        )
        
        collectionViewHeight = self.view.frame.height * 0.15
        detailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        detailCollectionView.heightAnchor.constraint(
            equalToConstant: collectionViewHeight
        ).isActive = true
    }
    
    func setEditUI() {
        dateTitleLabel.text = detailDate
    }
    
    func fetchTasks() {
        detailModel.fetchTasks(of: detailDate) { [weak self] (tasks, doneTasks) in
            guard let self = self else { return }
            
            self.todoUICollectionDataSource.todoTasks = tasks
            self.todoTasks = tasks
            self.todoDoneTasks = doneTasks
            
            self.detailModel.fetchRookie(of: self.detailDate) { rookie in
                self.rookie = rookie
                self.updateRookie()
                self.detailCollectionView.reloadData()
            }
        }
    }
    
    func updateRookie() {
        let totalCount = todoTasks.count
        let doneCount = todoDoneTasks.count
            
        let level = Level.fetchLevel(total: totalCount, done: doneCount)
        detailLabel.text = level.labelText
        detailImageView.image = UIImage(named: level.imageName)
            
        UIView.animate(withDuration: 1.0) {
            self.detailProgressView.setProgress(
                Float(doneCount) / Float(totalCount),
                animated: true
            )
        }
        
        detailProgressLabel.text = "\(doneCount)/\(totalCount)"
    }
    
}
