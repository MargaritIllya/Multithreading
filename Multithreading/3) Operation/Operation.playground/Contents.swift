import UIKit

//MARK: - 1) BlockOperation

class BlockOperationTest {
    
    private let operationQueue = OperationQueue()
    
    func test() {
        let blockOperation = BlockOperation {
            print("test")
        }
        operationQueue.addOperation(blockOperation)
    }
}
//var blockOperationTest = BlockOperationTest()
//blockOperationTest.test()

//MARK: - 2) Operation KVO

class OperationKVOTest: NSObject {
    
    func test() {
        let operation = Operation()
        operation.addObserver(self,
                              forKeyPath: "isCancelled",
                              options: NSKeyValueObservingOptions.new,
                              context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "isCancelled" {
            print("Operation cancelle")
        }
    }
}

//MARK: - 3) Operation and OperationQueue

class OperationTest2 {
    
    private let operationQueue = OperationQueue()
    
    func test() {
        operationQueue.addOperation {
            print("test2")
        }
    }
}
//var operationTest2 = OperationTest2()
//operationTest2.test()

class OperationTest {
    
    class OperationA: Operation {
        
        override func main() {
            print("test")
        }
    }
    
    private let operationQueue = OperationQueue()
    
    func test() {
        let testOperation = OperationA()
        operationQueue.addOperation(testOperation)
    }
}
//var operationTest = OperationTest()
//operationTest.test()

//MARK: - 4) maxConcurrentOperationCount

class OperationCountTest {
    
    private let operationQueue = OperationQueue()
    
    func test() {
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.addOperation {
            sleep(1)
            print("test 1")
        }
        operationQueue.addOperation {
            sleep(1)
            print("test 2")
        }
        operationQueue.addOperation {
            sleep(1)
            print("test 3")
        }
    }
}
//var operationCountTest = OperationCountTest()
//operationCountTest.test()

//MARK: - 5) Cancel

class CancelTest {
    
    private let operationQueue = OperationQueue()
    
    class OperationCancelTest: Operation {
        
        override func main() {
            if isCancelled {
                print("if 1")
                return
            }
            sleep(1)
            if isCancelled {
                print("if 2")
                return
            }
            print("test")
        }
    }
    
    func test() {
        let cancelOperation = OperationCancelTest()
        operationQueue.addOperation(cancelOperation)
        cancelOperation.cancel()
    }
}
//var cancelTest = CancelTest()
//cancelTest.test()
