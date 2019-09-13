//
//  ViewController.swift
//  SqLite
//
//  Created by mc on 2019/9/8.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SQLiteManager.shardManager().openDB(SQLiteName: "liubo.sqlite")
       
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let p = Person(dict: ["name":"liubo","age":88])
//        p.insetQueuePerson()
//        p.insetPerson()
        //p.updaPerson(nameString: "zhanghua");
//        if p.delePerson(idString: "2"){
//            print("删除成功")
//        }
        // print(Person.loadPerson()!)
        
        let manage = SQLiteManager.shardManager()
//        manage.beginTransaction()
//
//        let startime = CFAbsoluteTimeGetCurrent()
//        for i in 0..<10000{
//            let p = Person(dict: ["name":"lili + \(i)","age":i])
//
//            p.insetPerson()
//
//           // p.insetQueuePerson()
//            //测试huigun
////            if i == 200 {
////                manage.rollbackTransaction()
////                break
////            }
//
//        }
//        //消耗了 = 0.17585599422454834
//        manage.commitTransaction()
//       //不加事务消耗了 = 8.53604006767273
//        print("消耗了 = \(CFAbsoluteTimeGetCurrent() - startime)")
        
         let sql = "INSERT INTO T_Person(name,age) VALUES (?,?);"
        
        manage.bacthExecSQL(sql: sql,"lihui",60)
    }


}

