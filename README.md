BlockSample
===========

示例代码展示在MRC和ARC环境下使用block时常见的循环引用问题：
1、block引用self，self引用block，以及相应的解决方案。
2、A对象引用B对象，B对象引用block，block引用A对象，以及相应的解决方案。
3、A对象不引用B对象，B对象引用block，block引用A对象，该种情况不存在循环引用问题。
