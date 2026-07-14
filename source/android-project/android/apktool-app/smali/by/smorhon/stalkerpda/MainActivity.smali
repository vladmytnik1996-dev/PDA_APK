.class public Lby/smorhon/stalkerpda/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

.field private webView:Landroid/webkit/WebView;
.field private fileCallback:Landroid/webkit/ValueCallback;
.field private pendingExportText:Ljava/lang/String;
.field private pendingExportName:Ljava/lang/String;
.field private pendingWebPermission:Landroid/webkit/PermissionRequest;
.field private pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
.field private pendingGeoOrigin:Ljava/lang/String;
.field private lastBackPressed:J

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method private hideSystemUi()V
    .locals 2

    invoke-virtual {p0}, Lby/smorhon/stalkerpda/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v0

    const/16 v1, 0x400
    invoke-virtual {v0, v1}, Landroid/view/Window;->addFlags(I)V

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v0

    const/16 v1, 0x1706
    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 5
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    :try_start_startup
    invoke-virtual {p0}, Lby/smorhon/stalkerpda/MainActivity;->getWindow()Landroid/view/Window;
    move-result-object v0
    const/high16 v1, -0x80000000
    invoke-virtual {v0, v1}, Landroid/view/Window;->addFlags(I)V
    const-string v1, "#050805"
    invoke-static {v1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v1
    invoke-virtual {v0, v1}, Landroid/view/Window;->setStatusBarColor(I)V
    invoke-virtual {v0, v1}, Landroid/view/Window;->setNavigationBarColor(I)V

    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;

    const-string v1, "#07100A"
    invoke-static {v1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v1
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDatabaseEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setGeolocationEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V
    const/4 v3, 0x0
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setAllowFileAccessFromFileURLs(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setAllowUniversalAccessFromFileURLs(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setSupportZoom(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setBuiltInZoomControls(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setDisplayZoomControls(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setSaveFormData(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setMediaPlaybackRequiresUserGesture(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setMixedContentMode(I)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setUseWideViewPort(Z)V
    invoke-virtual {v1, v3}, Landroid/webkit/WebSettings;->setLoadWithOverviewMode(Z)V

    invoke-static {v3}, Landroid/webkit/WebView;->setWebContentsDebuggingEnabled(Z)V

    new-instance v1, Lby/smorhon/stalkerpda/LocalWebViewClient;
    invoke-direct {v1, p0}, Lby/smorhon/stalkerpda/LocalWebViewClient;-><init>(Lby/smorhon/stalkerpda/MainActivity;)V
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    new-instance v1, Lby/smorhon/stalkerpda/PdaWebChromeClient;
    invoke-direct {v1, p0}, Lby/smorhon/stalkerpda/PdaWebChromeClient;-><init>(Lby/smorhon/stalkerpda/MainActivity;)V
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebChromeClient(Landroid/webkit/WebChromeClient;)V

    new-instance v1, Lby/smorhon/stalkerpda/AndroidBridge;
    invoke-direct {v1, p0}, Lby/smorhon/stalkerpda/AndroidBridge;-><init>(Lby/smorhon/stalkerpda/MainActivity;)V
    const-string v4, "AndroidPda"
    invoke-virtual {v0, v1, v4}, Landroid/webkit/WebView;->addJavascriptInterface(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {}, Landroid/webkit/CookieManager;->getInstance()Landroid/webkit/CookieManager;
    move-result-object v1
    invoke-virtual {v1, v0, v3}, Landroid/webkit/CookieManager;->setAcceptThirdPartyCookies(Landroid/webkit/WebView;Z)V

    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->setContentView(Landroid/view/View;)V
    invoke-direct {p0}, Lby/smorhon/stalkerpda/MainActivity;->hideSystemUi()V
    const-string v1, "https://localhost/index.html"
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    :try_end_startup
    return-void

    .catch Ljava/lang/Throwable; {:try_start_startup .. :try_end_startup} :catch_startup

:catch_startup
    move-exception v0
    invoke-direct {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showStartupError(Ljava/lang/Throwable;)V
    return-void
.end method

.method private showStartupError(Ljava/lang/Throwable;)V
    .locals 7
    new-instance v0, Landroid/widget/TextView;
    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    const-string v1, "КПК Зоны не смог запуститься.\n\nДиагностика: "
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {p1}, Ljava/lang/Throwable;->getClass()Ljava/lang/Class;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    const-string v3, "\n"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {p1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v3
    if-nez v3, :message_ready
    const-string v3, "Без текста ошибки"
:message_ready
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    const-string v3, "\n\nСделайте скриншот этого экрана."
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const-string v1, "#D8F7C8"
    invoke-static {v1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v1
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V
    const-string v1, "#07100A"
    invoke-static {v1}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v1
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setBackgroundColor(I)V
    const/high16 v1, 0x41800000    # 16.0f
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v1, 0x20
    const/16 v2, 0x30
    invoke-virtual {v0, v1, v2, v1, v2}, Landroid/widget/TextView;->setPadding(IIII)V
    const/16 v1, 0x11
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setGravity(I)V
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->setContentView(Landroid/view/View;)V
    return-void
.end method

.method public openFileChooser(Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 3
    .param p1, "callback"
    .param p2, "params"

    if-eqz p1, :invalid_request
    if-eqz p2, :invalid_request

    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
    if-eqz v0, :no_previous
    const/4 v1, 0x0
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
:no_previous
    iput-object p1, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;

    :try_start
    invoke-virtual {p2}, Landroid/webkit/WebChromeClient$FileChooserParams;->createIntent()Landroid/content/Intent;
    move-result-object v0
    const-string v1, "android.intent.category.OPENABLE"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;
    const/16 v1, 0x1435
    invoke-virtual {p0, v0, v1}, Lby/smorhon/stalkerpda/MainActivity;->startActivityForResult(Landroid/content/Intent;I)V
    const/4 v0, 0x1
    return v0
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_no_picker

:catch_no_picker
    move-exception v2
    const/4 v0, 0x0
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
    invoke-interface {p1, v0}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
    const-string v1, "На устройстве нет приложения для выбора файла."
    invoke-virtual {p0, v1}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    const/4 v0, 0x0
    return v0

:invalid_request
    const/4 v0, 0x0
    return v0
.end method

.method public handleWebPermission(Landroid/webkit/PermissionRequest;)V
    .locals 5
    .param p1, "request"

    if-eqz p1, :done

    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->getOrigin()Landroid/net/Uri;
    move-result-object v0
    invoke-static {v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->isLocalUri(Landroid/net/Uri;)Z
    move-result v1
    if-nez v1, :origin_ok
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->deny()V
    return-void

:origin_ok
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->getResources()[Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v0
    const-string v1, "android.webkit.resource.VIDEO_CAPTURE"
    invoke-interface {v0, v1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :video_requested
    invoke-virtual {p1}, Landroid/webkit/PermissionRequest;->deny()V
    return-void

:video_requested
    const-string v0, "android.permission.CAMERA"
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v2
    if-nez v2, :request_runtime

    const/4 v2, 0x1
    new-array v3, v2, [Ljava/lang/String;
    const/4 v4, 0x0
    aput-object v1, v3, v4
    invoke-virtual {p1, v3}, Landroid/webkit/PermissionRequest;->grant([Ljava/lang/String;)V
    return-void

:request_runtime
    iget-object v2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    if-eqz v2, :store
    invoke-virtual {v2}, Landroid/webkit/PermissionRequest;->deny()V
:store
    iput-object p1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    const/4 v2, 0x1
    new-array v3, v2, [Ljava/lang/String;
    const/4 v4, 0x0
    aput-object v0, v3, v4
    const/16 v0, 0x2329
    invoke-virtual {p0, v3, v0}, Lby/smorhon/stalkerpda/MainActivity;->requestPermissions([Ljava/lang/String;I)V
:done
    return-void
.end method

.method public cancelWebPermission(Landroid/webkit/PermissionRequest;)V
    .locals 2
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    if-ne v0, p1, :done
    const/4 v1, 0x0
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
:done
    return-void
.end method

.method public handleGeolocationPermission(Ljava/lang/String;Landroid/webkit/GeolocationPermissions$Callback;)V
    .locals 5
    .param p1, "origin"
    .param p2, "callback"

    if-eqz p2, :done
    if-eqz p1, :deny_origin
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    invoke-static {v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->isLocalUri(Landroid/net/Uri;)Z
    move-result v0
    if-nez v0, :origin_ok

:deny_origin
    const/4 v0, 0x0
    invoke-interface {p2, p1, v0, v0}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
    return-void

:origin_ok
    const-string v0, "android.permission.ACCESS_FINE_LOCATION"
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v1
    if-nez v1, :check_coarse
    const/4 v0, 0x1
    const/4 v1, 0x0
    invoke-interface {p2, p1, v0, v1}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
    return-void

:check_coarse
    const-string v1, "android.permission.ACCESS_COARSE_LOCATION"
    invoke-virtual {p0, v1}, Lby/smorhon/stalkerpda/MainActivity;->checkSelfPermission(Ljava/lang/String;)I
    move-result v2
    if-nez v2, :request_runtime
    const/4 v2, 0x1
    const/4 v3, 0x0
    invoke-interface {p2, p1, v2, v3}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
    return-void

:request_runtime
    iget-object v2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
    if-eqz v2, :store_geo
    iget-object v3, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoOrigin:Ljava/lang/String;
    const/4 v4, 0x0
    invoke-interface {v2, v3, v4, v4}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
:store_geo
    iput-object p2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
    iput-object p1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoOrigin:Ljava/lang/String;
    const/4 v2, 0x2
    new-array v3, v2, [Ljava/lang/String;
    const/4 v4, 0x0
    aput-object v0, v3, v4
    const/4 v4, 0x1
    aput-object v1, v3, v4
    const/16 v0, 0x232a
    invoke-virtual {p0, v3, v0}, Lby/smorhon/stalkerpda/MainActivity;->requestPermissions([Ljava/lang/String;I)V
:done
    return-void
.end method

.method public beginSave(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "name"
    .param p2, "text"

    if-eqz p2, :bad_data
    invoke-virtual {p2}, Ljava/lang/String;->length()I
    move-result v0
    const/high16 v1, 0x400000
    if-gt v0, v1, :bad_data

    const-string v0, "zone-pda-backup.json"
    if-eqz p1, :name_ready
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object p1
    invoke-virtual {p1}, Ljava/lang/String;->length()I
    move-result v1
    if-lez v1, :name_ready
    const-string v1, "[^A-Za-z0-9._а-яА-ЯёЁ-]"
    const-string v2, "_"
    invoke-virtual {p1, v1, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
:name_ready
    iput-object p2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportText:Ljava/lang/String;
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportName:Ljava/lang/String;

    :try_start
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.CREATE_DOCUMENT"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "android.intent.category.OPENABLE"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;
    const-string v2, "application/json"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;
    const-string v2, "android.intent.extra.TITLE"
    invoke-virtual {v1, v2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const/16 v2, 0x1436
    invoke-virtual {p0, v1, v2}, Lby/smorhon/stalkerpda/MainActivity;->startActivityForResult(Landroid/content/Intent;I)V
    return-void
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_no_saver

:catch_no_saver
    move-exception v3
    const/4 v0, 0x0
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportText:Ljava/lang/String;
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportName:Ljava/lang/String;
    const-string v0, "Не найдено приложение для сохранения файла."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    return-void

:bad_data
    const-string v0, "Резервная копия слишком большая или повреждена."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    return-void
.end method

.method private writePendingExport(Landroid/net/Uri;)V
    .locals 6
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportText:Ljava/lang/String;
    if-eqz v0, :done
    if-eqz p1, :done

    :try_start
    invoke-virtual {p0}, Lby/smorhon/stalkerpda/MainActivity;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    const-string v2, "wt"
    invoke-virtual {v1, p1, v2}, Landroid/content/ContentResolver;->openOutputStream(Landroid/net/Uri;Ljava/lang/String;)Ljava/io/OutputStream;
    move-result-object v1
    if-eqz v1, :write_fail
    new-instance v2, Ljava/io/OutputStreamWriter;
    const-string v3, "UTF-8"
    invoke-direct {v2, v1, v3}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/lang/String;)V
    invoke-virtual {v2, v0}, Ljava/io/OutputStreamWriter;->write(Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/OutputStreamWriter;->flush()V
    invoke-virtual {v2}, Ljava/io/OutputStreamWriter;->close()V
    const-string v0, "Резервная копия сохранена."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    goto :clear

:write_fail
    const-string v0, "Не удалось открыть выбранный файл для записи."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    goto :clear
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_write

:catch_write
    move-exception v5
    const-string v0, "Ошибка сохранения резервной копии."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V

:clear
    const/4 v0, 0x0
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportText:Ljava/lang/String;
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportName:Ljava/lang/String;
:done
    return-void
.end method

.method public showToast(Ljava/lang/String;)V
    .locals 2
    const/4 v0, 0x0
    invoke-static {p0, p1, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V
    return-void
.end method

.method protected onActivityResult(IILandroid/content/Intent;)V
    .locals 4
    const/16 v0, 0x1435
    if-ne p1, v0, :check_save
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
    const/4 v1, 0x0
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
    if-eqz v0, :done
    invoke-static {p2, p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->parseResult(ILandroid/content/Intent;)[Landroid/net/Uri;
    move-result-object v1
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
    goto :done

:check_save
    const/16 v0, 0x1436
    if-ne p1, v0, :super_call
    const/4 v0, -0x1
    if-ne p2, v0, :clear_save
    if-eqz p3, :clear_save
    invoke-virtual {p3}, Landroid/content/Intent;->getData()Landroid/net/Uri;
    move-result-object v0
    invoke-direct {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->writePendingExport(Landroid/net/Uri;)V
    goto :done
:clear_save
    const/4 v0, 0x0
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportText:Ljava/lang/String;
    iput-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingExportName:Ljava/lang/String;
    goto :done

:super_call
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onActivityResult(IILandroid/content/Intent;)V
:done
    return-void
.end method

.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V
    .locals 7
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V

    const/16 v0, 0x2329
    if-ne p1, v0, :check_geo
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    const/4 v1, 0x0
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    if-eqz v0, :done
    if-eqz p3, :deny_web
    array-length v2, p3
    if-lez v2, :deny_web
    const/4 v2, 0x0
    aget v2, p3, v2
    if-nez v2, :deny_web

    const/4 v2, 0x1
    new-array v3, v2, [Ljava/lang/String;
    const-string v4, "android.webkit.resource.VIDEO_CAPTURE"
    const/4 v5, 0x0
    aput-object v4, v3, v5
    invoke-virtual {v0, v3}, Landroid/webkit/PermissionRequest;->grant([Ljava/lang/String;)V
    goto :done

:deny_web
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->deny()V
    goto :done

:check_geo
    const/16 v0, 0x232a
    if-ne p1, v0, :done
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
    iget-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoOrigin:Ljava/lang/String;
    const/4 v2, 0x0
    iput-object v2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
    iput-object v2, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoOrigin:Ljava/lang/String;
    if-eqz v0, :done

    const/4 v3, 0x0
    if-eqz p3, :geo_result
    array-length v4, p3
    const/4 v5, 0x0

:geo_loop
    if-ge v5, v4, :geo_result
    aget v6, p3, v5
    if-nez v6, :geo_next
    const/4 v3, 0x1
    goto :geo_result

:geo_next
    add-int/lit8 v5, v5, 0x1
    goto :geo_loop

:geo_result
    const/4 v4, 0x0
    invoke-interface {v0, v1, v3, v4}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V

:done
    return-void
.end method

.method public onBackPressed()V
    .locals 3
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;
    if-eqz v0, :fallback
    new-instance v1, Lby/smorhon/stalkerpda/BackValueCallback;
    invoke-direct {v1, p0}, Lby/smorhon/stalkerpda/BackValueCallback;-><init>(Lby/smorhon/stalkerpda/MainActivity;)V
    const-string v2, "(function(){try{return !!(window.pdaHandleAndroidBack&&window.pdaHandleAndroidBack());}catch(e){return false;}})()"
    invoke-virtual {v0, v2, v1}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void
:fallback
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method

.method public handleBackResult(Z)V
    .locals 6
    if-eqz p1, :not_consumed
    return-void
:not_consumed
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v0
    iget-wide v2, p0, Lby/smorhon/stalkerpda/MainActivity;->lastBackPressed:J
    sub-long v2, v0, v2
    const-wide/16 v4, 0x7d0
    cmp-long v2, v2, v4
    if-gtz v2, :arm_exit
    invoke-virtual {p0}, Lby/smorhon/stalkerpda/MainActivity;->finish()V
    return-void
:arm_exit
    iput-wide v0, p0, Lby/smorhon/stalkerpda/MainActivity;->lastBackPressed:J
    const-string v0, "Нажмите «Назад» ещё раз для выхода."
    invoke-virtual {p0, v0}, Lby/smorhon/stalkerpda/MainActivity;->showToast(Ljava/lang/String;)V
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .locals 0

    invoke-super {p0, p1}, Landroid/app/Activity;->onWindowFocusChanged(Z)V

    if-eqz p1, :done
    invoke-direct {p0}, Lby/smorhon/stalkerpda/MainActivity;->hideSystemUi()V

:done
    return-void
.end method

.method protected onPause()V
    .locals 3
    invoke-super {p0}, Landroid/app/Activity;->onPause()V
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;
    if-eqz v0, :done
    invoke-virtual {v0}, Landroid/webkit/WebView;->onPause()V
    const-string v1, "window.dispatchEvent(new Event('blur'));"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
:done
    return-void
.end method

.method protected onResume()V
    .locals 1
    invoke-super {p0}, Landroid/app/Activity;->onResume()V
    invoke-direct {p0}, Lby/smorhon/stalkerpda/MainActivity;->hideSystemUi()V
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;
    if-eqz v0, :done
    invoke-virtual {v0}, Landroid/webkit/WebView;->onResume()V
:done
    return-void
.end method

.method protected onDestroy()V
    .locals 3
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
    if-eqz v0, :no_file
    const/4 v1, 0x0
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->fileCallback:Landroid/webkit/ValueCallback;
:no_file
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
    if-eqz v0, :no_web_perm
    invoke-virtual {v0}, Landroid/webkit/PermissionRequest;->deny()V
    const/4 v1, 0x0
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingWebPermission:Landroid/webkit/PermissionRequest;
:no_web_perm
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoCallback:Landroid/webkit/GeolocationPermissions$Callback;
    if-eqz v0, :no_geo
    iget-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->pendingGeoOrigin:Ljava/lang/String;
    const/4 v2, 0x0
    invoke-interface {v0, v1, v2, v2}, Landroid/webkit/GeolocationPermissions$Callback;->invoke(Ljava/lang/String;ZZ)V
:no_geo
    iget-object v0, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;
    if-eqz v0, :finish
    const-string v1, "about:blank"
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    invoke-virtual {v0}, Landroid/webkit/WebView;->stopLoading()V
    invoke-virtual {v0}, Landroid/webkit/WebView;->clearHistory()V
    invoke-virtual {v0}, Landroid/webkit/WebView;->removeAllViews()V
    invoke-virtual {v0}, Landroid/webkit/WebView;->destroy()V
    const/4 v1, 0x0
    iput-object v1, p0, Lby/smorhon/stalkerpda/MainActivity;->webView:Landroid/webkit/WebView;
:finish
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
