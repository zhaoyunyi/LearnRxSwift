//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

let disposeBag = DisposeBag()
let neverSequence = Observable<String>.never()

// 没有序列
// never就是创建一个sequence，但是不发出任何事件信号
neverSequence
    .subscribe { _ in
        print("This will never be printed")
    }.addDisposableTo(disposeBag)

// 空序列 empty
// empty就是创建一个空的sequence,只能发出一个completed事件
Observable<Int>.empty()
    .subscribe { event in
        print(event)
    }
    .addDisposableTo(disposeBag)

// just
// just是创建一个sequence只能发出一种特定的事件，能正常结束
Observable.just("🔴")
    .subscribe { event in
        print(event)
    }.addDisposableTo(disposeBag)

// of 
// of是创建一个sequence能发出很多种事件信号
Observable.of("🐶", "🐱", "🐭", "🐹")
    .subscribe(onNext: { element in
        print(element)
    })
    .addDisposableTo(disposeBag)

//from
//from就是从集合中创建sequence，例如数组，字典或者Set
Observable.from(["🐶", "🐱", "🐭", "🐹"])
    .subscribe(onNext: { print($0)})
    .addDisposableTo(disposeBag)


print("自定义序列")
// create
// 我们也可以自定义可观察的sequence，那就是使用create
let myJust =  { (element: String) -> Observable<String> in
    return Observable.create { observer in
        observer.on(.next(element))
        observer.on(.completed)
        return Disposables.create()
    }
}

myJust("🔴")
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)


//range
//range就是创建一个sequence，他会发出这个范围中的从开始到结束的所有事件
Observable.range(start:1, count: 10)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

//repeatElement
//创建一个sequence，发出特定的事件n次
Observable.repeatElement("🔴")
    .take(2)
    .subscribe(onNext: { print($0)})
    .addDisposableTo(disposeBag)

// generate
// generate是创建一个可观察sequence，当初始化的条件为true的时候，他就会发出所对应的事件
Observable.generate(
    initialState: 0,
    condition: { $0 < 4 },
    iterate: { $0 + 1 }
    )
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)


// deferred
// deferred会为每一为订阅者observer创建一个新的可观察序列
var count = 1

let deferredSequence = Observable<String>.deferred {
    print("Creating \(count)")
    count += 1
    
    return Observable.create { observer in
        print("Emitting...")
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐵")
        return Disposables.create()
    }
}

deferredSequence
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

deferredSequence
    .subscribe(onNext: { print($0) })
    .addDisposableTo(disposeBag)

enum TestError: Error {
    case test
}
// error
// 创建一个可观察序列，但不发出任何正常的事件，只发出error事件并结束
Observable<Int>.error(TestError.test)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)

// doOn
// doOn我感觉就是在直接onNext处理时候，先执行某个方法，doOnNext( :)方法就是在subscribe(onNext:)前调用，doOnCompleted(:)就是在subscribe(onCompleted:)前面调用的
Observable.of("🍎", "🍐", "🍊", "🍋")
    .do(onNext: { print("Intercepted_Next:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
    .subscribe(onNext: { print($0) },onCompleted: { print("结束") })
    .addDisposableTo(disposeBag)







