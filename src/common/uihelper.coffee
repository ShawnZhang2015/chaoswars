

classArray = [
    cc.Node
    cc.Layer
    cc.LayerColor
    cc.Sprite
];

if ccui
    classArray = classArray.concat([
        ccui.ImageView
        ccui.Button
    ])
    cc.log(classArray)

#-----------------------------
OverloadCtor = (classType)->
    ctor = classType.prototype.ctor
    if !ctor
        return

    classType.prototype.ctor=()->
        if arguments.length == 0
            ctor.call(@)
            return

        parent = arguments[0]
        args = Array.prototype.slice.call(arguments)
        flag = false
        if parent instanceof cc.Node
            args = args[1..]
            flag = true

        ctor.apply(@, args)
        if flag
            parent.addChild(@)
        null

#-----------------------------
for classType in classArray
    OverloadCtor(classType)

#-----------------------------

module.exports =
    registerTouchEvent:(node)->
        listener = cc.EventListener.create(
            event: cc.EventListener.TOUCH_ONE_BY_ONE
            swallowTouches: true
        )

        if node.onTouchBegan
            listener.onTouchBegan = (touch, event)->
                node.onTouchBegan(touch, event)

        if node.onTouchMoved
            listener.onTouchMoved = (touch, event)->
                node.onTouchMoved(touch, event)

        if node.onTouchEnded
            listener.onTouchEnded = (touch, event)->
                node.onTouchEnded(touch, event)

        cc.eventManager.addListener(listener, node)
        listener



registerClass = (classType)->
    if classArray.indexOf(classType) == -1
        classArray.push(classType)
        OverloadCtor(classType)

global.registerClass = registerClass
