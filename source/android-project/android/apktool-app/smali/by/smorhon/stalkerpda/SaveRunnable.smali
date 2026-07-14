.class public final Lby/smorhon/stalkerpda/SaveRunnable;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "SaveRunnable.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;
.field private final name:Ljava/lang/String;
.field private final text:Ljava/lang/String;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/SaveRunnable;->activity:Lby/smorhon/stalkerpda/MainActivity;
    iput-object p2, p0, Lby/smorhon/stalkerpda/SaveRunnable;->name:Ljava/lang/String;
    iput-object p3, p0, Lby/smorhon/stalkerpda/SaveRunnable;->text:Ljava/lang/String;
    return-void
.end method

.method public run()V
    .locals 3
    iget-object v0, p0, Lby/smorhon/stalkerpda/SaveRunnable;->activity:Lby/smorhon/stalkerpda/MainActivity;
    iget-object v1, p0, Lby/smorhon/stalkerpda/SaveRunnable;->name:Ljava/lang/String;
    iget-object v2, p0, Lby/smorhon/stalkerpda/SaveRunnable;->text:Ljava/lang/String;
    invoke-virtual {v0, v1, v2}, Lby/smorhon/stalkerpda/MainActivity;->beginSave(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method
