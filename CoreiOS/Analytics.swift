//
//  Analytics.swift
//  CoreiOS
//
//  Created by Albin CR on 12/19/16.
//  Copyright © 2016 Albin CR. All rights reserved.
//

import Foundation

public class Analytics{
     
    //shared instances
    let api = Http.sharedInstance
    let object = Quintype.sharedInstance
    let defaults = UserDefaults.standard
    
    var sessionId:String?
    var deviceId:String?
    var publisherId:Int?
    var memberId: Int?
    var userAgent: String?
    var software: String?
    var deviceModel: String!
    var storyVisitPageViewEventId:String?
    let deviceType:String = "iOS"
    var deviceMaker:String = "Apple"
    let deviceIsMobile:Bool = true
    var parameter:[String:Any] = [:]
    
    public init(){}
    
    func paramInit(){
        sessionId = NSUUID().uuidString
        deviceId = UIDevice.current.identifierForVendor?.description
        publisherId = Constants.publisherConfig.publisherId
        userAgent = defaults.string(forKey: Constants.publisherConfig.appNameKey)! + "iOS"
        software = "iOS - " + UIDevice.current.systemVersion.description
        deviceModel = UIDevice.current.model
        storyVisitPageViewEventId = NSUUID().uuidString
        
        parameter = [
            "session-event-id":sessionId as Any,
            "id":UUID().uuidString,
            "device-tracker-id":deviceId as Any,
            "publisher-id":publisherId as Any,
            "referrer":"",
        ]
        if Constants.user.memberId != 0{
            memberId = Constants.user.memberId
            parameter["member-id"] = memberId
        }//TODO: - Set user in user model
    }
    
    private func checkConfig(complete:@escaping ()->()){
        if (defaults.string(forKey: Constants.analyticConfig.analyticKey) != nil){
            
           paramInit()
            
            complete()
        }else{
            
            Quintype.api.getPublisherConfig(cache: cacheOption.loadOldCacheAndReplaceWithNew, Success: { (data) in
                
                Quintype.cachePublisherKeys(data: data)
                
                self.paramInit()
                
            }, Error: { (error) in
                
            })
        }
    }
    
    
    open func trackPageViewSectionVisit(section: String){//1
        checkConfig {
            self.parameter["page-type"] = pageType.section.rawValue
            self.parameter["url"] = section
            
            self.Track(eventName: eventType.viewPage.rawValue, parameter: self.parameter as [String : AnyObject])
            
        }
        
    }
    
    //MARK: - - Trackhome page visit -
    
    open func trackPageViewHomeVisit(){//2
        checkConfig {
            self.parameter["page-type"] = pageType.home.rawValue
            self.parameter["url"] = Constants.storage.getBaseUrl()
            
            self.Track(eventName: eventType.viewPage.rawValue, parameter: self.parameter as [String : AnyObject])
        }
    }
    
    //MARK: - Tracksearch results page view -
    
    open func trackPageViewSearchResults(){//3
        checkConfig {
            self.parameter["page-type"] = pageType.searchResults.rawValue
            self.parameter["url"] = ""
            
            self.Track(eventName: eventType.viewPage.rawValue, parameter: self.parameter as [String : AnyObject])
        }
    }
    
    //MARK: - Trackstory page visit -
    
    /**
     - parameter story: story instance that is visited
     */
    
    open func trackPageViewStoryVisit(story: Story){//4
        
        checkConfig {
            self.parameter["page-type"] = pageType.story.rawValue
            self.parameter["url"] = story.slug
            self.parameter["page-view-event-id"] = self.storyVisitPageViewEventId
            self.parameter["story-content-id"] = story.story_content_id
            
            self.Track(eventName: eventType.viewStory.rawValue, parameter: self.parameter as [String : AnyObject])
        }
    }
    
    //MARK: - Tracka story visit -
    
    /**
     - parameter story: story that has been visited
     */
    
    open func trackStoryVisit(story: Story){//5
        checkConfig {
            self.parameter["page-type"] = pageType.story.rawValue
            self.parameter["url"] = story.slug
            self.parameter["page-view-event-id"] = self.storyVisitPageViewEventId
            self.parameter["story-content-id"] = story.story_content_id
            
            self.Track(eventName: eventType.viewStory.rawValue, parameter: self.parameter as [String : AnyObject])
        }
    }
    
    //MARK: - Trackstory element visit -
    
    /**
     - parameter story:        story to which this story element belongs
     - parameter storyElement: story element that is visited
     */
    
    open func trackStoryElementVisit(story: Story, cardStoryElement: CardStoryElement){//6
        checkConfig {
            
            let card = self.cardForStoryElement(story: story, storyElement: cardStoryElement)
            
            self.parameter["story-content-id"] = story.story_content_id
            self.parameter["story-version-id"] = story.story_version_id
            self.self.parameter["card-content-id"] = card?.content_id
            self.parameter["card-version-id"] = card?.content_version_id
            self.parameter["story-element-id"] = cardStoryElement.id
            self.parameter["story-element-type"] = cardStoryElement.type
            self.parameter["page-view-event-id"] = self.storyVisitPageViewEventId
            
            self.Track(eventName: eventType.storyElementView.rawValue, parameter: self.parameter as [String : AnyObject])
        }
        
    }
    
    //MARK: - Trackan action on story element -
    
    /**
     - parameter story:        story to which the story element belongs to
     - parameter storyElement: story element on which action is performed
     - parameter actionTimestamp: time in millis at which action happened
     - parameter action:       action on story element
     */
    
    open func trackStoryElementAction(story: Story, cardStoryElement: CardStoryElement, actionTimestamp: Float, action: String){//7
        checkConfig {
            let card = self.cardForStoryElement(story: story, storyElement: cardStoryElement)
            
            self.parameter["story-content-id"] = story.story_content_id
            self.parameter["story-version-id"] = story.story_version_id
            self.parameter["card-content-id"] = card?.content_id
            self.parameter["card-version-id"] = card?.content_version_id
            self.parameter["story-element-id"] = cardStoryElement.id
            self.parameter["story-element-type"] = cardStoryElement.type
            self.parameter["page-view-event-id"] = self.storyVisitPageViewEventId
            self.parameter["story-element-action"] = actionTimestamp
            self.parameter["action-timestamp"] = action
            
            self.Track(eventName: eventType.storyElementView.rawValue, parameter: self.parameter as [String : AnyObject])
        }
        
    }
    
    //MARK: - Tracka content share event -
    
    /**
     - parameter story:    story which is shared
     - parameter provider: provider to which content is share
     */
    
    open func trackShare(story: Story, provider: String){//10
        checkConfig {
            self.parameter["page-view-event-id"] = self.storyVisitPageViewEventId
            self.parameter["social-media-type"] = provider
            self.parameter["story-content-id"] = story.story_content_id
            self.parameter["content-type"] = story.content_type
            self.parameter["url"] = story.slug
            self.parameter["page-type"] = pageType.story.rawValue
            
            self.Track(eventName: eventType.viewStory.rawValue, parameter: self.parameter as [String : AnyObject])
        }
    }
    
    //MARK: - Find same card inside story's cards - 🌸
    private func cardForStoryElement(story: Story, storyElement: CardStoryElement) -> Card? {
        for card in story.cards {
            for elem in card.story_elements {
                if(elem.id == storyElement.id) {
                    return card
                }
            }
        }
        return nil
    }
    
    //MARK: - Main tracker function - 😍
    private func Track(eventName:String,parameter:[String:AnyObject]){
        
        if let baseUrl = Constants.publisherConfig.analyticBaseUrl{
            
            let param:[String:Any] = [
                "event":parameter,
                "event-type":"page-view"
            ]
            api.call(method: "post", urlString: baseUrl + Constants.analyticConfig.analyticEvent, parameter: param as [String : AnyObject]?,cache:cacheOption.none, Success: { (data) in
                
            }, Error: { (error) in
                
            })
            
        }
    }
    
}
