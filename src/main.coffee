
resources = require('./resource.coffee').resources

cc.game.onStart = ()->
    cc.view.adjustViewPort(true);
    cc.view.setDesignResolutionSize(640, 960, cc.ResolutionPolicy.SHOW_ALL)
    cc.view.resizeWithBrowserSize(true)

    app = require('./ui/app.coffee')

    cc.LoaderScene.preload(resources, ->
        cc.director.runScene(app());
    )

cc.game.run()