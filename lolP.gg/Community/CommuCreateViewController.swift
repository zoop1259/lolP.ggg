//
//  CommuCreateViewController.swift
//  lolP.gg
//
//  Created by 강대민 on 2022/02/15.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Toast_Swift

class CommuCreateViewController : UIViewController, UITextViewDelegate {
    
    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var textLabel: UITextView!
    
    var ref: DatabaseReference!
    //닉네임설정을 안한자를 위한..
    var fbusernickName: String = "별명이없는자"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        placeholderSetting()
    }
    
    //UILabel Placeholder
    func placeholderSetting() {
        textLabel.delegate = self
        textLabel.text = "내용을 입력해주세요."
        textLabel.textColor = UIColor.lightGray
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 제대로 입력해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func addBtn(_ sender: Any) {
        
        //로그인정보부터 불러오기.
        guard let user = Auth.auth().currentUser else { return }
        
        //작성날짜 구하기 위해서.
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        let writedateString = formatter.string(from: Date())
        print(writedateString)
        
        //board다음에 autoid를 넣는것.
        guard let keyValue = ref.child("board").childByAutoId().key else { return }
        guard let text = self.textLabel.text, !text.isEmpty,
              let title = self.titleLabel.text, !title.isEmpty else {
                  self.view.makeToast("모든 내용을 작성해주세요.", duration: 1.0, position: .center)
                  return
              }
        //닉네임 가져오기.
        ref.child("users").observeSingleEvent(of: .value, andPreviousSiblingKeyWith: {
            (snapshot, error) in
            let nicknames = snapshot.value as? [String: Any] ?? [:]
            //닉네임가져오기
            if let nickkey = nicknames[user.uid] as? [String:Any] {
                //let getnick = nickkey.values
                if let getnick = nickkey["nickName"] as? String {
                    print(getnick)
                    self.fbusernickName = getnick
                }
            }
        })
        //게시글 등록!
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            //데이터 저장.
            self.ref.child("board").child("create").child(keyValue).setValue([
                "title" : self.titleLabel.text as Any,
                "text" : self.textLabel.text as Any,
                "recordTime" : ServerValue.timestamp(),
                "uid" : user.uid,
                "nickName" : self.fbusernickName,
                "writeDate" : writedateString,
                "keyValue" : keyValue,
                "commentCount" : 0
                                                        ])
        }
        //화면 pop
        navigationController?.popViewController(animated: true)
    }
}