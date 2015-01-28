# chaoswars
这个demo是使用cocos2d-js+CoffeeScript+Browersify编写，主要是尝试如何在cocos2d-js中使用模块化的编程。

源码编译步骤：

* 1.安装CoffeeScript
    * npm install -g coffee-script
* 2.安装Browersify
    * npm install -g browserify
* 3.安装coffeeify插件
    * npm install coffeeify
    * coffeeify是Browersify的插件，用于Browersify下的javascript与CoffeeScript的混合开发。
    * 安装时注意不能使用-g参数，不然之后的编译会出错。
* 4.编译
    * browserify -t coffeeify src/main.coffee --debug > main.js