import UIKit

//MARK: - 1) Thread

var nsthread = Thread(block: {
    print("This is Thread")
})
//nsthread.start()

//MARK: - 2) QualityOfService

class QosThreadTest {

    func test() {
        let thread = Thread {
            print("Test QOS")
            print(qos_class_self())
        }
        thread.qualityOfService = .userInteractive
        thread.start()
        print(qos_class_main())
    }
}
//var qos = QosThreadTest()
//qos.test()


//MARK: - 3) Mutex

class NSLockTest {

    private let lock = NSLock()
    func test(i: Int) {
        lock.lock()
        //Do something
        lock.unlock()
    }
}

//MARK: - 4) Recursive Mutex

class RecursiveLockTest {

    private let lock = NSRecursiveLock()
    
    public func test1() {
        lock.lock()
        test2()
        lock.unlock()
    }
    public func test2() {
        lock.lock()
        //Do something
        lock.unlock()
    }
}

//MARK: - 5) NSCondition

class ConditionTest {

    private let condition = NSCondition()
    private var check = false

    func test1() {
        print("test1")

        condition.lock()
        while (!check) {
            print("test1 - wait")
            condition.wait()
        }
        condition.unlock()
        print("test1 - unlock")
    }
    func test2() {

        print("test2")
        condition.lock()
        check = true
        condition.signal()
        condition.unlock()
    }
}
//var ct = ConditionTest()
//ct.test1()
//ct.test2()

//MARK: - 6) UnfairLock (SpinLock)

class UnfairLockTest {
    private var lock = os_unfair_lock_s()
    func test() {

        os_unfair_lock_lock(&lock)
        //Do something
        os_unfair_lock_unlock(&lock)
    }
}

//MARK: - 7) Synchronized

class SynchronizedTest {

    private let lock = NSObject()
    func test() {
        objc_sync_enter(lock)
        //do something
        objc_sync_exit(lock)
    }
}

//MARK: - 8) Atomic Operation

class AtomicOperationsPseudoCodeTest {

    func compareAndSwap(old: Int, new: Int, value: UnsafeMutablePointer<Int>) -> Bool {
        if (value.pointee == old) {
            value.pointee = new
            return true
        }
        return false
    }

    func atomicAdd(amount: Int, value: UnsafeMutablePointer<Int>) -> Int {
        var success = false
        var new: Int = 0

        while !success {
            let original = value.pointee
            new = original + amount
            success = compareAndSwap(old: original, new: new, value: value)
        }
        return new
    }
}
