function token = uiGetToken()
    app = nansen.module.sharebrain.services.ebrains.GetTokenApp();
    waitfor(app.UIFigure)
    token = getenv('EBRAINS_ACCESS_TOKEN');
end