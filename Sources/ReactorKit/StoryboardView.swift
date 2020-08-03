import RxSwift

#if !os(Linux)
#if os(iOS) || os(tvOS)
import UIKit
private typealias OSViewController = UIViewController
#elseif os(OSX)
import AppKit
private typealias OSViewController = NSViewController
#endif

import WeakMapTable

private typealias AnyView = AnyObject
private enum MapTables {
  static let reactor = WeakMapTable<AnyView, Any>()
  static let isReactorBinded = WeakMapTable<AnyView, Bool>()
}

public protocol _ObjCStoryboardView {
  func performBinding()
}

public protocol StoryboardView: View, _ObjCStoryboardView {
}

extension StoryboardView {
  public var reactor: Reactor? {
    get { return MapTables.reactor.value(forKey: self) as? Reactor }
    set {
        print(reactor)
        print("StoryboardView의 reactor set")
      MapTables.reactor.setValue(newValue, forKey: self)
      self.isReactorBinded = false
      self.disposeBag = DisposeBag()
      self.performBinding()
    }
  }

  fileprivate var isReactorBinded: Bool {
    get { return MapTables.isReactorBinded.value(forKey: self, default: false) }
    set { MapTables.isReactorBinded.setValue(newValue, forKey: self) }
  }

  public func performBinding() {
    print("StoryboardView - performBinding")
    guard let reactor = self.reactor else {
        print("reactor nil이라 컷")
        return }
    guard !self.isReactorBinded else {
        print("이미 바인딩 돼있어서 컷")
        return }
    guard !self.shouldDeferBinding(reactor: reactor) else {
        print("shouldDeferBinding이 true라서 컷")
        return }
    print("bind 호출")
    self.bind(reactor: reactor)
    self.isReactorBinded = true
  }

  fileprivate func shouldDeferBinding(reactor: Reactor) -> Bool {
    #if !os(watchOS)
      return (self as? OSViewController)?.isViewLoaded == false
    #else
      return false
    #endif
  }
}

#if !os(watchOS)
extension OSViewController {
  @objc func _reactorkit_performBinding() {
    (self as? _ObjCStoryboardView)?.performBinding()
  }
}
#endif
#endif
