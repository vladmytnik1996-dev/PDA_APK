.class public final Lby/smorhon/stalkerpda/LocalWebViewClient;
.super Landroid/webkit/WebViewClient;
.source "LocalWebViewClient.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebViewClient;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/LocalWebViewClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    return-void
.end method

.method public static isLocalUri(Landroid/net/Uri;)Z
    .locals 3
    if-eqz p0, :not_local

    invoke-virtual {p0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;
    move-result-object v0
    const-string v1, "https"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :not_local

    invoke-virtual {p0}, Landroid/net/Uri;->getHost()Ljava/lang/String;
    move-result-object v0
    const-string v1, "localhost"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :not_local

    invoke-virtual {p0}, Landroid/net/Uri;->getPort()I
    move-result v0
    const/4 v1, -0x1
    if-eq v0, v1, :local
    const/16 v1, 0x1bb
    if-ne v0, v1, :not_local

:local
    const/4 v0, 0x1
    return v0

:not_local
    const/4 v0, 0x0
    return v0
.end method

.method private openExternal(Landroid/net/Uri;)Z
    .locals 4
    if-eqz p1, :handled

    invoke-virtual {p1}, Landroid/net/Uri;->getScheme()Ljava/lang/String;
    move-result-object v0
    const-string v1, "https"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :allowed
    const-string v1, "http"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :allowed
    const-string v1, "mailto"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :handled

:allowed
    :try_start_external
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.VIEW"
    invoke-direct {v1, v2, p1}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V
    iget-object v2, p0, Lby/smorhon/stalkerpda/LocalWebViewClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v2, v1}, Lby/smorhon/stalkerpda/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_external
    .catch Ljava/lang/Exception; {:try_start_external .. :try_end_external} :catch_external

    goto :handled

:catch_external
    move-exception v3

:handled
    const/4 v0, 0x1
    return v0
.end method

.method public shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    .locals 5
    :try_start_intercept
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;
    move-result-object v0
    invoke-static {v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->isLocalUri(Landroid/net/Uri;)Z
    move-result v1
    if-eqz v1, :fallback

    invoke-virtual {v0}, Landroid/net/Uri;->getPath()Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :serve_index
    const-string v2, "/"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :serve_index
    const-string v2, "/index.html"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :not_found

:serve_index
    iget-object v1, p0, Lby/smorhon/stalkerpda/LocalWebViewClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v1}, Lby/smorhon/stalkerpda/MainActivity;->getAssets()Landroid/content/res/AssetManager;
    move-result-object v1
    const-string v2, "www/index.html"
    invoke-virtual {v1, v2}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;
    move-result-object v1
    new-instance v2, Landroid/webkit/WebResourceResponse;
    const-string v3, "text/html"
    const-string v4, "UTF-8"
    invoke-direct {v2, v3, v4, v1}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/io/InputStream;)V
    return-object v2

:not_found
    new-instance v1, Ljava/io/ByteArrayInputStream;
    const-string v2, "Not found"
    const-string v3, "UTF-8"
    invoke-virtual {v2, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v2
    invoke-direct {v1, v2}, Ljava/io/ByteArrayInputStream;-><init>([B)V
    new-instance v2, Landroid/webkit/WebResourceResponse;
    const-string v3, "text/plain"
    const-string v4, "UTF-8"
    invoke-direct {v2, v3, v4, v1}, Landroid/webkit/WebResourceResponse;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/io/InputStream;)V
    const/16 v1, 0x194
    const-string v3, "Not Found"
    invoke-virtual {v2, v1, v3}, Landroid/webkit/WebResourceResponse;->setStatusCodeAndReasonPhrase(ILjava/lang/String;)V
    return-object v2
    :try_end_intercept
    .catch Ljava/lang/Exception; {:try_start_intercept .. :try_end_intercept} :catch_intercept

:catch_intercept
    move-exception v0
    goto :fallback

:fallback
    invoke-super {p0, p1, p2}, Landroid/webkit/WebViewClient;->shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;
    move-result-object v0
    return-object v0
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Z
    .locals 2
    if-eqz p2, :block
    invoke-interface {p2}, Landroid/webkit/WebResourceRequest;->getUrl()Landroid/net/Uri;
    move-result-object v0
    invoke-static {v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->isLocalUri(Landroid/net/Uri;)Z
    move-result v1
    if-eqz v1, :external
    const/4 v0, 0x0
    return v0

:external
    invoke-direct {p0, v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->openExternal(Landroid/net/Uri;)Z
    move-result v0
    return v0

:block
    const/4 v0, 0x1
    return v0
.end method

.method public shouldOverrideUrlLoading(Landroid/webkit/WebView;Ljava/lang/String;)Z
    .locals 2
    if-eqz p2, :block
    invoke-static {p2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    invoke-static {v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->isLocalUri(Landroid/net/Uri;)Z
    move-result v1
    if-eqz v1, :external
    const/4 v0, 0x0
    return v0

:external
    invoke-direct {p0, v0}, Lby/smorhon/stalkerpda/LocalWebViewClient;->openExternal(Landroid/net/Uri;)Z
    move-result v0
    return v0

:block
    const/4 v0, 0x1
    return v0
.end method
