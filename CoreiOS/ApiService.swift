//
//  ApiService.swif.swift
//  CoreiOS
//
//  Created by Albin CR on 11/11/16.
//  Copyright © 2016 Albin CR. All rights reserved.
//

//TODO:- On hold -
//collection, //login, // details




import Foundation

// This is where API is defined
public class ApiService{
    
    //MARK: - Calling Http shared inatance
    let api = Http.sharedInstance
    let defaults = UserDefaults.standard
    
    //MARK: - Accesing base url from Constants file
    private var baseUrl:String {
        get {
            return Constants.urlConfig.getBaseUrl()
        }
    }
    
    //MARK: - Default initilizer
    public init(){}
    
 
    
    
    var saveToDisk:Bool = false
    var cacheTime:Int?
    var cacheStatus:Bool = true
    var replaceWithNewData = false
    

    
    //MARK: - Api calling wrapper for reuseing the call (Common Call for all get Calls)
    func apiCall(apiCallName:String,method:String,url:String,parameter:[String:AnyObject]?,cacheStatus:Bool,cacheTime:Int,saveToDisk:Bool,retuenData:Bool = true,completion:@escaping (String?,Any?)->()) {
        api.call(method: method, urlString: url, parameter: parameter) { (status,error,data) in
            if !status{
                if let errorMessage = error{
                    completion(errorMessage,nil)
                }
            }else{
                
                if cacheStatus{
                    Cache.cacheData(data: data as Any, key: apiCallName, cacheTimeInMinute: cacheTime,saveToDisk:saveToDisk)
                    completion(nil,data)
                }else{
                    completion(nil,data)
                }
                
            }
        }
    }
    
    
    
    
    
    //MARK:- Get publisher details -
    public func getPublisherConfig(cache:cacheOption,completion:@escaping (String?,Config?)->()) {
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0]
        //print(apiCallName)
        
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.configUrl
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: nil, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.configParser(data: data as! [String : AnyObject]?, completion: { (configObject) in
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil, configObject)
                        }
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.configParser(data: data as! [String : AnyObject]?, completion: { (configObject) in
                    DispatchQueue.main.async {
                        completion(nil, configObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
    }
    
    //MARK: - Get stories -
    public func getStories(options:storiesOption,fields: [String]?,offset: Int?,limit: Int?,storyGroup: String?,cache:cacheOption,completion:@escaping (String?,[Story]?)->()) {
        
        let stringURLFields = fields?.joined(separator: ",").replacingOccurrences(of: ",", with: "%2C")
        
        
        var param:[String:Any?] = [
            
            "fields":stringURLFields,
            "offset":offset,
            "limit":limit,
            "story-group":storyGroup
        ]
        
        if let opt = options.value{
            
            if !opt.isEmpty{
                
                for (index,options) in opt{
                    param[index] = options
                }
                
            }
        }
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + param.description.replacingOccurrences(of: "-", with: "_")
        ////print(apiCallName)
        
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.getStories
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: param as [String : AnyObject]?, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?, completion: { (storiesObject) in
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,storiesObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?, completion: { (storiesObject) in
                    
                    DispatchQueue.main.async {
                        completion(nil,storiesObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
    }
    
    
    //MARK:- Get story by id
    public func getStoryFromId(storyId: String,cache:cacheOption,completion:@escaping (String?,Story?)->()) {
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + storyId
        ////print(apiCallName)
        
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.getStories + "/" + storyId
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: nil, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.storyParser(data: data as! [String : AnyObject]?, completion: { (storyObject) in
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,storyObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.storyParser(data: data as! [String : AnyObject]?, completion: { (storyObject) in
                    
                    DispatchQueue.main.async {
                        completion(nil,storyObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
        
        
    }
    
    //MARK:- Get realted story
    public func getRelatedStories(storyId: String,SectionId:String?,fields: [String]?,cache:cacheOption,completion:@escaping (String?,[Story]?)->()) {
        
        
        let stringURLFields = fields?.joined(separator: ",").replacingOccurrences(of: ",", with: "%2C")
        
        var param:[String:Any?] = [
            
            "fields":stringURLFields,
            "section-id":SectionId
            
        ]
        
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + storyId + param.description.replacingOccurrences(of: "-", with: "_")
        ////print(apiCallName)
        
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.relatedStories(storyId: storyId)
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: param as [String : AnyObject]?, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?,parseKey:"related-stories",completion: { (storiesObject) in
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,storiesObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?,parseKey:"related-stories",completion: { (storiesObject) in
                    
                    DispatchQueue.main.async {
                        completion(nil,storiesObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
        
    }
    
    //MARK:- Search
    public func search(searchBy:searchOption,fields: [String]?,offset:Int?,limit:Int?,cache:cacheOption,completion:@escaping (String?,Search?)->()) {
        
        
        let stringURLFields = fields?.joined(separator: ",").replacingOccurrences(of: ",", with: "%2C")
        var searchKey:String = ""
        
        var param:[String:Any?] = [
            
            "fields":stringURLFields,
            "offset":offset,
            "limit":limit,
            ]
        
        if let opt = searchBy.value{
            
            if opt.isEmpty{
                
                param[opt.first!.key] = opt.first!.value
                searchKey = opt.first!.value
                
            }
        }
        
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + searchKey + param.description.replacingOccurrences(of: "-", with: "_")
        ////print(apiCallName)
        
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.search
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: nil, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.searchParser(data: data as! [String : AnyObject]?, completion: { (searchObject) in
                    
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,searchObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.searchParser(data: data as! [String : AnyObject]?, completion: { (searchObject) in
                    
                    
                    DispatchQueue.main.async {
                        completion(nil,searchObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
        
    }
    
    //MARK:- Get comments of a particular story
    public func getCommentsForStory(storyId:String,cache:cacheOption,completion:@escaping (String?,[Comment]?)->()) {
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + storyId
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.getComments(storyId: storyId)
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: nil, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.commentsParser(data: data as! [String : AnyObject]?,completion: { (commentObject) in
                    
                    
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,commentObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.commentsParser(data: data as! [String : AnyObject]?,completion: { (commentObject) in
                    
                    DispatchQueue.main.async {
                        completion(nil,commentObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
    }
    
    //MARK:- Get story form slug
    public func getStoryFromSlug(slug: String,cache:cacheOption,completion:@escaping (String?,Story?)->()) {
        
        let urlSlug = slug.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        var param:[String:Any?] = ["slug":urlSlug]
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + slug
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.getStoryFromSlug
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: param as [String : AnyObject]?, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.storyParser(data: data as! [String : AnyObject]?,completion: { (storyObject) in
                    
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,storyObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.storyParser(data: data as! [String : AnyObject]?,completion: { (storyObject) in
                    
                    
                    DispatchQueue.main.async {
                        completion(nil,storyObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
    }
    
    //MARK:- Get breaking news
    public func getBreakingNews(fields:[String]?,limit:Int?,offset:Int?,cache:cacheOption,completion:@escaping (String?,[Story]?)->()) {
        
        
        let stringURLFields = fields?.joined(separator: ",").replacingOccurrences(of: ",", with: "%2C")
        
        var param:[String:Any?] = [
            
            "fields":stringURLFields,
            "offset":offset,
            "limit":limit,
            ]
        
        let apiCallName = "\(#function)".components(separatedBy: "(")[0] + param.description.replacingOccurrences(of: "-", with: "_")
        if let opt = cache.value{
            if opt.keys.first == Constants.cache.cacheToMemoryWithTime{
                saveToDisk = false
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.cacheToMemoryAndDiskWithTime{
                saveToDisk = true
                cacheTime = opt.values.first
            }else if opt.keys.first == Constants.cache.loadOldCacheAndReplaceWithNew{
                replaceWithNewData = true
                cacheTime = opt.values.first
                saveToDisk = true
            }
            
        }else{
            cacheStatus = false
        }
        
        let url = baseUrl + Constants.urlConfig.breakingNews
        
        func requestCall(retuenData:Bool = true){
            
            self.apiCall(apiCallName:apiCallName,method:"get",url: url, parameter: param as [String : AnyObject]?, cacheStatus: cacheStatus, cacheTime: cacheTime!, saveToDisk: saveToDisk, completion: { (error, data) in
                
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?, completion: { (storiesObject) in
                    
                    if retuenData{
                        DispatchQueue.main.async {
                            completion(nil,storiesObject)
                        }
                    }else{
                        ////print("data not returned")
                    }
                })
                
            })
            
        }
        
        Cache.retriveCacheData(keyName: apiCallName, completion: { (data) in
            
            if data != nil {
                ApiParser.StoriesParser(data: data as! [String : AnyObject]?, completion: { (storiesObject) in
                    
                    
                    DispatchQueue.main.async {
                        completion(nil,storiesObject)
                    }
                    
                    if self.replaceWithNewData{
                        requestCall(retuenData: false)
                    }
                })
                
            }else{
                requestCall()
            }
        })
    }
    
    //MARK: Facebook Token Sender
    
    public func facebookTokenLogin(facebookToken:String,complete:@escaping (Bool)->()){
        
        let parameter: [String: Any] = [
            "token": [
                "access-token": facebookToken
            ]
        ]
        print(parameter)
        let url = baseUrl + Constants.urlConfig.facebookLogin
        
        
        api.call(method: "post", urlString: url, parameter: parameter as [String : AnyObject]?) { (status, error, data) in
            
            print(status, error, data)
            
            if !status{
                if let errorMessage = error{
                    complete(false)
                }
            }else{
                complete(true)
                
            }
            
        }
        
        
    }
    //MARK: - Facebook logout -
    public func logoutFacebook(){
        
        defaults.remove(Constants.login.auth)
        
    }
    
    
    //MARK: -POST Commants
    //TODO: -Need testing
    
    public func postComment(comment:String?,storyId:Int){
        
        let param:[String:Any?] = [
            
            "story-content-id":storyId,
            "text":comment,
            
            ]
        
        api.call(method: "post", urlString: Constants.urlConfig.postComment, parameter: param as [String : AnyObject]?){ (status,error,data) in
            
            print(data)
            
        }
    }
    
    public func getCurrentUser(storyId:Int,complete:@escaping (Bool)->()){
        
        api.call(method: "get", urlString: Constants.urlConfig.getCurrentUser, parameter: nil){ (status,error,data) in
            
            print(data)
            complete(true)
            
            
        }
    }
    
    public func getAuthor(autherId:String,complete:@escaping (Bool)->()){
        
        
        api.call(method: "get", urlString: Constants.urlConfig.GetAuthor + "/\(autherId)", parameter: nil){ (status,error,data) in
            
            print(data)
            complete(true)
            
        }
        
    }
    
    
    
}
