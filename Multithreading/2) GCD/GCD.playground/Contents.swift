import UIKit

//MARK: - 1) Queues

class QueueTest1 {
    
    private let serialQueue = DispatchQueue(label: "serialTest")
    //Serial - задачи выполняются последовательно
    private let concurrentQueue = DispatchQueue(label: "serialTest", attributes: .concurrent)
    //Concurent - задачи выполняются параллельно
}

class QueueTest2 {
    
    private let globalQueue = DispatchQueue.global()
    //Global - является concurrent
    private let mainQueue = DispatchQueue.main
    //Main - является Serial и выполняется в главном потоке
}

//MARK: - 2) Methods (Async vs Sync)

class AsyncVcSyncTest {
    
    private let serialQueue = DispatchQueue(label: "serialTest")
//    private let serialQueue = DispatchQueue.global()
    func testSerial() {
        //async - управление вернется вызывающему потоку
        //sync - вызывающтй поток будет ожидать пока задача не будет выполнена
        serialQueue.async {
            sleep(1)
            print("Test 1")
        }
        serialQueue.async {
            sleep(1)
            print("Test 2")
        }
        serialQueue.sync {
            sleep(1)
            print("Test 3")
        }
        serialQueue.sync {
            sleep(1)
            print("Test 4")
        }
    }
}
//var asyncVcSyncTest1 = AsyncVcSyncTest1()
//asyncVcSyncTest1.testSerial()

//MARK: - 3) AsyncAfter

class AsyncAfterTest {
    
    private let concurrentQueue = DispatchQueue(label: "AsyncAfterTest", attributes: .concurrent)
    
    func test() {
        concurrentQueue.asyncAfter(deadline: .now() + 2) {
            print("test")
        }
    }
}
//let asyncAfterTest = AsyncAfterTest()
//asyncAfterTest.test()


//MARK: - 4) Concurrent perform
//способ эффективно распараллелить выполнение задачи

class ConcurrentPerformTest {
    
    func test() {
        DispatchQueue.concurrentPerform(iterations: 3) { (i) in
            print(i)// i - номер выполнения итерации
        }
    }
}
//var concurrentPerformTest = ConcurrentPerformTest()
//concurrentPerformTest.test()


//MARK: - 5) Work Item

class DispatchWorkItemTest1 {
    
    private let queue = DispatchQueue(label: "DispatchWorkItemTest1", attributes: .concurrent)
    
    func testNotify() {
        let item = DispatchWorkItem {
            print("test")
        }
        item.notify(queue: DispatchQueue.main) {
            print("finish")
        }
        print("-----")
        queue.async(execute: item)
    }
}
//var dispatchWorkItemTest1 = DispatchWorkItemTest1()
//dispatchWorkItemTest1.testNotify()

class DispatchWorkItemTest2 {

    private let queue = DispatchQueue(label: "DispatchWorkItemTest2")
    
    func testCancel() {
        queue.async {
            sleep(1)
            print("test 1")
        }
        queue.async {
            sleep(1)
            print("test 2")
        }
        let item = DispatchWorkItem {
            print("test")
        }
        queue.async(execute: item)
        item.cancel() //"test" не выполнится
    }
}
//var dispatchWorkItemTest2 = DispatchWorkItemTest2()
//dispatchWorkItemTest2.testCancel()

//MARK: - 6) Semaphore

class SemaphoreTest {
    
    private let semaphore = DispatchSemaphore(value: 0)
    //value - кол-во потоков, которые одновременно могут обращатся к ресурсу
    func test() {
        
        DispatchQueue.global().async {
            sleep(3)
            print("1")
            self.semaphore.signal()
        }
        semaphore.wait() //ждем signal
        print("2")
    }
}
//var semaphoreTest = SemaphoreTest()
//semaphoreTest.test()

class SemaphoreTest2 {
    
    private let semaphore = DispatchSemaphore(value: 2)
    //2 потока могут обращатся одновременно к ресурсу
    func doWork() {
        semaphore.wait()
        print("test")
        sleep(2)//Do something
        semaphore.signal()
    }
    
    func test() {
        DispatchQueue.global().async {
            self.doWork()
        }
        DispatchQueue.global().async {
            self.doWork()
        }
        DispatchQueue.global().async {
            self.doWork()
        }
    }
}
//var semaphoreTest2 = SemaphoreTest2()
//semaphoreTest2.test()

//MARK: - 7) Dispatch Group

class DispatchGroupTest1 {
    
    private let group = DispatchGroup()
    private let queue = DispatchQueue(label: "DispatchGroupTest1", attributes: .concurrent)
    
    func testNotify() {
        queue.async(group: group) {
            sleep(1)
            print("1")
        }
        queue.async(group: group) {
            sleep(2)
            print("2")
        }
        group.notify(queue: DispatchQueue.main) {
            print("Finish all")
        }
    }
}
//var dispatchGroupTest1 = DispatchGroupTest1()
//dispatchGroupTest1.testNotify()

class DispatchGroupTest2 {
    
    private let group = DispatchGroup()
    private let queue = DispatchQueue(label: "DispatchGroupTest2", attributes: .concurrent)
    
    func testWait() {
        
        group.enter() //заходим в группу
        queue.async {
            sleep(1)
            print("1")
            self.group.leave() //покидаем группу
        }
        group.enter()
        queue.async {
            sleep(2)
            print("2")
            self.group.leave()
        }
        group.wait()
        print("Finish all")
    }
}
//var dispatchGroupTest2 = DispatchGroupTest2()
//dispatchGroupTest2.testWait()

//MARK: - 8) Dispatch barrier

class DispatchBarrierTest {
    
    private let queue = DispatchQueue(label: "DispatchBarrierTest", attributes: .concurrent)
    private var internalTest: Int = 0
    
    func setTest(_ test: Int) {
        //блокируется ресурс только на запись
        queue.async(flags: .barrier) {
            self.internalTest = test
        }
    }
    
    func test() -> Int {
        var tmp: Int = 0
        queue.sync {
            tmp = self.internalTest
        }
        return tmp
    }
}

//MARK: - 9) Dispatch Source

class DispatchSourceTest1 {
    
    private let source = DispatchSource.makeTimerSource()
    
    func test() {
        source.setEventHandler {
            print("test")
        }
        source.schedule(deadline: .now(), repeating: 3)
        source.activate()
    }
}
//var dispatchSourceTest1 = DispatchSourceTest1()
//dispatchSourceTest1.test()

class DispatchSourceTest2 {
    
    private let source = DispatchSource.makeUserDataAddSource()
    //makeUserDataAddSource - позволяет суммировать события приходящие в source из других потоков
    init() {
        source.setEventHandler {
            print(self.source.data)
        }
        source.activate()
    }
    
    func test() {
        DispatchQueue.global().async {
            self.source.add(data: 20)
        }
    }
}
//var dispatchSourceTest2 = DispatchSourceTest2()
//dispatchSourceTest2.test()

//MARK: - 10) Target queue hierarchy

class TargetQueueHierarchyTest {
    
    private let targetQueue = DispatchQueue(label: "TargetQueue")
    
    func test() {
        let queue1 = DispatchQueue(label: "Queue1", target: targetQueue)
        let dispatchSource1 = DispatchSource.makeTimerSource(queue: queue1)
        dispatchSource1.setEventHandler {
            print("test1")
        }
        dispatchSource1.activate()
        
        let queue2 = DispatchQueue(label: "Queue1", target: targetQueue)
        let dispatchSource2 = DispatchSource.makeTimerSource(queue: queue2)
        dispatchSource2.setEventHandler {
            print("test2")
        }
        dispatchSource2.activate()
    }
}
//var targetQueueHierarchyTest = TargetQueueHierarchyTest()
//targetQueueHierarchyTest.test()
