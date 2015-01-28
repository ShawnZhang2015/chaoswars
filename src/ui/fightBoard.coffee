Weapon = require("./weapon.coffee")
UIHelp = require("../common/uihelper.coffee")
_ = require('../lib/underscore.js')._

#########################################
#cell类,描述board中的一个格子
#########################################
Cell = cc.Layer.extend(
    row: null,
    col: null,
    node: null
    ctor:(rect, @row, @col)->
        @_super()
        #@setOpacity(0)
        #@setColor(cc.color(100,200,100,100))
        @setAnchorPoint(0,0)
        @setContentSize(rect.width - 1, rect.height - 1)
        @setPosition(cc.p(rect.x, rect.y))

    getCenter:()->
        cc.p(@x + @width * 0.5, @y + @height * 0.5)

    setNode:(node)->
        if @node == node
            return

        if @node
            temp = @node
            @node = null
            temp.setCell(null)


        if node instanceof Weapon
            @node = node
            @node.setCell(@)

    getNode:()->
        @node
    setIndex:(@index)->
)

#########################################
#提示线
#########################################
class HintLines

    constructor:(@parent, linesCount)->
        #@batchNode = cc.Scale9Sprite.create("res/line.png", linesCount)

        @fingerLine = new cc.Scale9Sprite("res/line.png")
        @fingerLine.setAnchorPoint(cc.p(0, 0.5))
        @parent.addChild(@fingerLine)
        @linesArray = []

    refresh:(itemArray)->
        if itemArray.length <= 1
            return

        firstPoint = null
        nextPoint = null
        for item, i in itemArray
            firstPoint = @parent.convertToNodeSpace(item.getPosition())
            nextItem = itemArray[i + 1]
            if !nextItem
                break
            nextPoint = @parent.convertToNodeSpace(nextItem.getPosition())

            vect = @getDoublePointVector(firstPoint, nextPoint)
            line = @linesArray[i]
            if !line
                line = new cc.Scale9Sprite("res/line.png")
                line.setAnchorPoint(cc.p(0, 0.5))
                line.visible = false
                @parent.addChild(line, 10)
                @linesArray.push(line)

            if line.visible
                continue

            line.setPreferredSize(cc.size(vect.length, line.height))
            line.setRotation(vect.angle)
            line.setPosition(firstPoint)
            line.setVisible(true)
            cc.log(line.tag + ":" +JSON.stringify(line.getPosition()))

    updateFingerLine: (item, fingerPoint)->
        point = @parent.convertToNodeSpace(item.getPosition())
        vect = @getDoublePointVector(point, @parent.convertToNodeSpace(fingerPoint))
        @fingerLine.setPreferredSize(cc.size(vect.length, @fingerLine.height))
        @fingerLine.setRotation(vect.angle)
        @fingerLine.setPosition(point)
        @fingerLine.visible = true

    disappear:()->
        @fingerLine.visible = false

        for item in @linesArray
            item.setVisible(false)
            item.removeFromParent(true)
        @linesArray = []


    getDoublePointVector: (point1, point2)->
        x = point1.x - point2.x;
        y = point1.y - point2.y
        length = Math.sqrt(Math.pow(x, 2) +  Math.pow(y, 2))
        radian = Math.atan2(x, y)
        angle = 180 * radian / Math.PI + 90
        {length: length, angle: angle}




#########################################
#根据一个矩形大小,生成网络单元,返回二维数组
#########################################
getMatrixArray = (parent, rect, row, col)->
    point = cc.p(rect.x, rect.y)
    size  = cc.size(rect.width / col, rect.height / row)

    matrixArray = []
    for i in [0..row - 1]
        arow = []
        matrixArray.push(arow)
        for j in [0..col - 1]
            cellRect = cc.rect(point.x, point.y, size.width, size.height)
            cell = new Cell(cellRect, i, j)
            arow.push(cell)
            point.x += size.width

        point.x = rect.x
        point.y += size.height
        cc.log(JSON.stringify(point))

    matrixArray

#########################################
#战斗面板类
#########################################
FightBoard = cc.Layer.extend(
    matrixArray: null,
    itemArray: null,
    selectedItemArray: null,
    delegate: null,
    isTop: null,
    ctor:(@battleground, rect, row, col, isTop)->
        #@_super(cc.color.RED)
        @_super()
        @ignoreAnchor = false
        @battleground.addChild(@)
        @setContentSize(cc.size(rect.width, rect.height))
        @setPosition(cc.p(rect.x , rect.y))
        @setAnchorPoint(0.5, 0.5)

        @matrixArray = getMatrixArray(@, rect, row, col)

        @isTop = isTop
        if @isTop
            #@matrixArray = @matrixArray.reverse()
            @setPosition(cc.p(cc.winSize.width / 2, cc.winSize.height - @height / 2))
        else
            @matrixArray = @matrixArray.reverse()
            @setPosition(cc.p(cc.winSize.width / 2, @height / 2))
            #在下放的才能触摸

        UIHelp.registerTouchEvent(@)

        @itemArray = []
        index = 0
        for arow in @matrixArray
            for cell in arow
                @addChild(cell)
                weapon = @createWeapon("res/ball.png")
                weapon.setLocalZOrder(1)
                weapon.setCell(cell)
                cell.setIndex(index++)
                @itemArray.push(weapon)

        #if !@isTop
        #创建提示线
        @hintLines = new HintLines(@, @itemArray.length)

    createWeapon: (res)->
        return new Weapon(@battleground, res)

    setWeaponProperty:(x, y, value) ->
        @matrixArray[x][y].getNode().setProperty(value)

    checkItem: (point)->
        firstItem = @selectedItemArray[0]

        for item in @itemArray
            rect = item.getBoundingBox()
            if !cc.rectContainsPoint(rect, point)
                continue

            if !firstItem
                return item

            if item.getProperty() != firstItem.getProperty()
                continue

            if !@isNeighbar(item)
                continue

            index = @selectedItemArray.indexOf(item)
            #为已经选择的倒数第二个, 删除最后一个点
            if index != -1 and index == @selectedItemArray.length - 2
                @removeLastItem()
                return

            if index != -1
                return

            return item

    isNeighbar:(item)->
        lastItem = _.last(@selectedItemArray)
        if (Math.abs(item.getRow() - lastItem.getRow()) >= 2)
            return false
        if (Math.abs(item.getCol() - lastItem.getCol()) >= 2)
            return false
        true


    addSelectedItem: (item)->
        if !item
            return

        @selectedItemArray.push(item)
        @hintLines.refresh(@selectedItemArray)


    removeLastItem: ()->
        cc.assert(@selectedItemArray.length)
        @selectedItemArray.pop()
        @hintLines.refresh(@selectedItemArray)

    #触摸开始
    onTouchBegan: (touch)->
        point = (touch.getLocation())
        if !cc.rectContainsPoint(@.getBoundingBox(), point)
            return false;
        cc.log("isTop:" + @isTop);

        @selectedItemArray = []
        @hintLines.disappear()

        item = @checkItem(point)
        @addSelectedItem(item)
        true;


    onTouchMoved: (touch)->
        if !@selectedItemArray[0]
            return;

        point = (touch.getLocation())
        item = @checkItem(point)
        @addSelectedItem(item)
        if !_.isEmpty(@selectedItemArray)
            @hintLines.updateFingerLine(_.last(@selectedItemArray), point)


    setDelegate:(delegate)->
        @delegate = delegate

    onTouchEnded: (touch)->
        if @selectedItemArray.length < 2
            return;

#        for item in @selectedItemArray
#            item.setProperty(Weapon.Properties.WP_SHUI)
        #@hintLines.disappear()
        if @delegate and @delegate.onOpenFire
            @delegate.onOpenFire(@, @selectedItemArray)

    #执行动画
    onUpdate: (indexArray)->
        items = []
        #能过序号遍历item, 修改父节点
        for i in indexArray
            item = @itemArray[i]
            items.push(item)

        speed = cc.winSize.height / 5
        y = if @isTop then 0 else cc.winSize.height
        for item in items
            targetItems = @delegate.searchTargetItems(@, item.getCol())
            item.bindTargets(targetItems)
            distance = if @isTop then item.y else  Math.abs(cc.winSize.height - item.y)
            moveTo = cc.moveTo(distance / speed, cc.p(item.x ,y))
            item.runAction(moveTo)

    getColItems: (col)->
        items = []
        for rowArray in @matrixArray
            item = rowArray[col].getNode()
            if item
                items.push(item)
        items

    updateLines: ()->
        @hintLines.refresh(@selectedItemArray)
)

registerClass(Cell)
module.exports = (()->
    return FightBoard)()