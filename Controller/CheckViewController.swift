//
//  CheckViewController.swift
//  Swift6FireStore1
//
//  Created by 西澤駿 on 2021/05/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class CheckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var odaiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var odaiString = String()
    let db = Firestore.firestore()
    var dataSets: [AnswersModel] = [] // = var dataSets = [AnswersModel]()
    var idString = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        odaiLabel.text = odaiString
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 //セクションの数が１
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        tableView.rowHeight = 200
        
        cell.answerLabel.numberOfLines = 0
        cell.answerLabel.text = "\(self.dataSets[indexPath.row].userName)君の回答\n\(self.dataSets[indexPath.row].answers)"
        cell.likeButton.tag = indexPath.row
        cell.countLabel.text = String(self.dataSets[indexPath.row].likeCount) + "いいね"
        cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        
        if (self.dataSets[indexPath.row].likeFlagDic[idString] != nil) == true{
            let flag = self.dataSets[indexPath.row].likeFlagDic[idString]
            
            if flag as! Bool == true{
                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "nolike"), for: .normal)
            }
        }
        
        //let answerLabel = cell.contentView.viewWithTag(1) as! UILabel
//        answerLabel.numberOfLines = 0 //ラベルの高さに応じてセルが反応する
//        answerLabel.text = "\(self.dataSets[indexPath.row].userName)君の回答\n\(self.dataSets[indexPath.row].answers)"
        
        return cell
    }
    
    @objc func like(_ sender: UIButton){
        
        //値を送信
        var count = Int()
        let flag = self.dataSets[sender.tag].likeFlagDic[idString]
        
        if flag == nil{
            count = self.dataSets[sender.tag].likeCount + 1
            db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString: true]], merge: true) //merge->他の人のいいねを打ち消してしまうため必要となる
            
        }else{
            if flag! as! Bool == true{
                count = self.dataSets[sender.tag].likeCount - 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString: false]], merge: true)
            }else{
                count = self.dataSets[sender.tag].likeCount + 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString: true]], merge: true)
            }
        }
        db.collection("Answers").document(dataSets[sender.tag].docID).updateData(["like" : count], completion: nil)
        tableView.reloadData()
        print(sender.debugDescription)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移
        let commentVC = self.storyboard?.instantiateViewController(identifier: "commentVC") as! CommentViewController
        
        commentVC.idString = dataSets[indexPath.row].docID
        commentVC.kaitouString = "\(self.dataSets[indexPath.row].userName)君の回答\n\(self.dataSets[indexPath.row].answers)"
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func loadData(){
        //Answersのドキュメントたちを引っ張ってくる→PostDateを投稿したものが下に来る
        db.collection("Answers").order(by: "postDate").addSnapshotListener { [self] (snapShot, error) in
            
            self.dataSets = []
            
            if error != nil{
                return
            }
            
            //if let snapShotDoc = snapShot?.documents{
                
                db.collection("Answer").order(by: "postDate").addSnapshotListener { (snapShot, error) in
                    self.dataSets = []
                    if error != nil{
                        return
                    }
                }
                
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        if let answer = data["answer"] as? String, let userName = data["userName"] as? String, let likeCount = data["like"] as? Int, let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>{
                           
                            if likeFlagDic["\(doc.documentID)"] != nil{
                                let answerModel = AnswersModel(answers: answer, userName: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic)
                                self.dataSets.append(answerModel)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                //}
                
                
//                for doc in snapShotDoc{
//                    let data = doc.data()
//                    if let answer = data["answer"] as? String, let userName = data["userName"] as? String{
//
//                        let answerModel = AnswersModel(answers: answer, userName: userName, docID: doc.documentID)
//                        self.dataSets.append(answerModel)
//                    }
//                }
                //self.dataSets.reverse()
            }
        }
        //dataSetsに入れるAnswersModel型として
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
