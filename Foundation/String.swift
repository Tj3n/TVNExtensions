//
//  StringExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
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
    
    /// Remove front and back until reach characters not in set
    ///
    /// - Parameter set: CharacterSet
    /// - Returns: New String
    public func trim(in set: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: set)
    }
    
    /// Remove all characters in the characterSet
    ///
    /// - Parameter characterSet: CharacterSet
    /// - Returns: New String
    public func removeCharacters(from characterSet: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !characterSet.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    /// Remove all characters in the characterSet inside the string
    ///
    /// - Parameter characterString: string to get characters from
    /// - Returns: New String
    public func removeCharacters(from characterString: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: characterString))
    }
    
    /// Convert NSRange to Range
    ///
    /// - Parameter nsRange: NSRange
    /// - Returns: optional Range<String.Index>
    public func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex)
        let to16 = utf16.index(from16!, offsetBy: nsRange.length, limitedBy: utf16.endIndex)

        if let from = String.Index(from16!, within: self),
            let to = String.Index(to16!, within: self) {
                return from ..< to
        }
        return nil
    }
    
    public func getSize(attribute: [NSAttributedString.Key: Any], width: CGFloat = UIScreen.main.bounds.size.width, height: CGFloat = .greatestFiniteMagnitude) -> CGRect {
        guard self.isNotEmpty else { return .zero }
        let sizeOfText = (self as NSString).boundingRect(with: CGSize(width: width, height: height), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: attribute, context: nil)
        return sizeOfText
    }
    
    /// Will have hyphen (-) on word break
    public func hyphenationString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        return NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
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
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

// MARK: Conversion
extension String {
    
    /// Localize string, won't work with genstrings
    ///
    /// - Parameter comment: comment
    /// - Returns: Localized string
    public func localized(comment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
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
    
    public static func generateRandomString(length: Int, charactersIn chars: String = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") -> String {
        let upperBound = UInt32(chars.count)
        return String((0..<length).map { _ -> Character in
            return chars[chars.index(chars.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }
    
    public func toDate(format: String, dateFormatter: DateFormatter = DateFormatter.shared) -> Date? {
        dateFormatter.dateFormat = format
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from: self)
    }
    
    public func toBase64() -> String {
        return self.data(using: .utf8)!.base64EncodedString()
    }
    
    //To use with currency code
    public func toCurrencySymbol() -> String {
//        let result = Locale.availableIdentifiers.map{ Locale(identifier: $0) }.first{ $0.currencyCode == self }
//        return result?.currencySymbol ?? self
        guard let result = Locale.availableIdentifiers.first(where: { (identifier) -> Bool in
            return Locale(identifier: identifier).currencyCode == self
        }) else { return self }
        return Locale(identifier: result).currencySymbol ?? self
    }
    
    //To use with number string
    public func toCurrencyFormatter(currencyCode: String, formatter: NumberFormatter = NumberFormatter()) -> String {
        let number = NSDecimalNumber(string: self)
        if number != NSDecimalNumber.notANumber {
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            guard let formattedStr = formatter.string(from: number) else { return self }
            return formattedStr
        }
        return self
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
