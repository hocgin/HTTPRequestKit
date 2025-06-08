# HttpRequest

A description of this package.

### 使用

```swift 

        let request = HTTPRequest.build(baseURL: "https://9cb3e59a017449b081da7defd93dc684.api.mockbin.io/")

        /// 方式 1
        let result1 = try await request.run(String.self)
        debugPrint("result1 = \(result1)")
        /// 方式 2
        let result2: (Data, URLResponse) = try await request.response()
        debugPrint("result2 0 = \(result2.0), 1 = \(result2.1)")
        /// 方式 3
        let result3 = try await request.run(TestResp.self)
        debugPrint("result3 = \(result3)")

        /// ===== Combine =====
        /// 方式 4
        let cancel = request.sink(success: { (result4: TestResp) in
            debugPrint("result4 = \(result4)")
        })
        
        /// 方式5
        let publish: AnyPublisher<TestResp, HTTPRequest.HRError> = request.publish()
        let cancel5 = publish.sink(
            receiveCompletion: { debugPrint("receiveCompletion = \($0)") },
            receiveValue: { result5 in
                debugPrint("result5 = \(result5)")
            }
        )
```
