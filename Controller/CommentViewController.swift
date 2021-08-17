//
//  CommentViewController.swift
//  Swift6FireStore1
//
//  Created by 西澤駿 on 2021/05/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kaitouLabel: UILabel!
    //キーボードが上がった分テキストフィールドと送信ボタンを上にあげるために必要
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var userName = String()
    var idString = String()
    var kaitouString = String()
    var db = Firestore.firestore()
    var dataSets = [CommentModel]()
    let screenSize = UIScreen.main.bounds.size

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        kaitouLabel.text = kaitouString
        
        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        //テキストフィールドをセルの高さ分変更する
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        textField.frame.origin.y = screenSize.height - keyboardHeight - textField.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        
        textField.frame.origin.y = screenSize.height - textField.frame.height
        
        sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
        
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}
        
        
        UIView.animate(withDuration: duration) {
            
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        loadData()
    }
    
    func loadData() {
        db.collection("Answers").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.dataSets = []
            
            if error != nil{
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let userName = data["userName"] as? String, let comment = data["comment"] as? String, let postDate = data["postDate"] as? Double{
                        
                        let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate)
                        
                        self.dataSets.append(commentModel)
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //TableViewに表示するセルの数を返す->データセット（回答の数分）だけセルを表示する。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        tableView.rowHeight = 200
        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(self.dataSets[indexPath.row].userName)君\n\(self.dataSets[indexPath.row].comment)"
        return cell
    }
    
    // セルの中身を設定するメソッド（必須）
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }

    @IBAction func sendAction(_ sender: Any) {
        
        if textField.text?.isEmpty == true{
            return
        }
        db.collection("Answers").document(idString).collection("comments").document().setData(["userName": userName as Any, "comment":textField.text as Any, "postDate": Date().timeIntervalSince1970])
        
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
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
