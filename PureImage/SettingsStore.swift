//
//  SettingsStore.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/12/4.
//

import Foundation
import SwiftUI

let settingsMinImageSizeUpdated: Notification.Name = Notification.Name("settingsNewValueUpdated")
let settingsPageBtnLeftUpdated: Notification.Name = Notification.Name("settingsPageBtnLeftUpdated")

let imageSize1KB: CGFloat = 1 * 1024

class SettingStore {
    enum StoreKey {
        static let minImageSize: String = "SettingStore_minImageSize"
        static let nextPageName: String = "SettingStore_nextPageName"
        static let lastPageName: String = "SettingStore_lastPageName"
        static let useReferer: String = "SettingStore_useReferer"
        static let minImageCount: String = "SettingStore_minImageCount"
        static let pageBtnLeft: String = "SettingStore_pageBtnLeft"
    }
        
    static let shared = SettingStore()
    
    var floatImageSize: CGFloat {
        let minImageSize = CGFloat(Int(SettingStore.shared.minImageSize) ?? 200)
        return minImageSize * imageSize1KB
    }
    
    var minImageSize: String {
        get {
            UserDefaults.standard.string(forKey: StoreKey.minImageSize) ?? "200"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.minImageSize)
            NotificationCenter.default.post(name: settingsMinImageSizeUpdated, object: nil)
        }
    }
    var nextPageName: String {
        get {
            UserDefaults.standard.string(forKey: StoreKey.nextPageName) ?? "下一页"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.nextPageName)
        }
    }
    var lastPageName: String {
        get {
            UserDefaults.standard.string(forKey: StoreKey.lastPageName) ?? "上一页"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.lastPageName)
        }
    }
    var useReferer: Bool {
        get {
            UserDefaults.standard.bool(forKey: StoreKey.useReferer)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.useReferer)
        }
    }
    var minImageCount: Int {
        get {
            UserDefaults.standard.integer(forKey: StoreKey.minImageCount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.minImageCount)
        }
    }
    var pageBtnLeft: Bool {
        get {
            UserDefaults.standard.bool(forKey: StoreKey.pageBtnLeft)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StoreKey.pageBtnLeft)
            NotificationCenter.default.post(name: settingsPageBtnLeftUpdated, object: nil)
        }
    }
}
