enum TradeItAdError: ErrorType {
    case RequestError(String)
    case MissingConfig(String)
    case JSONParseError
    case UnknownError
}
