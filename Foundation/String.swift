//
//  StringExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

// MARK: Common
extension String {
    public subscript (regex: String) -> String? {
        if let range = self.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            return String(self[range])
        }
        return nil
    }
    
    public func index(fromStart index: Int) -> Index {
        return index <= 0 ? startIndex : self.index(startIndex, offsetBy: min(index, count-1))
    }
    
    public func index(fromEnd index: Int) -> Index {
        return index <= 0 ? self.index(before: endIndex) : self.index(endIndex, offsetBy: max(-index, -count))
    }
    
    public subscript (range: CountableRange<Int>) -> String {
        return String(self[index(fromStart: range.lowerBound)..<index(fromStart: range.upperBound)])
    }
    
    public subscript (range: CountableClosedRange<Int>) -> String {
        return String(self[index(fromStart: range.lowerBound)...index(fromStart: range.upperBound)])
    }
    
    public subscript (range: PartialRangeThrough<Int>) -> String {
        return String(self[...index(fromStart: range.upperBound)])
    }
    
    public subscript (range: CountablePartialRangeFrom<Int>) -> String {
        return String(self[index(fromStart: range.lowerBound)...])
    }
    
    public func replace(in r: CountableRange<Int>, with string: String) -> String {
        return self.replacingCharacters(in: index(fromStart: r.lowerBound)..<index(fromStart: r.upperBound), with: string)
    }
    
    public func replace(in r: CountableClosedRange<Int>, with string: String) -> String {
        return self.replacingCharacters(in: index(fromStart: r.lowerBound)...index(fromStart: r.upperBound), with: string)
    }
    
    public func firstCharacterUppercase() -> String {
        if !self.isEmpty {
            return String(self[self.startIndex]).uppercased()+String(self[self.index(after: self.startIndex)...])
        } else {
            return self
        }
    }
    
    public func trim(in set: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: set)
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
    
    public func getSize(font: UIFont, width: CGFloat = UIScreen.main.bounds.size.width, height: CGFloat = .greatestFiniteMagnitude) -> CGRect {
        guard self.isNotEmpty else { return .zero }
        let fontAttributes = [NSAttributedStringKey.font: font]
        let sizeOfText = (self as NSString).boundingRect(with: CGSize(width: width, height: height), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: fontAttributes, context: nil)
        return sizeOfText
    }
}

// MARK: Validation
extension String {
    public var isNotEmpty: Bool {
        get {
            return !self.isEmpty
        }
    }
    
    public func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    public func isValidURL() -> Bool {
        if let url = URL(string: self), let _ = url.scheme, let _ = url.host {
            return true
        } else {
            return false
        }
    }
}

// MARK: Conversion
extension String {
    
    /// Format non-decimal number string to string with decimal dot after numbersAfterDecimal
    ///
    /// - Parameter numbersAfterDecimal: numbers of characters after dot
    /// - Returns: formatted string
    public func formatDecimalString(numbersAfterDecimal: Int) -> String {
        guard let _ = Decimal(string: self) else { return "0.00" }
        
        var modPrice = self
        
        guard numbersAfterDecimal > 0 else { return self }
        
        if let dot = modPrice.range(of: ".") {
            modPrice.removeSubrange(dot)
        }
        
        while modPrice.count < numbersAfterDecimal+1 {
            modPrice.insert("0", at: modPrice.startIndex)
        }
        
        while modPrice.count > numbersAfterDecimal+1 && modPrice.first! == "0" {
            modPrice.remove(at: modPrice.startIndex)
        }
        
        modPrice.insert(".", at: modPrice.index(fromEnd: numbersAfterDecimal))
        return modPrice
    }
    
    public func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter.shared
        dateFormatter.dateFormat = format
        //        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from: self)
    }
    
    public func toBase64() -> String {
        return self.data(using: .utf8)!.base64EncodedString()
    }
    
    //To use with currency code
    public func toCurrencySymbol() -> String {
        return findCurrencySymbolByCode(self)
    }
    
    //To use with number string
    public func toCurrencyFormatter(currencyCode: String) -> String {
        if NSDecimalNumber(string: self) != NSDecimalNumber.notANumber {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            guard let formattedStr = formatter.string(from: NSDecimalNumber(string: self)) else { return self }
            return formattedStr
        }
        return self
    }
    
    fileprivate func findLocaleByCurrencyCode(_ currencyCode: String) -> Locale? {
        let locales = Locale.availableIdentifiers
        
        if let fiteredLocale = locales.index(where: { Locale(identifier: $0).currencyCode == currencyCode }) {
             return Locale(identifier: locales[fiteredLocale])
        }
        
//        let fiteredLocale = locales.filter({ Locale(identifier: $0).currencyCode == currencyCode })
//        if let locale = fiteredLocale.first {
//            return Locale(identifier: locale)
//        }
        
        return nil
    }
    
    fileprivate func findCurrencySymbolByCode(_ currencyCode: String) -> String {
        guard let locale = self.findLocaleByCurrencyCode(currencyCode) else { return currencyCode }
        if let currencySymbol = locale.currencySymbol {
            return currencySymbol
        }
        return currencyCode
    }
    
    public func toCountryName(locale: Locale = Locale(identifier: "en_US")) -> String? {
        return locale.localizedString(forRegionCode: self) ?? self
    }
    
    public func toFlag() -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in self.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
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
    
    fileprivate func stringByStrippingHTML() -> String {
        var string = self
        
        while string.range(of: "<[^>]+>", options: [.regularExpression], range: nil, locale: nil) != nil {
            let range = string.range(of: "<[^>]+>", options: [.regularExpression], range: nil, locale: nil)
            string = string.replacingCharacters(in: range!, with: "")
            //            string.stringByStrippingHTML()
        }
        
        return string
    }
}
