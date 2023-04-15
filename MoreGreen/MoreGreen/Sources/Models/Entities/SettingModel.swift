//
//  SettingModel.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/12.
//

import Foundation

// settingViewControllerのcellのimageとtitleを定義する構造体
struct SettingViewItemModel {
    // ここで、imageにfetchするのは、適切ではないとか考えたため、imageNameを入れることにした
    var imageName: String?
    var title: String?
}

//SettingModelをここで、定義
extension SettingViewItemModel {
    // index順番通り
    static var infomation = [
        SettingViewItemModel(imageName: "bell", title: "通知設定"),
        SettingViewItemModel(imageName: "trash", title: "データ初期化")
    ]
}
