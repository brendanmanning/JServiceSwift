//
//  JService.swift
//
//  Created by Brendan Manning on 9/24/17.
//  Copyright © 2017 BrendanManning. 
//  Released under the MIT License
//
//  github.com/brendanmanning/JServiceSwift
//

import Foundation
import SwiftyJSON

class JService: NSObject {
    
    /**
     * jService.io api endpoint constant
     */
    private let endpoint = "http://jservice.io/api/";
    
    /**
     * Shared instance of JService
     */
    static let sharedService = JService();
    
    /**
     * Create a new instance of JService
     * This should never be called by the programmer because the
     * singleton pattern elimiates its need
     */
    override init() {}
    
    /**
     * Get up to 100 Jeopardy categories
     * @param count The number of categories to return
     * @param callback A callback which recieves an array of categories fetched
     */
    public func categories( count: Int , offset: Int, callback: (_: [JCategory]) -> Void ) {
        
        var jcategories = [JCategory]()
        
        if count > 100 {
            callback(jcategories);
            return;
        }
        
        var joffset = offset;
        if joffset < 0 {
            
            // By checking /api/categories&offset=18000&count=100, you will see that is about as far as you can pagate
            // If we adjust this approximate maximum page length for whatever count is passed in, a random page can be fairly
            // safely selected.
            joffset = Int(arc4random_uniform(UInt32(150000/count))) + 1;
        }
        
        // The API endpoint for this action is: /api/categories?count={count}
        if let downloadedCategories = self.json(url: endpoint + "categories?count=" + String(count) + "&offset=" + String(joffset)) {
            if let downloadedCategoriesArray = downloadedCategories.array {
                for category in downloadedCategoriesArray {
                    jcategories.append(JCategory(id: category["id"].intValue, title: category["title"].stringValue, clues: category["clues"].intValue));
                }
            }
        }
        
        callback(jcategories);
        return;
    }
    
    /**
     * Get all the clues for a given category
     * @param categoryId The jService.io category id for which to get clues for
     * @param callback A callback which recieves an array of clues for the category
     */
    public func clues( categoryId: Int , callback: (_: [JClue]) -> Void ) {
        
        var jclues = [JClue]();
        
        if categoryId < 0 {
            callback(jclues);
            return;
        }
        
        // The API endpoint for a category (which contains an array of questions) is /api/category?id={id}
        if let downloadedCategory = self.json(url: endpoint + "category?id=" + String(categoryId)) {
            if let downloadedCluesArray = downloadedCategory["clues"].array {
                for clue in downloadedCluesArray {
                    jclues.append(JClue(id: clue["id"].intValue, categoryId: categoryId, value: clue["value"].intValue, question: clue["question"].stringValue, answer: clue["answer"].stringValue));
                }
            }
        }
        
        callback(jclues);
        return;
    }
    
    /**
     * Gets up to 100 random clues
     * @param callback A callback which recieves an array of random clues
     */
    public func random( count: Int , callback: (_: [JClue]) -> Void ) {
        
        var jrandomclues = [JClue]();
        
        if count > 100 {
            callback(jrandomclues);
            return;
        }
        
        // The API endpoint for random clues is /api/random?count={count}
        if let downloadedRandomClues = self.json(url: endpoint + "random?count=" + String(count)) {
            if let downloadedRandomCluesArray = downloadedRandomClues["clues"].array {
                for clue in downloadedRandomCluesArray {
                    jrandomclues.append(JClue(id: clue["id"].intValue, categoryId: clue["category_id"].intValue, value: clue["value"].intValue, question: clue["question"].stringValue, answer: clue["answer"].stringValue));
                }
            }
        }
        
        callback(jrandomclues);
        return;
    }
    
    /**
     * Utility method for downloading a URL and converting it's json to a SwiftyJSON parseable object
     * @param url URL for a JSON endpoint
     * @returns A SwiftyJSON object or nil if an error occurs
     */
    private func json( url: String ) -> JSON? {
        
        print("Downloading " + url);
        
        if let jsonUrl = URL(string: url) {
            do {
                let data = try Data(contentsOf: jsonUrl);
                let json = JSON(data: data);
                return json;
            } catch {}
        }
        return nil;
        
    }
}

class JCategory: NSObject {
    
    /**
     * The category's unique id, which comes from jService.io
     */
    public let id:Int;
    
    /**
     * The category's title
     */
    public let title:String;
    
    /**
     * How many clues are available for this category
     */
    public let clues:Int;
    
    /**
     * Create a new instance of the categoryy class
     */
    init( id: Int, title:String, clues:Int ) {
        self.id = id;
        self.title = title;
        self.clues = clues;
    }
}

class JClue: NSObject {
    
    /**
     * The clue's unique id, which comes from jService.io
     */
    public let id:Int;
    
    /**
     * The id for the category the clue belongs
     */
    public let categoryId:Int;
    
    /**
     * The value the clue was worth on Jeopardy
     */
    public let value:Int;
    
    /**
     * The question
     */
    public let question:String;
    
    /**
     * The answer
     */
    public let answer:String;
    
    /**
     * Constructor for objects of the JClue class
     */
    init( id: Int, categoryId: Int, value: Int, question: String, answer: String ) {
        self.id = id;
        self.categoryId = categoryId;
        self.value = value;
        self.question = question;
        self.answer = answer;
    }
