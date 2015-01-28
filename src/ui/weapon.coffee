
_ = require('../lib/underscore.js')._

Weapon = cc.Sprite.extend(
    cell: null
    fiveProperty: null
    targetWeapons: null
    type: null
    isActivity: null
    ctor:(parent)->
        @_super(parent, "res/ball.png")
        @setScale(1.5)
        @type = _.random(0, 2)
        typeImages = ["jiandao.png", "shitou.png", "bu.png"]
        image = new cc.Sprite(@, "res/" + typeImages[@type])
        image.setScale(0.7)
        image.setPosition(this.width / 2, this.height / 2)


    setCell:(cell)->
        if @cell == cell
            return

        if @cell
            temp = @cell
            @cell = null
            temp.setNode(null)


        if cell
            @cell = cell
            @cell.setNode(@)
            @setPosition(@cell.getParent().convertToWorldSpace(@cell.getCenter()))
            @setProperty()

    setProperty:(value)->
        if value != undefined
            @fiveProperty = value
        else
            @fiveProperty = _.random(0, Weapon.MAX_COUNT - 1)

        @setColor(Weapon.Colors[@fiveProperty])

    getProperty:()->
        @fiveProperty


    getCell:()->
        @cell

    getCol:()->
        cc.assert(@cell)
        @cell.col

    getRow:()->
        cc.assert(@cell)
        @cell.row

    bindTargets:(targetWeapons)->
        @isActivity = true
        if @targetWeapons == null
            @scheduleUpdate()
        @targetWeapons = targetWeapons
#        targetWeapon.runAction(cc.blink(1, 3))
#        targetWeapon.setBind(true)


    update: ()->
        for target in @targetWeapons
            if !target or !target.getParent()
                continue

            if cc.rectContainsPoint(@getBoundingBox(), target.getPosition())

                if !target.isActivity
                    target.removeFromParent()
                    return

                temp = @type - target.type
                if temp == 1 or temp == -2
                    target.removeFromParent()
                else if temp == 2 or temp == -1
                    @removeFromParent()
                else
                    @removeFromParent()
                    target.removeFromParent()

    onExit:()->
        @_super()
        if @cell
            @cell.setNode(null)

)

Weapon.Type =
    WT_SCISSORS: 1
    WT_STONE: 2
    WT_CLOTH: 3

Weapon.Properties =
    WP_MU: 0
    WP_HUO: 1
    WP_TU: 2
    WP_JING:3
    WP_SHUI: 4

Weapon.Colors = [cc.color.GREEN, cc.color.RED, cc.color.YELLOW, cc.color(200,200,200), cc.color.BLACK]

Weapon.MAX_COUNT = 5

module.exports = Weapon