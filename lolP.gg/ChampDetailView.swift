//
//  ChampDetailView.swift
//  lolP.gg
//
//  Created by 강대민 on 2022/01/11.
//

import Foundation
import UIKit

public class ChampDetailView : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var DetailTableView: UITableView!
    @IBOutlet var detailImg: UIImageView! //VC의 챔피언 이미지
    @IBOutlet var detailName: UILabel! //VC의 챔피언 이름

    public var VCImg : String? //viewcontroller에서 넘겨받은 챔피언 썸네일
    public var VCName : String? //vc에서 넘겨받은 챔피언 이름

    var skillName = [String]()
    var skillDesc = [String]()
    var skillImg = [String]()
    
    var urlString = "url정보담을 변수"
    //"https://ddragon.leagueoflegends.com/cdn/11.23.1/data/ko_KR/champion/\(self.detailErName).json"
    //let urlString = "https://ddragon.leagueoflegends.com/cdn/11.23.1/data/ko_KR/champion/Aatrox.json"

    public override func viewDidLoad() {
        super.viewDidLoad()
    
        if let vcname = VCName {
            //본문을 보여준다.
            self.detailName.text = vcname
            print("챔프디테일에서의 vcname값 : \(vcname)")
        }
        
        if let vcimg = VCImg {
            if let data = try? Data(contentsOf: URL(string: "http://ddragon.leagueoflegends.com/cdn/11.24.1/img/champion/\(vcimg).png")!) {
                DispatchQueue.main.async {
                    self.detailImg.image = UIImage(data: data)
                    print("챔프디테일에서의 vcimg값 : \(vcimg)")
                    self.urlString = "https://ddragon.leagueoflegends.com/cdn/11.24.1/data/ko_KR/champion/\(vcimg).json"
                    self.getSkill()
                    print("champskill url : \(self.urlString)")
                }
            }
        }
    }
    
    func getSkill() {
 
        //챔피언의 이름을 받아서 urlString을 완성시켜야함.
        guard let url = URL(string: self.urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { [self]data, _, error in
            guard let data = data, error == nil else {
                return
            }
            var result: MainSkillData?
            do {
                result = try JSONDecoder().decode(MainSkillData.self, from: data)
                //let spell = result?.SkillData.Spell.CodingKeys.skillid
            }
            catch {
                print("Failed to decode with error: \(error)")
            }
            guard let final = result else {
                return
            }
                
//            스킬의 이름 정보 이미지 관련 데이터를 변수에 저장.
            for (_, skillnames) in final.data {
                let sub = skillnames.spells
                for loop in sub {
                    self.skillName.append(loop.skillname)
                    self.skillDesc.append(loop.spellDescription)
                    self.skillImg.append(loop.skillid)
                    print(loop.skillid)
                    print(loop.skillname)
                    print(loop.spellDescription)
                }
                print("스킬의 개수 : \(self.skillName.count)")
            }
 
//            메인에서 일을 시킴. reloadData를 사용하기 떄문에 맨 마지막에 사용
            DispatchQueue.main.async {
                self.DetailTableView.reloadData()
            }
                                              
        })
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //스킬수만큼 카운트
        return skillName.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableView.dequeueReusableCell(withIdentifier: "champSkill", for: indexPath) as! ChampSkill
                
        //스킬이름
        cell.skillName.text = skillName[indexPath.row]
        //스킬설명
        cell.skillDesc.text = skillDesc[indexPath.row]
        //스킬이미지
        // 섬네일 경로를 인자값으로 하는 URL객체를 생성
        let url: URL! = URL(string: "https://ddragon.leagueoflegends.com/cdn/11.24.1/img/spell/\(skillImg[indexPath.row]).png")
        // 이미지를 읽어와 Data객체에 저장
        let imageData = try! Data(contentsOf: url)
        // UIImage객체를 생성하여 아울렛 변수의 image 속성에 대입
        cell.skillImg.image = UIImage(data: imageData)
        
        return cell
    }
}

class ChampSkill: UITableViewCell {
    @IBOutlet var skillImg: UIImageView!
    @IBOutlet var skillName: UILabel!
    @IBOutlet var skillDesc: UILabel!
}
