//
//  SQLiteManager.swift
//  SqLite
//
//  Created by mc on 2019/9/8.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SQLite3

class SQLiteManager: NSObject {
    private static let manager:SQLiteManager = SQLiteManager()
    
    class func shardManager()->SQLiteManager {
        return manager
    }
    
    //MARK:-- 了解事务概念
    /**
     开始事务 -》备份数据库
     提交事务 - > 删除备份
     回滚 - > 用备份还原数据
     */
    // 开始事务 -》备份数据库
    
    func beginTransaction(){
         execSQL(sql: "BEGIN TRANSACTION")
    }
    //提交事务 - > 删除备份
    func commitTransaction(){
         execSQL(sql: "COMMIT TRANSACTION")
    }
    
    //回滚 - > 用备份还原数据
    func rollbackTransaction(){
        execSQL(sql: "ROLLBACK TRANSACTION")
    }
    
    //创建一个串行队列
    /**
     
     
     label 表示队列标签
     
     qos 表示设置队列的优先级
     .userInteractive 需要用户交互的，优先级最高，和主线程一样
     .userInitiated 即将需要，用户期望优先级，优先级高比较高
     .default 默认优先级
     .utility 需要执行一段时间后，再通知用户，优先级低
     *.background 后台执行的，优先级比较低
     *.unspecified 不指定优先级，最低
     
     attributes 表示队列类型，默认为串行队列，设置为.concurrent表示并行队列。iOS 10.0之后 attributes 新增.initiallyInactive属性表示当前队列是不活跃的，它需要调用DispatchQueue的activate方法来执行任务。
     
     autoreleaseFrequency 表示自动释放频率，设置自动释放机制。
     .inherit 表示不确定，之前默认的行为也是现在的默认值
     .workItem 表示为每个执行的项目创建和排除自动释放池, 项目完成时清理临时对象
     .never 表示GCD不为您管理自动释放池

     */
    
 let dbQueue = DispatchQueue(label: "com.custom.thread", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    func execQueueSQL(action:@escaping (_ manage:SQLiteManager)->()){
        dbQueue.async {
            action(self)
        }
    }
    
    
    private var db:OpaquePointer? = nil
    //打开数据库
    func openDB(SQLiteName:String){
        //拿到数据j库文件路径
        let path = SQLiteName.docDir()
        print(path)
        let cPath = path.cString(using: String.Encoding.utf8);
        
        if sqlite3_open(cPath, &db) != SQLITE_OK
        {
          print("打开数据失败")
            return
        }
        if creatTable(){
             print("创建表成功")
        }else{
             print("创建表失败")
        }
        
        
        
    }
    //创建表
    func creatTable()->Bool{
        let sql = "CREATE TABLE IF NOT EXISTS T_Person("
        + "id integer PRIMARY KEY AUTOINCREMENT," +
        "name text NOT NULL," +
            "age integer DEFAULT 10" + ");"
        
    
        return execSQL(sql: sql)
        
    }
    //执行sql语句，删除，插入，更新
    func execSQL(sql:String) -> Bool{
        
        if sqlite3_exec(db, sql.cString(using: String.Encoding.utf8)!, nil, nil, nil) != SQLITE_OK {
            return false
        }else{
            return true
        }
        
    }
    ////执行sql语句 查询
    
    func execRocorSql(sql:String)->[[String:Any]]?
    {
        let cSQL = sql.cString(using: String.Encoding.utf8)!
      
        //先准备
        var stmt:OpaquePointer? = nil
        var records = [[String:Any]]()
        if sqlite3_prepare_v2(db, cSQL, -1, &stmt, nil) != SQLITE_OK {
            print("准备失败")
            return nil;
        }
         else{
              //查询数据 一条一条的拿
            while sqlite3_step(stmt) == SQLITE_ROW {
               let count = sqlite3_column_count(stmt)
                var record = [String:Any]()
                //print(count)
                //拿到每一列的名称
                for index in 0..<count{
                    
                   
                   let cname = sqlite3_column_name(stmt, index)
                   let name = String(cString:cname!, encoding: String.Encoding.utf8)!
                    //print(name)
                    //获取类型
                    let type = sqlite3_column_type(stmt, index)
                    switch type {
                    case SQLITE_INTEGER:
                        //整形
                        let num = sqlite3_column_int64(stmt, index)
                        //print(num)
                        record[name] = num
                        break;
                      case SQLITE_FLOAT:
                         //浮点型
                        let double = sqlite3_column_double(stmt, index)
                        record[name] = double
                        break
                    case SQLITE3_TEXT:
                        let ctext:UnsafePointer<UInt8> = sqlite3_column_text(stmt, index)!
                       
                        let text =  String(cString: ctext)
                        record[name] = text
                       // print(text)
                        break
                    case SQLITE_NULL:
                        record[name] = NSNull()
                        break
                        
                    default:
                        //二进制数据
                        break
                        
                    }
                    
                }
                sqlite3_finalize(stmt)
                //print(record)
                records.append(record)
            }
        }
        return records
        
        
    }
    
    // MARK:了解预编译 l可变参数
    func bacthExecSQL(sql:String , _ args: CVarArg...){
        
        let cSQL = sql.cString(using: String.Encoding.utf8)
        
       var stmt:OpaquePointer? = nil
        
       if sqlite3_prepare_v2(db, cSQL, -1, &stmt, nil) != SQLITE_OK {
            print("编译失败")
            return
        }
        
        
        //绑定数据
        var index:Int32 = 1
        for objc in args{
            
            if objc is Int {
                sqlite3_bind_int64(stmt, index, sqlite3_int64(objc as! Int))
                
            }
            else if objc is Double {
                sqlite3_bind_double(stmt, index, objc as! Double)
                
            }
            else if objc is String {
                let text = objc as! String
                let ctext = text.cString(using: String.Encoding.utf8)
                sqlite3_bind_text(stmt, index, ctext, -1) { (e:UnsafeMutableRawPointer?) in
                    e?.advanced(by: -1)
                    }
                //sqlite3_bind_text(stmt, index, ctext, -1, )
            }
            index = index + 1
        }
        
       if sqlite3_step(stmt) != SQLITE_DONE {
           print("执行失败")
        }
        if sqlite3_reset(stmt) != SQLITE_OK{
            print("重置失败")
        }
        
        //关闭
        sqlite3_finalize(stmt)
        
       
        
    }
    
    

}
