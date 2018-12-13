//
//  ViewController.swift
//  FunctionalityExamples
//
//  Created by Nicholas Feng on 2018-12-12.
//  Copyright © 2018 ZhixuanFeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet var welcomeMessageView: UIView!
    let welcomeMsgDissmissDelay:Double = 4     // 欢迎信息过多久消失
    
    @IBOutlet var colorDragCollectionView: UICollectionView!
    @IBOutlet var colorDropCollectionView: UICollectionView!
    
    // 红绿蓝黄紫青
    let colorArray = [UIColor.init(hue: 1.0, saturation: 0.33, brightness: 1, alpha: 1),
                      UIColor.init(hue: 0.333, saturation: 0.33, brightness: 1, alpha: 1),
                      UIColor.init(hue: 0.667, saturation: 0.33, brightness: 1, alpha: 1),
                      UIColor.init(hue: 0.167, saturation: 0.33, brightness: 1, alpha: 1),
                      UIColor.init(hue: 0.833, saturation: 0.33, brightness: 1, alpha: 1),
                      UIColor.init(hue: 0.5, saturation: 0.33, brightness: 1, alpha: 1)]
    var droppedColors = [UIColor]() // 已放进上方collectionview的颜色
    var sourceIndice = [Int]()  // 目前正在拖行的cell在起始的collectionview里的位置
    var backgroundColor:UIColor = UIColor.white     // 目前上方collectionview的背景颜色
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 欢迎语
        displayWelcomeMessage()
        
        
        // 注册自定义cell
        colorDragCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")
        colorDropCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")
        
        
        // 将此controller作为collectionview的delegate和datasource
        colorDragCollectionView.delegate = self
        colorDragCollectionView.dataSource = self
        colorDropCollectionView.delegate = self
        colorDropCollectionView.dataSource = self
        
        colorDragCollectionView.dragDelegate = self
        colorDropCollectionView.dragDelegate = self
        colorDragCollectionView.dropDelegate = self
        colorDropCollectionView.dropDelegate = self
        colorDragCollectionView.dragInteractionEnabled = true
        colorDropCollectionView.dragInteractionEnabled = true
    }

    
    // 显示欢迎信息
    func displayWelcomeMessage() {
        UIView.animate(withDuration: 0.5, delay: 2.0, animations: {     // 滑进画面
            self.welcomeMessageView.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.welcomeMsgDissmissDelay)) {}    // 几秒后run code的另一种写法
            
            UIView.animate(withDuration: 0.5, delay: self.welcomeMsgDissmissDelay, animations: {          // 几秒后执行滑走动画
                self.welcomeMessageView.frame.origin.y = -self.welcomeMessageView.frame.height
                self.view.layoutIfNeeded()
            }, completion: nil)
        })
    }
    
    
    // 添加cell
    func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section) // 找位置
                if collectionView === self.colorDropCollectionView {
                    self.droppedColors.insert(item.dragItem.localObject as! UIColor, at: indexPath.row) // 添加颜色进array
                }
                indexPaths.append(indexPath)
                backgroundAddColor(color: item.dragItem.localObject as! UIColor) // 刷新背景颜色
            }
            collectionView.insertItems(at: indexPaths)  // 添加cell
        })
    }
    
    
    // 移除cell
    func removeItem(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        // 从颜色array的尾部开始删除以免出错
        let indice = sourceIndice.sorted().reversed()
        for index in indice {
            backgroundSubColor(color: droppedColors[index]) // 刷新背景颜色
            self.droppedColors.remove(at: index)
        }
        sourceIndice = [Int]()
        
        // 刷新collectionView
        self.colorDropCollectionView.reloadData()
    }
    
    
    // 背景颜色加上颜色
    func backgroundAddColor(color: UIColor) {
        let RGBA = getRGBA(color: backgroundColor)
        let RGBA2 = getRGBA(color: color)
        let newR = (RGBA[0] + RGBA2[0]) / 2
        let newG = (RGBA[1] + RGBA2[1]) / 2
        let newB = (RGBA[2] + RGBA2[2]) / 2
        backgroundColor = UIColor.init(red: newR, green: newG, blue: newB, alpha: 1.0)
        colorDropCollectionView.backgroundColor = backgroundColor
    }
    
    // 背景颜色减去颜色
    func backgroundSubColor(color: UIColor) {
        let RGBA = getRGBA(color: backgroundColor)
        let RGBA2 = getRGBA(color: color)
        let newR = RGBA[0]*2 - RGBA2[0]
        let newG = RGBA[1]*2 - RGBA2[1]
        let newB = RGBA[2]*2 - RGBA2[2]
        backgroundColor = UIColor.init(red: newR, green: newG, blue: newB, alpha: 1.0)
        colorDropCollectionView.backgroundColor = backgroundColor
    }
    
    // 返回含红绿蓝数值的array
    func getRGBA(color: UIColor) -> [CGFloat] {
        var R: CGFloat = 0
        var G: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 0
        color.getRed(&R, green: &G, blue: &B, alpha: &A)
        return [R, G, B, A]
    }
}


// UICollectionView相关设定
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 返回collectionview里cell的个数，初始为6个，0个
        return collectionView == self.colorDragCollectionView ? colorArray.count : droppedColors.count;
    }
    
    // 填充collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // colorDropCollectionView填充空白cell
        if collectionView == self.colorDropCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            cell.backgroundColor = droppedColors[indexPath.item]
            return cell;
        }
        else {  // colorDragCollectionView填充颜色cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            
            cell.backgroundColor = colorArray[indexPath.item]
            
            return cell
        }
    }
}

// Drag相关
extension ViewController : UICollectionViewDragDelegate {
    
    // 设定拖拽时抓取的信息（此处为颜色）
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = collectionView == colorDragCollectionView ?  self.colorArray[indexPath.item] : self.droppedColors[indexPath.item]    // 分别从哪里取颜色
        let itemProvider = NSItemProvider(object: item as UIColor)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item // 把颜色作为localObject
        if collectionView == colorDropCollectionView {
            sourceIndice.append(indexPath.item)
        }
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = collectionView == colorDragCollectionView ?  self.colorArray[indexPath.item] : self.droppedColors[indexPath.item]
        let itemProvider = NSItemProvider(object: item as UIColor)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        if collectionView == colorDropCollectionView {
            sourceIndice.append(indexPath.item)
        }
        return [dragItem]
    }
}

// Drop相关
extension ViewController : UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIColor.self)
    }
    
    // 决定从不同地方拖到不同地方的时候应该怎样处理
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        // 从下到上，copy
        if collectionView === self.colorDropCollectionView && !collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
        }
        // 从上到下，move
        else if collectionView === self.colorDragCollectionView && !collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
        }
        // 不允许其它情况
        else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    // 决定move和copy的情况分别要做什么
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        }
        else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection:section)
            destinationIndexPath = IndexPath(row:row, section:section)
        }
        
        switch coordinator.proposal.operation {
            case .copy:
                self.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
                sourceIndice = [Int]()
                break
            case .move:
                self.removeItem(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
                break
            default:
                sourceIndice = [Int]()
                return
        }
    }
}
