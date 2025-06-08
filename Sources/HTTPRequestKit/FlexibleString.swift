
struct FlexibleString: Codable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // 尝试直接解码成字符串
        if let string = try? container.decode(String.self) {
            self.value = string
            return
        }

        // 如果是字典对象，尝试从其中一个 key 解出字符串
        if let dict = try? container.decode([String: String].self),
           let first = dict.values.first
        {
            self.value = first
            return
        }

        // 最后失败
        throw DecodingError.typeMismatch(
            String.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected a string or a dictionary with string values"
            )
        )
    }
}