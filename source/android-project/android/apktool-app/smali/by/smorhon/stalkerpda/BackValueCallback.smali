.class public final Lby/smorhon/stalkerpda/BackValueCallback;
.super Ljava/lang/Object;
.implements Landroid/webkit/ValueCallback;
.source "BackValueCallback.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/BackValueCallback;->activity:Lby/smorhon/stalkerpda/MainActivity;
    return-void
.end method

.method public onReceiveValue(Ljava/lang/Object;)V
    .locals 3
    const/4 v0, 0x0
    if-eqz p1, :send
    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "true"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
:send
    iget-object v1, p0, Lby/smorhon/stalkerpda/BackValueCallback;->activity:Lby/smorhon/stalkerpda/MainActivity;
    invoke-virtual {v1, v0}, Lby/smorhon/stalkerpda/MainActivity;->handleBackResult(Z)V
    return-void
.end method
