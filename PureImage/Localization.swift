//
//  Localization.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/12/12.
//

import Foundation

class I18N {
    static func s(_ str: String) -> String {
        return str;
    }
    
    static func usage() -> String {
        return """
使用说明：
1. 输入 URL
2. 点击 '网页' 打开图片网址
3. 浏览到需要查看的页面，点击 '图片' 开始提取图片

设置项:
1. 设置过滤图片最小尺寸，单位是KB
2. 设置单次提取照片数量，当页图片数量不够会自动提取下一页
3. 定义目标网页的 ”上一页“ 和 ”下一页“ 的标签名称，不同的网页翻页标签可能不同
4. 图片请求是否需要授权，如果提取照片显示没有权限，则开启

点击 '重置' 清楚当前照片和网页
"""
    }
    
    static func settings_minImageSize() -> String {
        return "提取最小图片尺寸(KB)"
    }
    
    static func settings_minImageCount() -> String {
        return "提取图片最小数量"
    }
    
    static func settings_nextPageName() -> String {
        return "下一页标签"
    }
    
    static func settings_lastPageName() -> String {
        return "上一页标签"
    }
    
    static func settings_imageRequestNeedAuth() -> String {
        return "图片请求需要授权"
    }
    
    static func settings_pageBtnLeft() -> String {
        return "页面切换左手习惯开关"
    }
}

