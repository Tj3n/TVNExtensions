//
//  IndexedListCollator.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 10/30/19.
//

import Foundation
import UIKit

/// The model struct/class should implement this to sort
public protocol IndexableItem {
    var indexedOn: NSString { get }
}

/// Use to generate the indexSectionTitles for custom object
/// See example below
public class IndexedListCollator<Item: IndexableItem> {
    
    public init() {
        
    }
    
    /// Unfortunately, `UILocalizedIndexedCollation` only works with selectors which require attributes to be exposed via @objc. Structs do not support exposing attributes via this tag. This little wrapper helps in those cases.
    private final class CollationWrapper: NSObject {
        let value: Any
        @objc let indexedOn: NSString
        
        init(value: Any, indexedOn: NSString) {
            self.value = value
            self.indexedOn = indexedOn
        }
        
        func unwrappedValue<UnwrappedType>() -> UnwrappedType {
            return value as! UnwrappedType
        }
    }
 
    public func sectioned(items: [Item]) -> (sections: [[Item]], collation: UILocalizedIndexedCollation) {
        let collation = UILocalizedIndexedCollation.current()
        let selector = #selector(getter: CollationWrapper.indexedOn)
        
        let wrappedItems = items.map { item in
            CollationWrapper(value: item, indexedOn: item.indexedOn)
        }
        
        let sortedObjects = collation.sortedArray(from: wrappedItems, collationStringSelector: selector) as! [CollationWrapper]
        
        var sections = collation.sectionIndexTitles.map { _ in [Item]() }
        sortedObjects.forEach { item in
            let sectionNumber = collation.section(for: item, collationStringSelector: selector)
            sections[sectionNumber].append(item.unwrappedValue())
        }
     
        return (sections: sections, collation: collation)
    }
}


//var collation: UILocalizedIndexedCollation
//var sections: [[Object]]
//
//extension ExampleViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sections[section].count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let object = sections[indexPath.section][indexPath.row]
//        //Do sth
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return collation.sectionTitles[section]
//    }
//
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return collation.section(forSectionIndexTitle: index)
//    }
//
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return collation.sectionIndexTitles
//    }
//}
