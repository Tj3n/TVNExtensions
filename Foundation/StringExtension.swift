//
//  StringExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

extension String {
    
    public subscript (regex: String) -> String? {
        if let range = self.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            return String(self[range])
        }
        return nil
    }
    
    // MARK: Common
    public func index(fromStart index: Int) -> Index {
        return self.index(startIndex, offsetBy: index)
    }
    
    public func index(fromEnd index: Int) -> Index {
        return self.index(endIndex, offsetBy: index >= self.count ? -index : index)
    }

    public func replace(in r: Range<Int>, with string: String) -> String {
        return self.replacingCharacters(in: index(fromStart: r.lowerBound)..<index(fromStart: r.upperBound), with: string)
    }
    
    public func firstCharacterUppercase() -> String {
        if !self.isEmpty {
            return replace(in: 0..<1, with: self[...self.index(fromStart: 1)].uppercased())
        } else {
            return self
        }
    }
    
    //Convert nsrange to range
    public func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex)
        let to16 = utf16.index(from16!, offsetBy: nsRange.length, limitedBy: utf16.endIndex)

        if let from = String.Index(from16!, within: self),
            let to = String.Index(to16!, within: self) {
                return from ..< to
        }
        return nil
    }
    
    //MARK: Validation
    //Validate email
    public func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    //Validate URL
    public func isValidURL() -> Bool {
        let url = URL(string: self)
        // candidate is a well-formed url with:
        //  - a scheme (like http://)
        //  - a host (like stackoverflow.com)
        if url != nil && url?.scheme != nil && url?.host != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Conversion
    public func toCurrencySymbol() -> String {
        return findCurrencySymbolByCode(self)
    }
    
    fileprivate func findLocaleByCurrencyCode(_ currencyCode: String) -> Locale {
        let locales = Locale.availableIdentifiers
        
        let fiteredLocale = locales.filter({ Locale(identifier: $0).currencyCode == currencyCode })
        if let locale = fiteredLocale.first {
            return Locale(identifier: locale)
        }
        
        return Locale.current
    }
    
    fileprivate func findCurrencySymbolByCode(_ currencyCode: String) -> String {
        let locale = self.findLocaleByCurrencyCode(currencyCode)
        if let currencySymbol = locale.currencySymbol {
            return currencySymbol
        }
        return currencyCode
    }
    
    public func toCountryName() -> String? {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: self)
    }
    
    public func toFlag() -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in self.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    // MARK: HTML Stripping
    fileprivate func stringByStrippingHTML() -> String {
        var string = self
        
        while string.range(of: "<[^>]+>", options: [.regularExpression], range: nil, locale: nil) != nil {
            let range = string.range(of: "<[^>]+>", options: [.regularExpression], range: nil, locale: nil)
            string = string.replacingCharacters(in: range!, with: "")
//            string.stringByStrippingHTML()
        }
        
        return string
    }
    
    public func stringConvertedFromHTML() -> String {
        var text = self.replacingOccurrences(of: "<br>", with: "\n")
        text = text.replacingOccurrences(of: "<br />", with: "\n")
        text = text.replacingOccurrences(of: "<li>", with: "• ")
        text = text.replacingOccurrences(of: "</li>", with: "\n")
        text = text.replacingOccurrences(of: "<ul>", with: "\n")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "\n\n", with: "\n")
        text = text.stringByStrippingHTML()
        
        return text.trimmingCharacters(in: CharacterSet(charactersIn: "\n\(unichar(0x0085))")).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
//    public static func randomString(numericOnly: Bool, length: Int) -> String {
//        
//    }
}
