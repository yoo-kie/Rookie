//
//  Constant.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/19.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

enum Constant {
    
    enum Date {
        static let locale: String = "ko"
        static let dataFormat: String = "yyyy.MM.dd eee"
    }

    enum Layer {
        static let cornerRadius: CGFloat = 10
    }
    
    enum Defer {
        static let cancel: String = "닫기"
        static let doneMessage: String = "이미 완료된 일입니다-!"
    }
    
    enum Add {
        static let message: String = "추가하기"
        static let ok: String = "완료"
        static let cancel: String = "취소"
        static let placeHolder: String = "ex) 영화보기"
    }
    
}
