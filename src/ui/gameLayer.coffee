
FightBoard = require('./fightBoard.coffee');
GameLayer = cc.Layer.extend(
    redBoard: null,
    blueBoard: null,
    ctor:(parent)->
        @_super(parent)

        background = new cc.Sprite(@, "res/background.jpg")
        background.setAnchorPoint(0,0)

        @redBoard = new FightBoard(@, cc.rect(0,0,640, 320), 4, 8)
        @redBoard.setDelegate(@)

        @blueBoard = new FightBoard(@, cc.rect(0,0,640, 320), 4, 8, true)
        @blueBoard.setDelegate(@)

    onOpenFire:(sender, weapons)->
        indexArray = []
        for item in weapons
            indexArray.push(item.getCell().index)
        if sender == @redBoard
            @redBoard.onUpdate(indexArray)
        else if sender == @blueBoard
            @blueBoard.onUpdate(indexArray)
        #@blueBoard.onUpdate(indexArray)

    searchTargetItems:(sender, col)->
        if @redBoard == sender
            @blueBoard.getColItems(col)
        else
            @redBoard.getColItems(col)
)

module.exports = GameLayer