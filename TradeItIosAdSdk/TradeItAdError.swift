enum TradeItAdError: ErrorType {
    case RequestError(String)
    case MissingConfig(String)
    case JSONParseError
    case MissingAdType(String)
    case UnknownError(String)
}
