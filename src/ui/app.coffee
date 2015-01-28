UIHelper = require('../common/uihelper.coffee')
GameLayer = require('./gameLayer.coffee')

AppLayer = cc.LayerColor.extend(
    ctor:()->
        @_super(cc.color.RED)

        label = new cc.LabelTTF("开始游戏", "", 32);
        menuItem = new cc.MenuItemLabel(label, ()->
            global.battleground = scene = new GameLayer()
            cc.director.pushScene(scene)
        , @);

        menu = new cc.Menu()
        menu.addChild(menuItem);

        @addChild(menu);
)

registerClass(AppLayer)

module.exports = ()->
    scene = new cc.Scene()
    layer = new AppLayer(scene)
    scene