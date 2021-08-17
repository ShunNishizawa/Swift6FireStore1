//
//  LoginViewController.swift
//  Swift6FireStore1
//
//  Created by 西澤駿 on 2021/05/20.
//

import UIKit
import FirebaseAuth //ログインをつかさどるライブラリ

class LoginViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func login(){
        Auth.auth().signInAnonymously { (result, error) in
            let user = result?.user
            print(user)
            
            UserDefaults.standard.set(self.textField.text, forKey: "userName")
            
            //画面遷移
            let  viewVC = self.storyboard?.instantiateViewController(identifier: "viewVC") as! ViewController
            self.navigationController?.pushViewController(viewVC, animated: true)
        }
    }

    @IBAction func done(_ sender: Any) {
        login()
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
