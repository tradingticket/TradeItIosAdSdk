enum TradeItAdError: Error {
    case requestError(String)
    case missingConfig(String)
    case jsonParseError
    case missingAdType(String)
    case unknownError(String)
}
