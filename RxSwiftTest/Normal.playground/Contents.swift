//: Playground - noun: a place where people can play

import UIKit
import RxSwift

extension ObservableType {
    
    /**
     Add observer with `id` and print each emitted event.
     - parameter id: an identifier for the subscription.
     */
    func addObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
    
}

func writeSequenceToConsole<O: ObservableType>(name: String, sequence: O) -> Disposable {
    return sequence.subscribe { event in
        print("Subscription: \(name), event: \(event)")
    }
}
// Subjects
// Subjet是observable和Observer之间的桥梁，一个Subject既是一个Obserable也是一个Observer，他既可以发出事件，也可以监听事件。

let disposeBag = DisposeBag()
let subject = PublishSubject<String>()

subject.addObserver("1").addDisposableTo(disposeBag)
subject.onNext("🐶")
subject.onNext("🐱")

subject.addObserver("2").addDisposableTo(disposeBag)
subject.onNext("🅰️")
subject.onNext("🅱️")

// ReplaySubject
// 当你订阅ReplaySubject的时候，你可以接收到订阅他之后的事件，但也可以接受订阅他之前发出的事件，接受几个事件取决与bufferSize的大小
let replaySubject = ReplaySubject<String>.create(bufferSize: 1)

replaySubject.addObserver("3").addDisposableTo(disposeBag)
replaySubject.onNext("🐶--replay")
replaySubject.onNext("🐱--replay")

replaySubject.addObserver("4").addDisposableTo(disposeBag)
replaySubject.onNext("🅰️")
replaySubject.onNext("🅱️")

// BehaviorSubject
// 当你订阅了BehaviorSubject，你会接受到订阅之前的最后一个事件。
let behaviorSubject = BehaviorSubject(value: "🔴")

behaviorSubject.addObserver("5").addDisposableTo(disposeBag)
behaviorSubject.onNext("🐶")
behaviorSubject.onNext("🐱")


behaviorSubject.addObserver("6").addDisposableTo(disposeBag)
behaviorSubject.onNext("🅰️")
behaviorSubject.onNext("🅱️")

// Variable
// Variable是BehaviorSubject一个包装箱，就像是一个箱子一样，使用的时候需要调用asObservable()拆箱，里面的value是一个BehaviorSubject，他不会发出error事件，但是会自动发出completed事件。
let variable = Variable("🔴")

variable.asObservable().addObserver("variable").addDisposableTo(disposeBag)
variable.value = "🐶"
variable.value = "🐱"

variable.asObservable().addObserver("variable2").addDisposableTo(disposeBag)
variable.value = "🅰️"
variable.value = "🅱️"


// 联合操作
// 联合操作就是把多个Observable流合成单个Observable流

// startWith
// 在发出事件消息之前，先发出某个特定的事件消息。比如发出事件2 ，3然后我startWith(1)，那么就会先发出1，然后2 ，3
Observable.of("2", "3")
    .startWith("1")
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

// merge
//合并两个Observable流合成单个Observable流，根据时间轴发出对应的事件
let subject1 = PublishSubject<String>()
let subject2 = PublishSubject<String>()

Observable.of(subject1, subject2)
    .merge()
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

subject1.onNext("🅰️")

subject1.onNext("🅱️")

subject2.onNext("①")

subject2.onNext("②")

subject1.onNext("🆎")

subject2.onNext("③")

// zip
// 绑定超过最多不超过8个的Observable流，结合在一起处理。注意Zip是一个事件对应另一个流一个事件。
let stringSubject = PublishSubject<String>()
let intSubject = PublishSubject<Int>()

Observable.zip(stringSubject, intSubject) { stringElement, intElement in
    "\(stringElement) \(intElement)"
    }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)
// 将stringSubject和intSubject压缩到一起共同处理
stringSubject.onNext("🅰️")
stringSubject.onNext("🅱️")

intSubject.onNext(2)

intSubject.onNext(1)

stringSubject.onNext("🆎")
intSubject.onNext(3)

// combineLatest
// 绑定超过最多不超过8个的Observable流，结合在一起处理。和Zip不同的是combineLatest是一个流的事件对应另一个流的最新的事件，两个事件都会是最新的事件，可将下图与Zip的图进行对比。

let stringSubjectCombineLatest = PublishSubject<String>()
let intSubjectCombineLatest = PublishSubject<Int>()
print("combineLatest")
Observable.combineLatest(stringSubjectCombineLatest, intSubjectCombineLatest) { stringElement, intElement in
    "\(stringElement) \(intElement)"
    }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

stringSubjectCombineLatest.onNext("🅰️")

stringSubjectCombineLatest.onNext("🅱️")
intSubjectCombineLatest.onNext(1)

intSubjectCombineLatest.onNext(2)

stringSubjectCombineLatest.onNext("🆎")

// switchLatest
// switchLatest可以对事件流进行转换，本来监听的subject1，我可以通过更改variable里面的value更换事件源。变成监听subject2了
print("switchLatest")
let subject1SwitchLatest = BehaviorSubject(value: "⚽️")
let subject2SwitchLatest = BehaviorSubject(value: "🍎")

let variableSwitchLatest = Variable(subject1SwitchLatest)

variableSwitchLatest.asObservable()
    .switchLatest()
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

subject1SwitchLatest.onNext("🏈")
subject2SwitchLatest.onNext("🏀")

variableSwitchLatest.value = subject2SwitchLatest

subject1SwitchLatest.onNext("⚾️")

subject2SwitchLatest.onNext("🍐")

variableSwitchLatest.value = subject1SwitchLatest
subject2SwitchLatest.onNext("赚到 Switch1 上去了")
subject1SwitchLatest.onNext("其实是我呢")

// 变换操作 map
// 通过传入一个函数闭包把原来的sequence转变为一个新的sequence的操作
Observable.of(1, 2, 3)
    .map { $0 * $0 }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

print("flatMap")
// flatMap
// 将一个sequence转换为一个sequences，当你接收一个sequence的事件，你还想接收其他sequence发出的事件的话可以使用flatMap，她会将每一个sequence事件进行处理以后，然后再以一个新的sequence形式发出事件。和Swift中的意思差不多。
struct Player {
    var score: Variable<Int>		//里面是一个Variable
}

let 👦🏻 = Player(score: Variable(80))
let 👧🏼 = Player(score: Variable(90))
let 😂 = Player(score: Variable(550))

let player = Variable(👦🏻)  //将player转为Variable

player.asObservable()
    .flatMap { $0.score.asObservable() }//转换成了一个新的序列
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

👦🏻.score.value = 85

player.value = 👧🏼 //更换了value，相当于又添加了一个sequence，两个sequence都可以接收

👦🏻.score.value = 95
👦🏻.score.value = 222
player.value = 😂

👧🏼.score.value = 100

// flatMapLatest
// flatMapLatest只会接收最新的value事件，将上例改为flatMapLatest

print("scan--")
// scan 
// scan就是给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作。

Observable.of(10, 100, 1000)
    .scan(1) { aggregateValue, newValue in
        aggregateValue + newValue
    }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

// 过滤和约束
// filter
// filter很好理解，就是过滤掉某些不符合要求的事件
Observable.of(
    "🐱", "🐰", "🐶",
    "🐸", "🐱", "🐰",
    "🐹", "🐸", "🐱")
    .filter {
        $0 == "🐱"
    }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

print("distinctUntilChanged0----")
// distinctUntilChanged
// distinctUntilChanged就是当下一个事件与前一个事件是不同事件的事件才进行处理操作
Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
    .distinctUntilChanged()
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

// elementAt
// 只处理在指定位置的事件
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .elementAt(3)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

print("single----")
// single
// 找出在sequence只发出一次的事件，如果超过一个就会发出error错误
Observable.of("🐱", "🐱", "🐶", "🐸", "🐷", "🐵")
    .single()
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .single { $0 == "🐸" }		//青蛙只有一个，completed
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐱", "🐰", "🐶")
    .single { $0 == "🐰" } //兔子有两个，会发出error
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .single { $0 == "🔵" } //没有蓝色球，会发出error
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

// take
// 只处理前几个事件信号,
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .take(3)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .takeLast(3)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

// takeWhile
// 当条件满足的时候进行处理
Observable.of(1, 2, 3, 4, 5, 6)
    .takeWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)


// takeUntil
// 接收事件消息，直到另一个sequence发出事件消息的时候
let sourceSequence = PublishSubject<String>()
let referenceSequence = PublishSubject<String>()

sourceSequence
    .takeUntil(referenceSequence)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

sourceSequence.onNext("🐱")
sourceSequence.onNext("🐰")
sourceSequence.onNext("🐶")

referenceSequence.onNext("🔴")	//停止接收消息

sourceSequence.onNext("🐸")
sourceSequence.onNext("🐷")
sourceSequence.onNext("🐵")



// skip
// 取消前几个事件

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .skip(2)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)


// skipWhile
// 满足条件的事件消息都取消
Observable.of(1, 2, 3, 4, 5, 6)
    .skipWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)


// skipWhileWithIndex
// 满足条件的都被取消，传入的闭包同skipWhile有点区别而已
Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
    .skipWhileWithIndex { element, index in
        index < 3
    }
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

print("skipUntil ----")
// skipUntil
// 直到某个sequence发出了事件消息，才开始接收当前sequence发出的事件消息
let sourceSequenceSkipUntil = PublishSubject<String>()
let referenceSequenceSkipUntil = PublishSubject<String>()

sourceSequenceSkipUntil
    .skipUntil(referenceSequenceSkipUntil)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

sourceSequenceSkipUntil.onNext("🐱")
sourceSequenceSkipUntil.onNext("🐰")
sourceSequenceSkipUntil.onNext("🐶")

referenceSequenceSkipUntil.onNext("🔴")

sourceSequenceSkipUntil.onNext("🐸")
sourceSequenceSkipUntil.onNext("🐷")
sourceSequenceSkipUntil.onNext("🐵")


// toArray
// 将sequence转换成一个array，并转换成单一事件信号，然后结束
Observable.range(start: 1, count: 10)
    .toArray()
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)


// reduce
// 用一个初始值，对事件数据进行累计操作。reduce接受一个初始值，和一个操作符号
Observable.of(10, 100, 1000)
    .reduce(1, accumulator: +)
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

print("concat ----")
// concat
// concat会把多个sequence和并为一个sequence，并且当前面一个sequence发出了completed事件，才会开始下一个sequence的事件。
// 在第一sequence完成之前，第二个sequence发出的事件都会被忽略，但会接收一完成之前的二发出的最后一个事件。不好解释，看例子说明

let subject1Concat = BehaviorSubject(value: "🍎")
let subject2Concat = BehaviorSubject(value: "🐶")

let variableConcat = Variable(subject1Concat)

variableConcat.asObservable()
    .concat()
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

subject1Concat.onNext("🍐")
subject2Concat.onNext("🍊")

variableConcat.value = subject2Concat

subject2Concat.onNext("🐱")	//1完成前，会被忽略
subject2Concat.onNext("teng") //1完成前，会被忽略
subject2Concat.onNext("fei")	//1完成前的最后一个，会被接收

subject1Concat.onCompleted()

subject2Concat.onNext("🐭")


playgroundShouldContinueIndefinitely()
print("连接性操作----")
// 连接性操作
// Connectable Observable有订阅时不开始发射事件消息，而是仅当调用它们的connect（）方法时。这样就可以等待所有我们想要的订阅者都已经订阅了以后，再开始发出事件消息，这样能保证我们想要的所有订阅者都能接收到事件消息。其实也就是等大家都就位以后，开始发出消息。

// publish
// 将一个正常的sequence转换成一个connectable sequence

func sampleWithPublish() {
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .publish()
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(12) { _ = intSequence.connect() } //相当于把事件消息推迟了两秒
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
    
}

//sampleWithPublish()

// replay
// 将一个正常的sequence转换成一个connectable sequence，然后和replaySubject相似，能接收到订阅之前的事件消息。

func sampleWithReplay() {
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .replay(5)	//接收到订阅之前的5条事件消息
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(8) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
//    delay(8) {
//        _ = intSequence
//            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
//    }
}
//sampleWithReplay()


// multicast
// 将一个正常的sequence转换成一个connectable sequence，并且通过特性的subject发送出去，比如PublishSubject，或者replaySubject，behaviorSubject等。不同的Subject会有不同的结果。

func sampleWithMulticast() {
    let subject = PublishSubject<Int>()
    
    _ = subject
        .subscribe(onNext: { print("Subject: \($0)") })
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .multicast(subject)
    
    _ = intSequence
        .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
    }
}
//sampleWithMulticast()


// 错误处理
// catchErrorJustReturn

let sequenceThatFails = PublishSubject<String>()

sequenceThatFails
    .catchErrorJustReturn("😊")
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

sequenceThatFails.onNext("😬")
sequenceThatFails.onNext("😨")
sequenceThatFails.onNext("😡")
sequenceThatFails.onNext("🔴")
sequenceThatFails.onError(TestError.test)

// catchError
// 捕获error进行处理，可以返回另一个sequence进行订阅
let sequenceThatFailsCatchError = PublishSubject<String>()
let recoverySequenceCatchError = PublishSubject<String>()

sequenceThatFails
    .catchError {
        print("Error:", $0)
        return recoverySequenceCatchError
    }
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

sequenceThatFailsCatchError.onNext("😬")
sequenceThatFailsCatchError.onNext("😨")
sequenceThatFailsCatchError.onNext("😡")
sequenceThatFailsCatchError.onNext("🔴")
sequenceThatFailsCatchError.onError(TestError.test)

recoverySequenceCatchError.onNext("😊")


// retry
// 遇见error事件可以进行重试，比如网络请求失败，可以进行重新连接
var count = 1

let sequenceThatErrors = Observable<String>.create { observer in
    observer.onNext("🍎")
    observer.onNext("🍐")
    observer.onNext("🍊")
    
    if count == 1 {
        observer.onError(TestError.test)
        print("Error encountered")
        count += 1
    }
    print("Error \(count)")
    observer.onNext("🐶")
    observer.onNext("🐱")
    observer.onNext("🐭")
    observer.onCompleted()
    
    return Disposables.create()
}

sequenceThatErrors
    .retry(3)		//不传入数字的话，只会重试一次  不知道为什么只retry 2 次
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)


sequenceThatErrors
    .retry(1)
    .debug()
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

// 查看RxSwift所有资源的占用
