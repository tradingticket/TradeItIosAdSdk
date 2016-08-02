enum TradeItAdError: ErrorType {
    case RequestError(String)
    case JSONParseError
    case UnknownError
}
