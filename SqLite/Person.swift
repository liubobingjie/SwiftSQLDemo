//
//  Person.swift
//  SqLite
//
//  Created by mc on 2019/9/8.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class Person: NSObject {
   @objc var id:Int = 0
    @objc var age:Int = 0
     @objc var name:String?
    
    //执行数据库的操作
   public func insetPerson() -> Bool {
        assert(name != nil, "必须设置name")
        let sql = "INSERT INTO T_Person(name,age) VALUES ('\(name!)',\(age));"
        
        return SQLiteManager.shardManager().execSQL(sql: sql);
    }
    
    public func insetQueuePerson(){
        var successTag:Bool = false
        SQLiteManager.shardManager().execQueueSQL { (manage:SQLiteManager) in
            assert(self.name != nil, "必须设置name")
            let sql = "INSERT INTO T_Person(name,age) VALUES ('\(self.name!)',\(self.age));"
            
          successTag = manage.execSQL(sql: sql);
            if successTag {
                print("插入成功")
            }else{
                print("插入失败")
            }
           
        }
       
        
        
    }
    
    func updaPerson(nameString:String)->Bool{
        let sql = "UPDATE T_Person SET name = '\(nameString)' WHERE id = 1 ;"
        
        return SQLiteManager.shardManager().execSQL(sql:sql)
    }
    func delePerson(idString:String)->Bool{
        let sql = "DELETE FROM T_Person WHERE id = \(idString);"
        return SQLiteManager.shardManager().execSQL(sql: sql)
    }
   class func loadPerson() ->[Person]?{
        let sql = "SELECT * FROM T_Person;"
       let res = SQLiteManager.shardManager().execRocorSql(sql: sql)
    var model = [Person]()
    if res == nil {
      print("查询为空")
       return nil
    }else{
        for dict in res! {
            model.append(Person(dict: dict))
            
        }
    }
   
     return model
    }
    
    init(dict:[String:Any]){
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    override var description: String{
        return "id = \(id),age = \(age),name = \(name)"
    }

}
