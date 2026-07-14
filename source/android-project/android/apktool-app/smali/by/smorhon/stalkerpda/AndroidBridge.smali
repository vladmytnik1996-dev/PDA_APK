.class public final Lby/smorhon/stalkerpda/AndroidBridge;
.super Ljava/lang/Object;
.source "AndroidBridge.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/AndroidBridge;->activity:Lby/smorhon/stalkerpda/MainActivity;
    return-void
.end method

.method public saveTextFile(Ljava/lang/String;Ljava/lang/String;)V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation
    new-instance v0, Lby/smorhon/stalkerpda/SaveRunnable;
    iget-object v1, p0, Lby/smorhon/stalkerpda/AndroidBridge;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-direct {v0, v1, p1, p2}, Lby/smorhon/stalkerpda/SaveRunnable;-><init>(Lby/smorhon/stalkerpda/MainActivity;Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {v1, v0}, Lby/smorhon/stalkerpda/MainActivity;->runOnUiThread(Ljava/lang/Runnable;)V
    return-void
.end method
