.class public final Lby/smorhon/stalkerpda/PdaWebChromeClient;
.super Landroid/webkit/WebChromeClient;
.source "PdaWebChromeClient.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebChromeClient;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/PdaWebChromeClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    return-void
.end method

.method public onPermissionRequest(Landroid/webkit/PermissionRequest;)V
    .locals 2
    new-instance v0, Lby/smorhon/stalkerpda/PermissionRunnable;
    iget-object v1, p0, Lby/smorhon/stalkerpda/PdaWebChromeClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-direct {v0, v1, p1}, Lby/smorhon/stalkerpda/PermissionRunnable;-><init>(Lby/smorhon/stalkerpda/MainActivity;Landroid/webkit/PermissionRequest;)V
    invoke-virtual {v1, v0}, Lby/smorhon/stalkerpda/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method

.method public onPermissionRequestCanceled(Landroid/webkit/PermissionRequest;)V
    .locals 1
    iget-object v0, p0, Lby/smorhon/stalkerpda/PdaWebChromeClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v0, p1}, Lby/smorhon/stalkerpda/MainActivity;->cancelWebPermission(Landroid/webkit/PermissionRequest;)V
    return-void
.end method

.method public onGeolocationPermissionsShowPrompt(Ljava/lang/String;Landroid/webkit/GeolocationPermissions$Callback;)V
    .locals 1
    iget-object v0, p0, Lby/smorhon/stalkerpda/PdaWebChromeClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v0, p1, p2}, Lby/smorhon/stalkerpda/MainActivity;->handleGeolocationPermission(Ljava/lang/String;Landroid/webkit/GeolocationPermissions$Callback;)V
    return-void
.end method

.method public onShowFileChooser(Landroid/webkit/WebView;Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 1
    iget-object v0, p0, Lby/smorhon/stalkerpda/PdaWebChromeClient;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v0, p2, p3}, Lby/smorhon/stalkerpda/MainActivity;->openFileChooser(Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    move-result v0
    return v0
.end method
