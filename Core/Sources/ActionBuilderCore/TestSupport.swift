// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public extension Dictionary where Key == String, Value == String {
    var isTestingUI: Bool {
        get { self["UITesting"] == "YES" }
        set { self["UITesting"] = newValue ? "YES" : "NO" }
    }
}
