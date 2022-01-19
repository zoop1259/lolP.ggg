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
    
    var detailErName : String?
    var skillLabel : String?
    var skillimgLabel : String?
    
    var ss = [String]()
    
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
            detailErName = vcimg
            if let data = try? Data(contentsOf: URL(string: "http://ddragon.leagueoflegends.com/cdn/11.24.1/img/champion/\(vcimg).png")!) {
                DispatchQueue.main.async {
                    self.detailImg.image = UIImage(data: data)
                    print("챔프디테일에서의 vcimg값 : \(vcimg)")
                    
                    self.urlString = "https://ddragon.leagueoflegends.com/cdn/11.24.1/data/ko_KR/champion/\(vcimg).json"
                    self.getSkill()
                    print(self.urlString)
                    
                }
            }
        }
        
    }
    
    func getSkill() {
 
        //챔피언의 이름을 받아서 urlString을 완성시켜야함.
        //만 되면 좋은데...
               
        guard let url = URL(string: self.urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            var result: MainSkillData?
            do {
                result = try JSONDecoder().decode(MainSkillData.self, from: data)
            }
            catch {
                print("Failed to decode with error: \(error)")
            }
            guard let final = result else {
                return
            }
            
            var subresult: SkillData?
            do {
                subresult = try JSONDecoder().decode(SkillData.self, from: data)
            }
            catch {
                print("서브리절트에서 오류: \(error)")
            }
            guard let subfinal = subresult else {
                return
            }
            
            
            //챔피언 id와 name의 dictionary 생성.
            for (_, champnames) in final.data {
                //cDic만으론 157개를 가진 dictionary가 아니게 되어 2중for문 사용. 알아본바 map? 같은걸 사용해볼....
//                print(champnames)
//                let subdic = getskillName(skills: champnames)
//                print(subdic.count)
//                subarr.append(champnames.spells)
//                print(subarr.count) //왜 1개인가..
//                self.ss.append(champnames.spells)
                var dic = [champnames.id : champnames.spells]
//                print(dic.count)
//                print("dic key : \(dic.keys) ----value : \(dic.values)")
   
                
                /*
                for i in champnames.spells {
                    //여기서 출력하면 추가되는 과정을 출력해주는건가.. ss가 [Any]일때 가능하지만...
                    self.ss.append(i)
                }
                print(self.ss.count)
                */
                
                
                 
//                let ss = getskillInfo(infos: champnames.name)
//                for (_, subdatas) in champnames.spells {
//
//                }
                
                
//                for (names , ids) in cDic {
//                    dict.updateValue(names, forKey: ids)
////                    self.champsInfo = dict
//                    self.champsInfo.updateValue(names, forKey: ids)
//                }
            }
            
            
//            print(final.data)
            
//            for data in final.data {
//                print()
//                for subdata in data.spells {
//                    let content = subdata.content.joined(separator: "\n\t")
//                    print("""
//                        \(subdata.name) - \(subdata.description)
//                        \(content)
//
//                    """)
//                }
//            }
 
//            메인에서 일을 시킴. reloadData를 사용하기 떄문에 맨 마지막에 사용
            DispatchQueue.main.async {
                self.DetailTableView.reloadData()
            }
                                              
        })
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //스킬수만큼 카운트 패시브까지 한다면 패시브를 +
        return ss.count
    }
//
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableView.dequeueReusableCell(withIdentifier: "champSkill", for: indexPath) as! ChampSkill
        //스킬이름
//        cell.skillName.text = ss[indexPath.row]
        //스킬이미지
//        cell.skillImg.image = ''''
        return cell
    }
    
}

class ChampSkill: UITableViewCell {
    
    @IBOutlet var skillImg: UIImageView!
    @IBOutlet var skillName: UILabel!
    
}
