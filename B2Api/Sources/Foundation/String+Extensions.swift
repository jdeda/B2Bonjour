//
//  String+Extensions.swift
//  B2Api
//
//  Created by Klajd Deda on 3/27/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
import Log4swift

// MARK: - String (Extensions) -

public extension String {
    static let kAFCharactersGeneralDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static let kAFCharactersSubDelimitersToEncode = "!$&'()*+,;="
    
    var percentEscapedString: String {
        var allowedCharacterSet = NSCharacterSet.urlUserAllowed
        allowedCharacterSet.remove(charactersIn: Self.kAFCharactersGeneralDelimitersToEncode + Self.kAFCharactersSubDelimitersToEncode)
        
        let escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        //        // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
        //        // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        //
        //        static NSUInteger const batchSize = 50;
        //
        //        NSUInteger index = 0;
        //        NSMutableString *escaped = @"".mutableCopy;
        //
        //        while (index < string.length) {
        //            NSUInteger length = MIN(string.length - index, batchSize);
        //            NSRange range = NSMakeRange(index, length);
        //
        //            // To avoid breaking up character sequences such as 👴🏻👮🏽
        //            range = [string rangeOfComposedCharacterSequencesForRange:range];
        //
        //            NSString *substring = [string substringWithRange:range];
        //            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        //            [escaped appendString:encoded];
        //
        //            index += range.length;
        //        }
        
        return escaped ?? self
    }
}
