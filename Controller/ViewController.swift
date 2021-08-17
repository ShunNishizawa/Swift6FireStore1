//
//  ViewController.swift
//  Swift6FireStore1
//
//  Created by 西澤駿 on 2021/05/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import EMAlertController
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var odaiLabel: UILabel!
    
    var idString = String()
    
    //DBの場所を指定
    let db1 = Firestore.firestore().collection("odai").document("yQiuBLhuFxatgJe7EytU") //お題を取得する
    let db2 = Firestore.firestore()
    
    var userName = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }else{
            idString = db2.collection("Answers").document().path
            print(idString)
            idString = String(idString.dropFirst(8))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }
        
        navigationController?.isNavigationBarHidden = false
        
        //ロード(odai)
        loadQuestionData()
    }
    
    func loadQuestionData(){
        db1.getDocument { (snapShot, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            //ドキュメントの中のデータを取ってくる
            let data = snapShot?.data()
            self.odaiLabel.text = data!["odaiText"] as! String
        }
        //snapShotに値が入ってくるまではここが呼ばれる
    }
    
    @IBAction func send(_ sender: Any) {
        
        db2.collection("Answers").document(idString).setData(
        
            ["answer": textView.text as Any, "userName": userName as Any, "postDate": Date().timeIntervalSince1970, "like": 0, "likeFlagDic": [idString: false]]
        )
        
        textView.text = ""
        
        //アラート表示
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "check"), title: "投稿完了！", message: "みんなの回答を見てみよう！")
        let doneAction = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)
        textView.text = ""
    }
    
    @IBAction func checkAnswer(_ sender: Any) {
        //画面遷移
        let checkVC = self.storyboard?.instantiateViewController(identifier: "checkVC") as! CheckViewController
        checkVC.odaiString = odaiLabel.text!
        self.navigationController?.pushViewController(checkVC, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "documentID")
        } catch let error as NSError {
            print("error", error)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

